import 'dart:convert'; // ✅ Required for jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'base_page.dart';

class EditUserPage extends StatefulWidget {
  final Map user;

  const EditUserPage({super.key, required this.user});

  @override
  EditUserPageState createState() => EditUserPageState();
}

class EditUserPageState extends State<EditUserPage> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.user['username']);
    emailController = TextEditingController(text: widget.user['user_email']);
    phoneController = TextEditingController(text: widget.user['phone']);
  }

  Future<void> updateUser() async {
    var url = Uri.parse("https://test.zuasoko.com/users/edit");
    var body = {
      'id': widget.user['id'].toString(),
      'username': usernameController.text,
      'user_email': emailController.text,
      'phone': phoneController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body), // ✅ Encode the body as JSON
      );

      if (!mounted) return;

      if (response.body.contains('success')) {
        Navigator.pop(context, true);
      } else {
        showSnackbar("Error updating user");
      }
    } catch (e) {
      if (!mounted) return;
      showSnackbar("Network error");
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
      title: "Edit User",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "User Email"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUser,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Update User"),
            ),
          ],
        ),
      ),
    );
  }
}
