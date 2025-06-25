import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'base_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String selectedCategory = 'Farmer';
  Uint8List? _imageBytes;
  bool isLoading = false;

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> register() async {
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
      r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
    ).hasMatch(emailController.text.trim())) {
      showSnackbar("❌ Invalid email format!");
      return;
    }

    if (!RegExp(r"^0[0-9]{9}$").hasMatch(phoneController.text.trim())) {
      showSnackbar("❌ Invalid phone number! Use format: 0712345678");
      return;
    }

    String formattedPhone = "254${phoneController.text.trim().substring(1)}";

    setState(() => isLoading = true);

    var url = Uri.parse("https://test.zuasoko.com/routes/users/add");
    var request = http.MultipartRequest("POST", url);

    request.fields['username'] = usernameController.text.trim();
    request.fields['first_name'] = firstNameController.text.trim();
    request.fields['last_name'] = lastNameController.text.trim();
    request.fields['user_email'] = emailController.text.trim();
    request.fields['phone'] = formattedPhone;
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
      final data = jsonDecode(responseData);

      setState(() => isLoading = false);

      if (data['status'] == 'success') {
        showSnackbar("✅ Registration successful!");
        Navigator.pop(context);
      } else {
        showSnackbar("❌ ${data['message']}");
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
      title: 'Register',
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: "Username"),
                    ),
                    TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: "First Name",
                      ),
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
                      decoration: const InputDecoration(
                        labelText: "Phone (e.g. 0712345678)",
                      ),
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
                          ['Farmer', 'Driver', 'Customer']
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => selectedCategory = value!),
                      decoration: const InputDecoration(labelText: "Category"),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Camera"),
                          onPressed: () => pickImage(ImageSource.camera),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo),
                          label: const Text("Gallery"),
                          onPressed: () => pickImage(ImageSource.gallery),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_imageBytes != null)
                      Image.memory(_imageBytes!, height: 100, width: 100),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: register,
                      child: const Text("Register"),
                    ),
                  ],
                ),
              ),
    );
  }
}
