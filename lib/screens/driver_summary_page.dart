import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverSummaryPage extends StatefulWidget {
  final String userId;
  final String username;

  const DriverSummaryPage({super.key, required this.userId, required this.username});

  @override
  _DriverSummaryPageState createState() => _DriverSummaryPageState();
}

class _DriverSummaryPageState extends State<DriverSummaryPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDriverProducts();
  }

  Future<void> fetchDriverProducts() async {
    try {
      final response = await http.post(
        Uri.parse('https://flutter.zuasoko.com/get_driver_products.php'),
        body: {'driver_id': widget.userId},
      );

      debugPrint('Raw response: ${response.body}'); // Debugging

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is Map && data.containsKey('products')) {
          setState(() {
            products = List<Map<String, dynamic>>.from(data['products']);
            isLoading = false;
          });
        } else {
          debugPrint('Unexpected response format: $data');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        debugPrint('Failed to fetch products. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Summary')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("No assigned products.", style: TextStyle(fontSize: 16)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];

                      // Construct image URL
                      String imageUrl = "https://flutter.zuasoko.com/${product['image']}";
                      
                      // Print the image URL for debugging
                      debugPrint('Product Image Path: $imageUrl');

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: product['image'] != null && product['image'].toString().isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Error loading image: $imageUrl');
                                    return const Icon(Icons.image_not_supported);
                                  },
                                )
                              : const Icon(Icons.image),
                          title: Text(product['description'] ?? 'No description'),
                          subtitle: Text(
                            "Location: ${product['location'] ?? 'Unknown'}\n"
                            "Weight: ${product['weight'] ?? '0'} kg\n"
                            "Price per kg: \$${product['price_per_kg'] ?? '0.00'}",
                          ),
                          trailing: Text(
                            "\$${((double.tryParse(product['weight'].toString()) ?? 0.0) * (double.tryParse(product['price_per_kg'].toString()) ?? 0.0)).toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
