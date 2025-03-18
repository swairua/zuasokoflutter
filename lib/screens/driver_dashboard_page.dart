import 'package:flutter/material.dart';
import 'driver_summary_page.dart';
import 'offers_page.dart';

class DriverDashboardPage extends StatelessWidget {
  final String userId;
  final String username;

  const DriverDashboardPage({super.key, required this.userId, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Dashboard')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome, $username!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'User ID: $userId',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverSummaryPage(userId: userId, username: username),
                    ),
                  );
                },
                child: const Text('View Summary'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OffersPage(userId: userId, username: username),
                    ),
                  );
                },
                child: const Text('Check Offers'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
