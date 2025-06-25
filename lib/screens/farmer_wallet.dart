import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_page.dart'; // Import your BasePage widget

class FarmerWallet extends StatefulWidget {
  final String userId;
  final Widget? drawer; // Add optional drawer

  const FarmerWallet({super.key, required this.userId, this.drawer});

  @override
  FarmerWalletState createState() => FarmerWalletState();
}

class FarmerWalletState extends State<FarmerWallet> {
  List<dynamic> products = [];
  bool isLoading = true;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse(
      "https://test.zuasoko.com/get-farmer-products?userId=${widget.userId}",
    );
    print("Sending farmer_id: ${widget.userId}");

    try {
      // final response = await http.post(url, body: {'farmer_id': widget.userId});
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("Response: ${response.body}");

        try {
          final List<dynamic> data = jsonDecode(response.body);

          double computedTotal = 0.0;
          for (var product in data) {
            double pricePerKg =
                double.tryParse(product["price_per_kg"].toString()) ?? 0.0;
            double weight =
                double.tryParse(product["weight"].toString()) ?? 0.0;
            computedTotal += pricePerKg * weight;
          }

          setState(() {
            products = data;
            totalAmount = computedTotal;
            isLoading = false;
          });
        } catch (e) {
          print("JSON Decode Error: $e");
          setState(() => isLoading = false);
        }
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> cashOut() async {
    final url = Uri.parse(
      "https://test.zuasoko.com/cashout?userId=${widget.userId}",
    );

    try {
      final response = await http.post(
        url,
        body: {'farmer_id': widget.userId, 'amount': totalAmount.toString()},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Cashout successful"),
          ),
        );
      } else {
        throw Exception("Cashout failed");
      }
    } catch (e) {
      print("Error in cashout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to process cashout")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Farmer Wallet",
      drawer: widget.drawer, // pass the drawer to BasePage
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : products.isEmpty
              ? const Center(child: Text("No accepted products found"))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.all(10),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                "https://test.zuasoko.com/product_images/${product['image']}",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print(
                                    "Failed to load image: ${product['image']}, Error: $error",
                                  );
                                  return const SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 30,
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            title: Text(
                              product["description"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Location: ${product["location"]}"),
                                Text(
                                  "Price per kg: \$${double.tryParse(product["price_per_kg"]?.toString() ?? "0")?.toStringAsFixed(2) ?? "0.00"}",
                                ),
                                Text(
                                  "Weight: ${double.tryParse(product["weight"]?.toString() ?? "0")?.toStringAsFixed(2) ?? "0.00"} kg",
                                ),
                                Text(
                                  "Total Amount: \$${(double.tryParse(product["price_per_kg"]?.toString() ?? "0")! * double.tryParse(product["weight"]?.toString() ?? "0")!).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              // Safely get status or default to 'pending', then uppercase
                              (product["status"] ?? 'pending')
                                  .toString()
                                  .toUpperCase(),

                              style: TextStyle(
                                // Use lowercase for comparison or compare uppercase consistently
                                color:
                                    (product["status"] ?? '')
                                                .toString()
                                                .toLowerCase() ==
                                            'accepted'
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Total Wallet Balance: \$${totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: totalAmount > 0 ? cashOut : null,
                          child: const Text("Cash Out"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
