import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'base_page.dart';

class OffersPage extends StatefulWidget {
  final String userId;
  final String username;

  const OffersPage({super.key, required this.userId, required this.username});

  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  List<dynamic> offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    try {
      final response = await http.get(
        Uri.parse('https://test.zuasoko.com/available_offers'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            offers = data['offers'];
            isLoading = false;
          });
        } else {
          debugPrint('API returned success: false');
          setState(() => isLoading = false);
        }
      } else {
        debugPrint('Failed to fetch offers: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching offers: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> acceptOffer(String productId) async {
    try {
      final response = await http.post(
        Uri.parse('https://test.zuasoko.com/accept_offer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"user_id": widget.userId, "product_id": productId}),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          offers.removeWhere((offer) => offer['id'].toString() == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer accepted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to accept offer')),
        );
      }
    } catch (e) {
      debugPrint('Error accepting offer: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('An error occurred')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Available Offers',
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : offers.isEmpty
              ? const Center(child: Text('No available offers'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Back to Dashboard"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          final String? imageUrl =
                              offer['image'] != null
                                  ? 'https://test.zuasoko.com/${offer['image']}'
                                  : null;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            child: ListTile(
                              leading:
                                  imageUrl != null
                                      ? Image.network(
                                        imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons.broken_image,
                                            size: 50,
                                          );
                                          // Alternatively, use a placeholder image:
                                          // return Image.asset(
                                          //   'assets/images/placeholder.png',
                                          //   width: 50,
                                          //   height: 50,
                                          //   fit: BoxFit.cover,
                                          // );
                                        },
                                      )
                                      : const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                      ),
                              title: Text(offer['description']),
                              subtitle: Text(
                                'Location: ${offer['location']}\n'
                                'Price: ${offer['price_per_kg']} per kg\n'
                                'Weight: ${offer['weight']} kg',
                              ),
                              isThreeLine: true,
                              trailing: ElevatedButton(
                                onPressed:
                                    () => acceptOffer(offer['id'].toString()),
                                child: const Text('Accept'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
