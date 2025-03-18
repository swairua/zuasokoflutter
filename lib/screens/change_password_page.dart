import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> changePassword() async {
    setState(() => isLoading = true);

    var url = Uri.parse("https://flutter.zuasoko.com/change_password.php");
    var body = {
      'username': usernameController.text.trim(),
      'old_password': oldPasswordController.text.trim(),
      'new_password': newPasswordController.text.trim(),
    };

    try {
      final response = await http.post(url, body: body);
      Map<String, dynamic> data = jsonDecode(response.body);

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
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
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
