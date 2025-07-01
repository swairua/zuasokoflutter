import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_details_page.dart';
import 'base_page.dart';

class CustomerDashboardPage extends StatefulWidget {
  final String userId;
  final String username;

  const CustomerDashboardPage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  List<Map<String, dynamic>> products = [];
  int cartQuantity = 0;
  int currentPage = 1;
  bool isLoadingMore = false;
  bool allLoaded = false;
  final ScrollController _scrollController = ScrollController();
  final String imageBaseUrl = "https://test.zuasoko.com/product_images/";

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCartQuantity();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && !isLoadingMore && !allLoaded) {
        fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoadingMore = true);
    try {
      final response = await http.get(
        Uri.parse('https://test.zuasoko.com/sellable-items?page=$currentPage'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          setState(() => allLoaded = true);
        } else {
          setState(() {
            products.addAll(data.map((item) => Map<String, dynamic>.from(item)));
            currentPage++;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
    setState(() => isLoadingMore = false);
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
          cartQuantity = int.tryParse(data['cart_quantity'].toString()) ?? cartQuantity;
        });
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  Drawer buildDrawer() {
    return Drawer(
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
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartDetailsPage(
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
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Marketplace',
      drawer: buildDrawer(),
      child: Stack(
        children: [
          products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = (constraints.maxWidth ~/ 180).clamp(2, 6);
                    return GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: products.length + (isLoadingMore ? 1 : 0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        if (index >= products.length) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        var product = products[index];
                        String? imageName = product['image'];
                        String imageUrl = (imageName != null && imageName.isNotEmpty)
                            ? (imageName.startsWith('http') ? imageName : "$imageBaseUrl$imageName")
                            : "";

                        String title = product['name'] ?? 'No name';
                        String description = product['description'] ?? 'No description';
                        String price = product['retail_price']?.toString() ?? '0.00';
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
                                flex: 5,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                        ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        description,
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "\$$price",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
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
                    builder: (context) => CartDetailsPage(
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
