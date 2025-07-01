import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'user_management_page.dart';
import 'farmer_dashboard_page.dart';
import 'offers_page.dart';
import 'AllProductsPage.dart';
import 'base_page.dart';

class DashboardPage extends StatefulWidget {
  final String userId;
  final String username;

  const DashboardPage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  late String username;
  late String userId;

  String? prefsUserId;
  String? prefsUsername;

  @override
  void initState() {
    super.initState();
    username = widget.username;
    userId = widget.userId;

    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedUserId = prefs.getString('userId');

    setState(() {
      prefsUserId = savedUserId;
      prefsUsername = savedUsername;

      if (savedUserId != null && savedUserId.isNotEmpty) userId = savedUserId;
      if (savedUsername != null && savedUsername.isNotEmpty) username = savedUsername;
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logout();
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget debugPanel() {
    return Container(
      width: double.infinity,
      color: Colors.yellow.shade200,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DEBUG INFO:",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 4),
          Text("Passed userId: '${widget.userId}'"),
          Text("Passed username: '${widget.username}'"),
          Text("Loaded from SharedPreferences userId: '${prefsUserId ?? 'null'}'"),
          Text("Loaded from SharedPreferences username: '${prefsUsername ?? 'null'}'"),
          const SizedBox(height: 6),
          Text(
            userId.isEmpty
                ? "⚠️ Current userId is EMPTY or NULL!"
                : "✅ Current userId: '$userId'",
            style: TextStyle(
                color: userId.isEmpty ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget drawerMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.green),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Menu",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Welcome, $username!",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  "User ID: $userId",
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Users'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserManagementPage()),
              );
            },
          ),
          
         ListTile(
            leading: const Icon(Icons.agriculture),
            title: const Text('Farmer Offers'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OffersPage(
                    userId: userId,
                    username: username,
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.agriculture),
            title: const Text('All Products'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllProductsPage(),
                ),
              );
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: confirmLogout,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Dashboard",
      drawer: drawerMenu(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // debugPanel(),
            const SizedBox(height: 20),
            Text(
              "Welcome, $username!",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "User ID: $userId",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: confirmLogout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
