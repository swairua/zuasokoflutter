import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // Import for handling image bytes
import 'package:image_picker/image_picker.dart';
import 'base_page.dart'; // Import your BasePage widget

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String selectedCategory = 'Farmer'; // Default value
  Uint8List? _imageBytes;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> addUser() async {
    if (usernameController.text.trim().isEmpty ||
        firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showSnackbar("❌ Please fill in all fields!");
      return;
    }

    if (!RegExp(
      r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+",
    ).hasMatch(emailController.text.trim())) {
      showSnackbar("❌ Invalid email format!");
      return;
    }

    if (!RegExp(r"^\d{10,15}$").hasMatch(phoneController.text.trim())) {
      showSnackbar("❌ Invalid phone number!");
      return;
    }

    setState(() => isLoading = true);
    var url = Uri.parse("https://test.zuasoko.com/users/add");
    var request = http.MultipartRequest("POST", url);

    request.fields['username'] = usernameController.text.trim();
    request.fields['first_name'] = firstNameController.text.trim();
    request.fields['last_name'] = lastNameController.text.trim();
    request.fields['email'] = emailController.text.trim();
    request.fields['phone'] = phoneController.text.trim();
    request.fields['password'] = passwordController.text.trim();
    request.fields['category'] = selectedCategory;

    if (_imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'user_image',
          _imageBytes!,
          filename: 'profile.jpg',
        ),
      );
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        setState(() => isLoading = false);
        showSnackbar("❌ Server error (${response.statusCode})");
        return;
      }

      try {
        Map<String, dynamic> data = jsonDecode(responseData);
        setState(() => isLoading = false);

        if (data.containsKey('success') && data['success'] == true) {
          showSnackbar("✅ User added successfully!");
          Navigator.pop(context, true);
        } else {
          showSnackbar(
            "❌ ${data.containsKey('error') ? data['error'] : 'Unknown server error'}",
          );
        }
      } catch (e) {
        setState(() => isLoading = false);
        showSnackbar("❌ Error parsing response: $responseData");
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
      title: "Add User", // Set the title for the app bar
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // <-- Added this to enable scrolling
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Form Fields
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: "First Name"),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: "Last Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items:
                    ['Farmer', 'Admin', 'Customer'].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
                decoration: const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera),
                    label: const Text("Camera"),
                    onPressed: () => pickImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Gallery"),
                    onPressed: () => pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _imageBytes != null
                  ? Image.memory(
                    _imageBytes!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  )
                  : const Text("No image selected"),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: addUser,
                    child: const Text("Add User"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
