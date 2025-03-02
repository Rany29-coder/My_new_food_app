import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'product_model.dart';

/// Reuse the same color constants
const kBackgroundColor = Color(0xFFFAF3E0);
const kDarkBrown = Color(0xFF5A3D2B);
const kSoftBrown = Color(0xFF8B5E3C);

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _detailsController = TextEditingController();
  final _weightController = TextEditingController();
  final _ratingController = TextEditingController();

  File? _image;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  /// Common input decoration to give consistent styling
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kDarkBrown),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: kSoftBrown),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: kDarkBrown),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _originalPriceController.text.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _detailsController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _ratingController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final productId = _firestore.collection('products').doc().id;

        // Save image to Firebase Storage
        String imageUrl = '';
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('product_images')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          await storageRef.putFile(_image!);
          imageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image upload failed: $e')),
          );
          return;
        }

        // Create product object
        final product = Product(
          id: productId,
          name: _nameController.text.trim(),
          price: double.tryParse(_priceController.text) ?? 0.0,
          originalPrice: double.tryParse(_originalPriceController.text) ?? 0.0,
          expiryDate: _expiryDateController.text.isNotEmpty
              ? DateTime.parse(_expiryDateController.text)
              : DateTime.now(),
          details: _detailsController.text.trim(),
          imageUrl: imageUrl,
          weight: double.tryParse(_weightController.text) ?? 0.0,
          rating: double.tryParse(_ratingController.text) ?? 0.0,
        );

        // Save product to Firestore with userId
        await _firestore.collection('products').doc(productId).set({
          ...product.toMap(),
          'userId': user.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 1) Off-white background
      backgroundColor: kBackgroundColor,

      /// 2) Soft brown AppBar
      appBar: AppBar(
        backgroundColor: kSoftBrown,
        title: const Text('Add Product', style: TextStyle(color: Colors.white)),
      ),

      /// 3) Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Name
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Product Name'),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),

            /// Price
            TextField(
              controller: _priceController,
              decoration: _inputDecoration('Price'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),

            /// Original Price
            TextField(
              controller: _originalPriceController,
              decoration: _inputDecoration('Original Price'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),

            /// Expiry Date
            TextField(
              controller: _expiryDateController,
              decoration: _inputDecoration('Expiry Date (YYYY-MM-DD)'),
              keyboardType: TextInputType.datetime,
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),

            /// Details
            TextField(
              controller: _detailsController,
              decoration: _inputDecoration('Details'),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),

            /// Weight
            TextField(
              controller: _weightController,
              decoration: _inputDecoration('Weight (kg)'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),

            /// Rating
            TextField(
              controller: _ratingController,
              decoration: _inputDecoration('Rating (0-5)'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 20),

            /// Image
            _image != null
                ? Image.file(_image!, height: 200)
                : const Text('No image selected.', style: TextStyle(color: kDarkBrown)),

            /// Pick Image Button
            TextButton(
              onPressed: _pickImage,
              style: TextButton.styleFrom(
                foregroundColor: kSoftBrown,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),

            /// Add Product Button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _addProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSoftBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
