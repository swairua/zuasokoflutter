import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditUserPage extends StatefulWidget {
  final Map user;
  const EditUserPage({super.key, required this.user});

  @override
  EditUserPageState createState() => EditUserPageState();
}

class EditUserPageState extends State<EditUserPage> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController; // Added phone field

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.user['username']);
    emailController = TextEditingController(text: widget.user['user_email']);
    phoneController = TextEditingController(text: widget.user['phone']); // Added
  }

  Future<void> updateUser() async {
    var url = Uri.parse("https://flutter.zuasoko.com/edit_user.php");
    var body = {
      'id': widget.user['id'].toString(),
      'username': usernameController.text,
      'user_email': emailController.text,
      'phone': phoneController.text, // Added
    };

    try {
      final response = await http.post(url, body: body);
      if (!mounted) return; // Ensures context is safe to use

      if (response.body.contains('success')) {
        Navigator.pop(context, true); // Refresh list on success
      } else {
        showSnackbar("Error updating user");
      }
    } catch (e) {
      if (!mounted) return; // Ensures context is safe
      showSnackbar("Network error");
    }
  }

  void showSnackbar(String message) {
    if (!mounted) return; // Prevent context issues
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit User")),
      body: Padding(
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
              decoration: const InputDecoration(labelText: "Phone Number"), // Added
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUser,
              child: const Text("Update User"),
            ),
          ],
        ),
      ),
    );
  }
}
