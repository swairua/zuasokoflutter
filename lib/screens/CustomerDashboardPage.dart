import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_details_page.dart';

class CustomerDashboardPage extends StatefulWidget {
  final String userId;
  final String username;

  const CustomerDashboardPage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  CustomerDashboardPageState createState() => CustomerDashboardPageState();
}

class CustomerDashboardPageState extends State<CustomerDashboardPage> {
  List<Map<String, dynamic>> products = [];
  int cartQuantity = 0;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCartQuantity();
  }

  /// Fetch available products
  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://test.zuasoko.com/sellable_item'),
      );
      if (response.statusCode == 200) {
        setState(() {
          products = List<Map<String, dynamic>>.from(
            json.decode(response.body),
          );
        });
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }
  }

  /// Fetch cart quantity
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
      debugPrint("Error fetching cart quantity: $e");
    }
  }

  /// Show quantity input dialog
  void promptQuantityInput(String productId) {
    TextEditingController quantityController = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Quantity"),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter quantity"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Add to Cart"),
              onPressed: () {
                int quantity = int.tryParse(quantityController.text) ?? 1;
                Navigator.pop(context);
                addToCart(productId, quantity);
              },
            ),
          ],
        );
      },
    );
  }

  /// Add item to cart
  Future<void> addToCart(String productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('https://test.zuasoko.com/add_to_cart'),
        body: {
          'user_id': widget.userId,
          'product_id': productId,
          'quantity': quantity.toString(),
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          fetchCartQuantity();
        }
      }
    } catch (e) {
      debugPrint("Error adding to cart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.username),
              accountEmail: Text('User ID: ${widget.userId}'),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('My Cart'),
              onTap: () {
                Navigator.pop(context); // Close drawer
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
        ),
      ),
      body:
          products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  var product = products[index];
                  String productId = product['id'].toString();

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: Image.network(
                                product['image'],
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/placeholder.png', // Make sure you add this to pubspec.yaml
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  );
                                },
                              )
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                product['description'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "\$${product['retail_price']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: () => promptQuantityInput(productId),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Colors.blueAccent,
                                ),
                                child: const Text('Add to Cart'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('View Cart ($cartQuantity)'),
        icon: const Icon(Icons.shopping_cart),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CartDetailsPage(
                    userId: widget.userId,
                    username: widget.username,
                  ),
            ),
          );
          fetchCartQuantity(); // Refresh cart quantity
        },
      ),
    );
  }
}
