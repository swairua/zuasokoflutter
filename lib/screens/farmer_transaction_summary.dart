import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class FarmerTransactionSummary extends StatefulWidget {
  final String userId; // Define userId

  const FarmerTransactionSummary({super.key, required this.userId}); // Include userId in constructor

  @override
  _FarmerTransactionSummaryState createState() => _FarmerTransactionSummaryState();
}

class _FarmerTransactionSummaryState extends State<FarmerTransactionSummary> {
  List<dynamic> products = [];
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _imagePath; // For displaying image preview

  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

 Future<void> fetchProducts() async {
  setState(() => isLoading = true);

  var url = Uri.parse("https://flutter.zuasoko.com/fetch_products.php?userId=${widget.userId}");

  try {
    final response = await http.get(url);
    print("API Response: ${response.body}");

    List<dynamic> fetchedProducts = json.decode(response.body);

    setState(() {
      products = fetchedProducts.map((product) {
        String imageUrl = product["image"] ?? "";

        // Fix double prefixing issue
        if (!imageUrl.startsWith("http")) {
          if (!imageUrl.contains("product_images/")) {
            // If no "product_images/" prefix, add it
            imageUrl = "https://flutter.zuasoko.com/product_images/$imageUrl";
          } else {
            // If it already has "product_images/", just prepend the domain
            imageUrl = "https://flutter.zuasoko.com/$imageUrl";
          }
        }

        print("Final Image URL: $imageUrl"); // Debugging

        return {
          ...product,
          "image": imageUrl, // Fixed image URL
          "price_per_kg": product["price_per_kg"].toString(),
          "weight": product["weight"].toString(),
        };
      }).toList();
      isLoading = false;
    });
  } catch (e) {
    setState(() => isLoading = false);
    showSnackbar("Failed to load products.");
  }
}


  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imagePath = pickedFile.path; // Store image path for preview
      });
    }
  }

  Future<void> addProduct() async {
    if (descriptionController.text.isEmpty ||
        locationController.text.isEmpty ||
        priceController.text.isEmpty ||
        weightController.text.isEmpty) {
      showSnackbar("All fields are required!");
      return;
    }

    var url = Uri.parse("https://flutter.zuasoko.com/add_product.php");
    var request = http.MultipartRequest("POST", url);

    request.fields['userId'] = widget.userId; // Include userId
    request.fields['description'] = descriptionController.text;
    request.fields['location'] = locationController.text;
    request.fields['price_per_kg'] = priceController.text;
    request.fields['weight'] = weightController.text;

    if (_imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image', _imageBytes!,
        filename: 'product.jpg',
      ));
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      var data = json.decode(responseData);

      if (data['success'] != null) {
        showSnackbar("Product added successfully!");
        fetchProducts(); // Refresh list
        Navigator.pop(context); // Close the bottom sheet after submission
      } else {
        showSnackbar("Error: ${data['error']}");
      }
    } catch (e) {
      showSnackbar("Network error!");
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("Take Photo"),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("Choose from Gallery"),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  void showAddProductModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the bottom sheet to resize dynamically
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0, right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0, // Adjust for keyboard
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price per kg"), keyboardType: TextInputType.number),
                TextField(controller: weightController, decoration: const InputDecoration(labelText: "Weight"), keyboardType: TextInputType.number),
                const SizedBox(height: 10),

                // Display selected image preview
                _imagePath != null
                    ? Image.memory(_imageBytes!, height: 100, width: 100, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 100, color: Colors.grey),

                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text("Pick Image"),
                  onPressed: showImagePickerOptions,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addProduct,
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farmer Products")),
      body: Column(
        children: [
          Text("User ID: ${widget.userId}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      return ListTile(
                        leading: product['image'] != null
                            ? Image.network(
                                product['image'], // Use already formatted URL

                                width: 50, height: 50, fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(product['description']),
                        subtitle: Text("Price: Ksh ${product['price_per_kg']} per kg"),
                        trailing: Text("Weight: ${product['weight']}kg"),
                        onTap: () => editProduct(product),
                      );
                    },
                  ),
                ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add Product"),
            onPressed: showAddProductModal,
          ),
        ],
      ),
    );
  }

  Future<void> editProduct(dynamic product) async {
  descriptionController.text = product['description'];
  locationController.text = product['location'];
  priceController.text = product['price_per_kg'];
  weightController.text = product['weight'];
  _imageBytes = null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16.0, right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price per kg")),
              TextField(controller: weightController, decoration: const InputDecoration(labelText: "Weight")),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => updateProduct(product['id']),
                child: const Text("Update"),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> updateProduct(int productId) async {
  var url = Uri.parse("https://flutter.zuasoko.com/edit_product.php?userId=${widget.userId}");
  var request = http.MultipartRequest("POST", url);

  request.fields['product_id'] = productId.toString();
  request.fields['description'] = descriptionController.text;
  request.fields['location'] = locationController.text;
  request.fields['price_per_kg'] = priceController.text;
  request.fields['weight'] = weightController.text;

  try {
    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    var data = json.decode(responseData);

    if (data['success'] != null) {
      showSnackbar("Product updated successfully!");
      fetchProducts();
      Navigator.pop(context);
    } else {
      showSnackbar("Error: ${data['error']}");
    }
  } catch (e) {
    showSnackbar("Network error!");
  }
}

}
