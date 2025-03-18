import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

class CartDetailsPage extends StatefulWidget {
  final String userId;
  final String username;

  const CartDetailsPage({super.key, required this.userId, required this.username});

  @override
  CartDetailsPageState createState() => CartDetailsPageState();
}

class CartDetailsPageState extends State<CartDetailsPage> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      final response = await http.post(
        Uri.parse('https://flutter.zuasoko.com/display_cart_items.php'),
        body: {'user_id': widget.userId},
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is List) {
          setState(() {
            cartItems = data.map((item) => Map<String, dynamic>.from(item)).toList();
            totalAmount = cartItems.fold(0.0, (sum, item) => 
              sum + (double.tryParse(item['price'].toString()) ?? 0) * (int.tryParse(item['quantity'].toString()) ?? 0)
            );
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        debugPrint('Failed to fetch cart items. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching cart items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> confirmOrder() async {
    if (cartItems.isEmpty) return;

    String orderId = const Uuid().v4(); // Generate a unique order ID

    List<Map<String, dynamic>> orderProducts = cartItems.map((item) {
      return {
        'order_id': orderId,
        'product_id': item['product_id'],
        'user_id': widget.userId,
        'total_amount': (double.tryParse(item['price'].toString()) ?? 0) * (int.tryParse(item['quantity'].toString()) ?? 0),
        'order_status': 'confirmed'
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('https://flutter.zuasoko.com/save_confirmed_orders.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderProducts),
      );

      final responseData = json.decode(response.body);

      if (responseData['success']) {
        debugPrint('Order confirmed successfully.');
      } else {
        debugPrint('Failed to confirm order: ${responseData['message']}');
      }
    } catch (e) {
      debugPrint('Error confirming order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart Details')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty.", style: TextStyle(fontSize: 16)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            var item = cartItems[index];
                            return ListTile(
                              leading: item['image'] != null
                                  ? Image.network(
                                      "https://flutter.zuasoko.com/${item['image']}",
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                                    )
                                  : const Icon(Icons.image),
                              title: Text(item['description']),
                              subtitle: Text("Quantity: ${item['quantity']}"),
                              trailing: Text(
                                "\$${(double.tryParse(item['price'].toString()) ?? 0 * (int.tryParse(item['quantity'].toString()) ?? 0)).toStringAsFixed(2)}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Total: \$${totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: confirmOrder,
                        child: const Text('Confirm Order'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
