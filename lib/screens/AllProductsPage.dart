import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_page.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  List<dynamic> products = [];
  List<dynamic> drivers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  Future<void> fetchAllProducts() async {
    setState(() => isLoading = true);
    var url = Uri.parse("https://test.zuasoko.com/fetch_all_products");

    try {
      final response = await http.get(url);
      if (kDebugMode) print("Fetch Products Response: ${response.body}");

      List<dynamic> fetchedProducts = json.decode(response.body);

      setState(() {
        products = fetchedProducts.map((product) {
          String imageUrl = product["image"] ?? "";
          if (!imageUrl.startsWith("http")) {
            if (!imageUrl.contains("product_images/")) {
              imageUrl = "https://test.zuasoko.com/product_images/$imageUrl";
            } else {
              imageUrl = "https://test.zuasoko.com/$imageUrl";
            }
          }

          return {
            ...product,
            "image": imageUrl,
            "price_per_kg": product["price_per_kg"].toString(),
            "weight": product["weight"].toString(),
            "is_assigned": product["is_assigned"] == true || product["is_assigned"] == 1,
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (kDebugMode) print("Error fetching products: $e");
      showSnackbar("Failed to load products.");
    }
  }

  Future<void> fetchDrivers() async {
    var url = Uri.parse("https://test.zuasoko.com/fetch_drivers");

    try {
      final response = await http.get(url);
      if (kDebugMode) print("Fetch Drivers Response: ${response.body}");

      setState(() {
        drivers = json.decode(response.body);
      });
    } catch (e) {
      if (kDebugMode) print("Error fetching drivers: $e");
      showSnackbar("Failed to load drivers.");
    }
  }

  void assignDriverDialog(dynamic product) async {
    await fetchDrivers();
    if (drivers.isEmpty) {
      showSnackbar("No drivers available.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Assign Driver to ${product['description']}"),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: drivers.map((driver) {
                return ListTile(
                  title: Text(driver['name'] ?? "Unnamed Driver"),
                  onTap: () {
                    assignDriver(product['id'], driver['id']);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> assignDriver(int productId, int driverId) async {
    var url = Uri.parse("https://test.zuasoko.com/assign_to_driver");

    try {
      final response = await http.post(
        url,
        body: {
          "product_id": productId.toString(),
          "driver_id": driverId.toString(),
        },
      );

      final data = json.decode(response.body);
      if (data["success"] != null) {
        showSnackbar("Driver assigned successfully.");
        fetchAllProducts(); // Refresh
      } else {
        showSnackbar("Error: ${data['error']}");
      }
    } catch (e) {
      showSnackbar("Network error!");
    }
  }

  void suggestPriceDialog(dynamic product) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Suggest Price for ${product['description']}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Enter new suggested price (per kg)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              suggestNewPrice(product['id'], controller.text.trim());
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<void> suggestNewPrice(int productId, String price) async {
    if (price.isEmpty || double.tryParse(price) == null) {
      showSnackbar("Invalid price input");
      return;
    }

    var url = Uri.parse("https://test.zuasoko.com/suggest_new_price");

    try {
      final response = await http.post(
        url,
        body: {
          "product_id": productId.toString(),
          "suggested_price": price,
        },
      );

      final data = json.decode(response.body);
      if (data["success"] != null) {
        showSnackbar("Suggestion submitted!");
      } else {
        showSnackbar("Error: ${data['error']}");
      }
    } catch (e) {
      showSnackbar("Network error!");
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "All Products",
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
  final product = products[index];
  return Card(
    margin: const EdgeInsets.all(10),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Image.network(
              product['image'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/placeholder.png', fit: BoxFit.cover);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['description'], style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Price: Ksh ${product['price_per_kg']} per kg"),
                Text("Weight: ${product['weight']}kg"),
                Text("Farmer: ${product['username'] ?? 'N/A'}"),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (product['is_assigned'] == true)
                      const Text("Assigned", style: TextStyle(color: Colors.green))
                    else
                      ElevatedButton(
                        onPressed: () => assignDriverDialog(product),
                        child: const Text("Assign Driver"),
                      ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => suggestPriceDialog(product),
                      child: const Text("Suggest Price"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
},



            ),
    );
  }
}
