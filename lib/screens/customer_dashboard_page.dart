import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_details_page.dart';

class CustomerDashboardPage extends StatefulWidget {
  final String userId;
  final String username;

  const CustomerDashboardPage({super.key, required this.userId, required this.username});

  @override
  _CustomerDashboardPageState createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  List<Map<String, dynamic>> products = [];
  int cartQuantity = 0;
  final String imageBaseUrl = "https://flutter.zuasoko.com/";

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCartQuantity();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://flutter.zuasoko.com/sellable_items.php'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          products = data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
  }

  Future<void> fetchCartQuantity() async {
    try {
      final response = await http.post(
        Uri.parse('https://flutter.zuasoko.com/cart_quantity.php'),
        body: {'user_id': widget.userId},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Ensure cart quantity is parsed as an integer
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
        Uri.parse('https://flutter.zuasoko.com/add_to_cart.php'),
        body: {'user_id': widget.userId, 'product_id': productId},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Ensure cart quantity is parsed as an integer
          cartQuantity = int.tryParse(data['cart_quantity'].toString()) ?? cartQuantity;
        });
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online Shopping')),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];

                // Construct full image URL safely
                String? imageName = product['image'];
                String imageUrl = (imageName != null && imageName.isNotEmpty)
                    ? "$imageBaseUrl$imageName"
                    : "";

                String description = product['description'] ?? 'No description';
                String price = product['retail_price']?.toString() ?? '0.00';
                String productId = product['id']?.toString() ?? '0';

                return Card(
                  child: ListTile(
                    leading: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(width: 50, height: 50), // No placeholder, just empty space
                    title: Text(description),
                    subtitle: Text("\$$price"),
                    trailing: ElevatedButton(
                      onPressed: () => addToCart(productId),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('View Cart ($cartQuantity)'),
        icon: const Icon(Icons.shopping_cart),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartDetailsPage(userId: widget.userId, username: widget.username),
            ),
          );
        },
      ),
    );
  }
}
