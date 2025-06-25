import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'edit_user_page.dart';
import 'add_user_page.dart';
import 'base_page.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List users = [];
  List filteredUsers = [];
  int currentPage = 0;
  final int usersPerPage = 5;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    var url = Uri.parse("https://test.zuasoko.com/users/users");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body);
          applySearch();
        });
      } else {
        showSnackbar("Failed to load users: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      showSnackbar("Error fetching users: $e");
      debugPrint('StackTrace: $stackTrace');
    }
  }

  void applySearch() {
    setState(() {
      filteredUsers =
          users.where((user) {
            final name = user['username'].toString().toLowerCase();
            final email = user['user_email'].toString().toLowerCase();
            return name.contains(searchQuery.toLowerCase()) ||
                email.contains(searchQuery.toLowerCase());
          }).toList();
      currentPage = 0; // Reset to first page on new search
    });
  }

  Future<void> deleteUser(int userId) async {
    var url = Uri.parse("https://test.zuasoko.com/users/delete/$userId");
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        showSnackbar("User deleted successfully");
        fetchUsers();
      } else {
        showSnackbar(
          "Error deleting user: ${response.statusCode} ${response.reasonPhrase}",
        );
      }
    } catch (e, stackTrace) {
      showSnackbar("Network error: $e");
      debugPrint('StackTrace: $stackTrace');
    }
  }

  Future<void> confirmDelete(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this user?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      deleteUser(userId);
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
    ).then((value) => fetchUsers());
  }

  void navigateToAddUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUserPage()),
    ).then((value) => fetchUsers());
  }

  List get paginatedUsers {
    int start = currentPage * usersPerPage;
    int end = start + usersPerPage;
    return filteredUsers.sublist(
      start,
      end > filteredUsers.length ? filteredUsers.length : end,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "User Management",
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                searchQuery = value;
                applySearch();
              },
            ),
          ),
          Expanded(
            child:
                filteredUsers.isEmpty
                    ? const Center(child: Text("No users found"))
                    : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: paginatedUsers.length,
                      itemBuilder: (context, index) {
                        var user = paginatedUsers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(user['username']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Email: ${user['user_email']}"),
                                Text("Phone: ${user['phone']}"),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.green,
                                  ),
                                  onPressed: () => navigateToEditPage(user),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => confirmDelete(user['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          if (filteredUsers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed:
                        currentPage > 0
                            ? () => setState(() => currentPage--)
                            : null,
                    child: const Text("Previous"),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Page ${currentPage + 1} of ${((filteredUsers.length - 1) / usersPerPage + 1).floor()}",
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed:
                        (currentPage + 1) * usersPerPage < filteredUsers.length
                            ? () => setState(() => currentPage++)
                            : null,
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: FloatingActionButton(
                onPressed: navigateToAddUser,
                backgroundColor: Colors.green,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
