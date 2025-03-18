import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import 'change_password_page.dart';
import 'farmer_dashboard_page.dart';
import 'driver_dashboard_page.dart';
import 'customer_dashboard_page.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    print("🟡 Debug: Login button pressed");

    var url = Uri.parse("https://flutter.zuasoko.com/flutterlogin.php");
    var body = {
      'username': usernameController.text.trim(),
      'password': passwordController.text.trim(),
    };

    try {
      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => isLoading = false);

        if (data['status'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('userId', data['userId'].toString());
          prefs.setString('username', data['username']);
          prefs.setString('category', data['category']);

          String userId = data['userId'].toString();
          String username = data['username'];
          String category = data['category'];

          print("✅ Debug: Login success - userId: $userId, username: $username, category: $category");

          if (!mounted) return;

          // Navigate based on user category
          switch (category) {
            case 'farmer':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FarmerDashboardPage(userId: userId, username: username)),
              );
              break;
            case 'driver':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DriverDashboardPage(userId: userId, username: username)),
              );
              break;
            case 'admin':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage(userId: userId, username: username)),
              );
              break;
            case 'customer':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CustomerDashboardPage(userId: userId, username: username)),
              );
              break;
            default:
              Navigator.pushReplacementNamed(context, '/dashboard_page');
          }
        } else {
          showSnackbar(data['message'] ?? "Invalid login credentials.");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      showSnackbar("❌ Network error, please try again.");
    }
  }

  void showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: const Text("Login"),
                  ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              ),
              child: const Text("Register"),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
              ),
              child: const Text("Change Password"),
            ),
          ],
        ),
      ),
    );
  }
}
