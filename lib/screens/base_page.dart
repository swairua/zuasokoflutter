import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? drawer; // Add drawer as an optional parameter

  const BasePage({
    super.key,
    required this.title,
    required this.child,
    this.drawer,  // Include drawer here
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green, // Green AppBar
      ),
      drawer: drawer,  // Pass drawer to Scaffold.drawer
      body: Container(
        color: Colors.green[50], // Light green background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo at the top
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/icon/app_icon.png', // Your logo asset
                width: 100, // Adjust size
                height: 100,
              ),
            ),
            // Page content below the logo
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
