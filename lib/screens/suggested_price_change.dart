import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_page.dart';

class SuggestedPriceChangePage extends StatefulWidget {
  final String userId;
  final Widget? drawer;

  const SuggestedPriceChangePage({super.key, required this.userId, this.drawer});

  @override
  State<SuggestedPriceChangePage> createState() => _SuggestedPriceChangePageState();
}

class _SuggestedPriceChangePageState extends State<SuggestedPriceChangePage> {
  List<dynamic> suggestions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSuggestions();
  }

  Future<void> fetchSuggestions() async {
    final url = Uri.parse("https://test.zuasoko.com/get_suggested_prices?user_id=${widget.userId}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          suggestions = data['suggestions'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load suggestions");
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> respondToSuggestion(String action, int productId) async {
    final url = Uri.parse("https://test.zuasoko.com/respond_to_price_suggestion");
    try {
      final response = await http.post(url, body: {
        'action': action,
        'product_id': productId.toString(),
        'user_id': widget.userId,
      });

      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Response sent')),
      );

      // Refresh after action
      fetchSuggestions();
    } catch (e) {
      print("Failed to respond to suggestion: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending response")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Suggested Price Changes",
      drawer: widget.drawer,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : suggestions.isEmpty
              ? const Center(child: Text("No suggested price changes found"))
              : ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final item = suggestions[index];
                    final isPending = (item['status'] ?? '').toLowerCase() == 'pending';

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['description'] ?? 'No description',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("Current Price: Ksh ${item['price_per_kg']}"),
                            Text("Suggested Price: Ksh ${item['log_suggested_price']}"),
                            Text("Status: ${item['status'] ?? 'N/A'}"),
                            Text("Suggested by: ${item['suggested_by'] ?? 'System'}"),
                            const SizedBox(height: 10),
                            if (isPending)
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => respondToSuggestion("accept", item['product_id']),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    child: const Text("Accept"),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => respondToSuggestion("decline", item['product_id']),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text("Decline"),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
