import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_page.dart'; // Import the BasePage widget

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> changePassword() async {
    if (usernameController.text.trim().isEmpty ||
        oldPasswordController.text.trim().isEmpty ||
        newPasswordController.text.trim().isEmpty) {
      showSnackbar("❌ Please fill in all fields!");
      return;
    }

    setState(() => isLoading = true);

    var url = Uri.parse("https://test.zuasoko.com/change-password");
    var body = {
      'username': usernameController.text.trim(),
      'old_password': oldPasswordController.text.trim(),
      'new_password': newPasswordController.text.trim(),
    };

    try {
      final response = await http.post(url, body: body);
      final Map<String, dynamic> data = jsonDecode(response.body);

      setState(() => isLoading = false);
      showSnackbar(data['message']);

      if (data['status'] == 'success') {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isLoading = false);
      showSnackbar("❌ Network error, please try again");
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Change Password",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(labelText: "Old Password"),
              obscureText: true,
            ),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: "New Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: changePassword,
                  child: const Text("Change Password"),
                ),
          ],
        ),
      ),
    );
  }
}
