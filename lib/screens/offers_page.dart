import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OffersPage extends StatefulWidget {
  final String userId;
  final String username;

  const OffersPage({super.key, required this.userId, required this.username});

  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  List<dynamic> offers = [];

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    final response = await http.get(
      Uri.parse('https://flutter.zuasoko.com/get_available_offers.php'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          offers = data['offers'];
        });
      }
    }
  }

  Future<void> acceptOffer(String productId) async {
    final response = await http.post(
      Uri.parse('https://flutter.zuasoko.com/accept_offer.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"user_id": widget.userId, "product_id": productId}),
    );

    final data = json.decode(response.body);
    if (data['success']) {
      setState(() {
        offers.removeWhere((offer) => offer['id'] == productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer accepted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Offers')),
      body: offers.isEmpty
          ? const Center(child: Text('No available offers'))
          : ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: offer['image'] != null
                        ? Image.network(
                            'https://flutter.zuasoko.com/${offer['image']}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image),
                    title: Text(offer['description']),
                    subtitle: Text(
                        'Location: ${offer['location']}\nPrice: ${offer['price_per_kg']} per kg\nWeight: ${offer['weight']} kg'),
                    trailing: ElevatedButton(
                      onPressed: () => acceptOffer(offer['id'].toString()),
                      child: const Text('Accept'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
