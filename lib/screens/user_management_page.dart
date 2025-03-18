import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_user_page.dart';
import 'add_user_page.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    var url = Uri.parse("https://flutter.zuasoko.com/get_users.php");
    try {
      final response = await http.get(url);
      setState(() {
        users = jsonDecode(response.body);
      });
    } catch (e) {
      showSnackbar("Error fetching users");
    }
  }

  Future<void> deleteUser(int userId) async {
    var url = Uri.parse("https://flutter.zuasoko.com/delete_user.php");
    try {
      final response = await http.post(url, body: {'id': userId.toString()});
      if (response.body.contains('success')) {
        showSnackbar("User deleted successfully");
        fetchUsers(); // Refresh list
      } else {
        showSnackbar("Error deleting user");
      }
    } catch (e) {
      showSnackbar("Network error");
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void navigateToEditPage(Map user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditUserPage(user: user)),
    ).then((value) => fetchUsers()); // Refresh after edit
  }

  void navigateToAddUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUserPage()),
    ).then((value) => fetchUsers()); // Refresh after adding
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return Card(
                  child: ListTile(
                    title: Text(user['username']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${user['user_email']}"),
                        Text("Phone: ${user['phone']}"), // Added phone number
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => navigateToEditPage(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteUser(user['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddUser,
        child: const Icon(Icons.add),
      ),
    );
  }
}
