import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_details_page.dart';
import 'base_page.dart'; // <-- Make sure this is imported

class CustomerDashboardPage extends StatefulWidget {
  final String userId;
  final String username;

  const CustomerDashboardPage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  _CustomerDashboardPageState createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  List<Map<String, dynamic>> products = [];
  int cartQuantity = 0;
  final String imageBaseUrl = "https://test.zuasoko.com/product_images/";

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCartQuantity();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://test.zuasoko.com/sellable-items'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          products =
              data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
  }

  Future<void> fetchCartQuantity() async {
    try {
      final response = await http.post(
        Uri.parse('https://test.zuasoko.com/cart_quantity'),
        body: {'user_id': widget.userId},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cartQuantity = int.tryParse(data['cart_quantity'].toString()) ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching cart quantity: $e');
    }
  }

  Future<void> addToCart(String productId) async {
    try {
      final response = await http.post(
        Uri.parse('https://test.zuasoko.com/add_to_cart'),
        body: {'user_id': widget.userId, 'product_id': productId},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cartQuantity =
              int.tryParse(data['cart_quantity'].toString()) ?? cartQuantity;
        });
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Marketplace',
      child: Stack(
        children: [
          products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = (constraints.maxWidth ~/ 180).clamp(
                    2,
                    4,
                  );
                  return GridView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 80.0,
                    ), // leave space for FAB
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      var product = products[index];

                      String? imageName = product['image'];
                      String imageUrl =
                          (imageName != null && imageName.isNotEmpty)
                              ? "$imageBaseUrl$imageName"
                              : "";

                      String description =
                          product['description'] ?? 'No description';
                      String price =
                          product['retail_price']?.toString() ?? '0.00';
                      String productId = product['id']?.toString() ?? '0';
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 2,
                              child:
                                  imageUrl.isNotEmpty
                                      ? ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      description,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "\$$price",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => addToCart(productId),
                                        child: const Text('Add to Cart'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              label: Text('View Cart ($cartQuantity)'),
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CartDetailsPage(
                          userId: widget.userId,
                          username: widget.username,
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
