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
import 'base_page.dart'; // Import the BasePage widget

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

    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();

    print(
      "📦 Debug: Username: $username, Password: ${password.isNotEmpty ? '***' : '[EMPTY]'}",
    );

    var url = Uri.parse("https://test.zuasoko.com/login");
    var body = {'username': username, 'password': password};
    var headers = {"Content-Type": "application/json"};

    print("🌐 Sending POST to $url with headers $headers and body $body");

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Raw response body: ${response.body}");

      if (response.statusCode == 200) {
        dynamic data;

        try {
          data = jsonDecode(response.body);
        } catch (e) {
          print("❌ JSON decode error: $e");
          setState(() => isLoading = false);
          showSnackbar("Server returned invalid response format.");
          return;
        }

        print("✅ Parsed JSON: $data");

        setState(() => isLoading = false);

        if (data['status'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('userId', data['userId'].toString());
          prefs.setString('username', data['username']);
          prefs.setString('category', data['category']);

          print("🔐 Login successful. Saving user session.");
          print(
            "🧑‍💼 ID: ${data['userId']}, Username: ${data['username']}, Role: ${data['category']}",
          );

          if (!mounted) return;

          switch (data['category']) {
            case 'farmer':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => FarmerDashboardPage(
                        userId: data['userId'].toString(),
                        username: data['username'],
                      ),
                ),
              );
              break;
            case 'driver':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DriverDashboardPage(
                        userId: data['userId'].toString(),
                        username: data['username'],
                      ),
                ),
              );
              break;
            case 'admin':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DashboardPage(
                        userId: data['userId'].toString(),
                        username: data['username'],
                      ),
                ),
              );
              break;
            case 'customer':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CustomerDashboardPage(
                        userId: data['userId'].toString(),
                        username: data['username'],
                      ),
                ),
              );
              break;
            default:
              print("⚠️ Unknown role: ${data['category']}");
              Navigator.pushReplacementNamed(context, '/dashboard_page');
          }
        } else {
          print("🚫 Login failed. Message: ${data['message']}");
          showSnackbar(data['message'] ?? "Invalid login credentials.");
        }
      } else {
        setState(() => isLoading = false);
        print("❌ Server error: ${response.statusCode}");
        showSnackbar("Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Network error during login: $e");
      showSnackbar("❌ Network error: $e");
    }
  }

  void showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Login", // Set the title for the app bar
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo is added by the BasePage widget
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
                : ElevatedButton(onPressed: login, child: const Text("Login")),
            const SizedBox(height: 10),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  ),
              child: const Text("Register"),
            ),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordPage(),
                    ),
                  ),
              child: const Text("Change Password"),
            ),
          ],
        ),
      ),
    );
  }
}
