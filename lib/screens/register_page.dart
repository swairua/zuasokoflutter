import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // Import for handling image bytes
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController(); // Added phone
  TextEditingController passwordController = TextEditingController();
  String selectedCategory = 'Farmer';
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

  Future<void> register() async {
    if (usernameController.text.trim().isEmpty ||
        firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty || // Validate phone
        passwordController.text.trim().isEmpty) {
      showSnackbar("❌ Please fill in all fields!");
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
        .hasMatch(emailController.text.trim())) {
      showSnackbar("❌ Invalid email format!");
      return;
    }

    if (!RegExp(r"^0[0-9]{9}$").hasMatch(phoneController.text.trim())) {
      showSnackbar("❌ Invalid phone number! Use format: 0712345678");
      return;
    }

    // Format phone number (replace leading 0 with 254)
    String formattedPhone = "254${phoneController.text.trim().substring(1)}";

    setState(() => isLoading = true);
    var url = Uri.parse("https://flutter.zuasoko.com/flutterregister.php");
    var request = http.MultipartRequest("POST", url);

    request.fields['username'] = usernameController.text.trim();
    request.fields['first_name'] = firstNameController.text.trim();
    request.fields['last_name'] = lastNameController.text.trim();
    request.fields['user_email'] = emailController.text.trim();
    request.fields['phone'] = formattedPhone; // Send formatted phone
    request.fields['password'] = passwordController.text.trim();
    request.fields['category'] = selectedCategory;

    if (_imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'user_image',
        _imageBytes!,
        filename: 'profile.jpg',
      ));
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      Map<String, dynamic> data = jsonDecode(responseData);

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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              decoration: const InputDecoration(labelText: "Phone (e.g. 0712345678)"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: ['Farmer', 'Driver', 'Customer'].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedCategory = value!),
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
                    onPressed: register,
                    child: const Text("Register"),
                  ),
          ],
        ),
      ),
    );
  }
}
