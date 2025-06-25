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
      if (kDebugMode) {
        print("Fetch Products Response: ${response.body}");
      }

      List<dynamic> fetchedProducts = json.decode(response.body);

      setState(() {
        products =
            fetchedProducts.map((product) {
              String imageUrl = product["image"] ?? "";
              if (!imageUrl.startsWith("http")) {
                if (!imageUrl.contains("product_images/")) {
                  imageUrl =
                      "https://test.zuasoko.com/product_images/$imageUrl";
                } else {
                  imageUrl = "https://test.zuasoko.com/$imageUrl";
                }
              }

              return {
                ...product,
                "image": imageUrl,
                "price_per_kg": product["price_per_kg"].toString(),
                "weight": product["weight"].toString(),
                "is_assigned":
                    product["is_assigned"] == true ||
                    product["is_assigned"] == 1, // handle bool/int
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
      if (kDebugMode) {
        print("Fetch Drivers Response: ${response.body}");
      }
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
      builder: (context) {
        return AlertDialog(
          title: Text("Assign Driver to ${product['description']}"),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    drivers.map((driver) {
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
        );
      },
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

      if (kDebugMode) {
        print("Assign Driver Response: $data");
      }

      if (data["success"] != null) {
        showSnackbar("Driver assigned successfully.");
        fetchAllProducts(); // Refresh
      } else {
        showSnackbar("Error: ${data['error']}");
      }
    } catch (e) {
      if (kDebugMode) print("Network error: $e");
      showSnackbar("Network error!");
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "All Products",
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    child: ListTile(
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.network(
                          product['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/placeholder.png',
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      title: Text(product['description']),
                      subtitle: Text(
                        "Price: Ksh ${product['price_per_kg']} per kg\n"
                        "Weight: ${product['weight']}kg\n"
                        "Farmer: ${product['username'] ?? 'N/A'}",
                      ),
                      trailing:
                          product['is_assigned'] == true
                              ? const Text(
                                "Assigned",
                                style: TextStyle(color: Colors.green),
                              )
                              : ElevatedButton(
                                onPressed: () => assignDriverDialog(product),
                                child: const Text("Assign Driver"),
                              ),
                    ),
                  );
                },
              ),
    );
  }
}
