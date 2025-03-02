import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'product_model.dart';

/// Color Palette (same as Onboard and other pages)
const kBackgroundColor = Color(0xFFFAF3E0); 
const kDarkBrown = Color(0xFF5A3D2B);
const kSoftBrown = Color(0xFF8B5E3C);

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({required this.product, Key? key}) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _expiryDateController;
  late TextEditingController _detailsController;
  late TextEditingController _weightController;
  late TextEditingController _ratingController;

  File? _image;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _originalPriceController =
        TextEditingController(text: widget.product.originalPrice.toString());
    _expiryDateController =
        TextEditingController(text: widget.product.expiryDate.toIso8601String());
    _detailsController = TextEditingController(text: widget.product.details);
    _weightController = TextEditingController(text: widget.product.weight.toString());
    _ratingController = TextEditingController(text: widget.product.rating.toString());
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _editProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _originalPriceController.text.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _detailsController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _ratingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final updatedProduct = Product(
          id: widget.product.id,
          name: _nameController.text,
          price: double.parse(_priceController.text),
          originalPrice: double.parse(_originalPriceController.text),
          expiryDate: DateTime.parse(_expiryDateController.text),
          details: _detailsController.text,
          imageUrl: widget.product.imageUrl, // TODO: upload new image if changed
          weight: double.parse(_weightController.text),
          rating: double.parse(_ratingController.text),
        );

        await _firestore
            .collection('products')
            .doc(widget.product.id)
            .update(updatedProduct.toMap());

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Common InputDecoration for consistent styling
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Use the same off-white background
      backgroundColor: kBackgroundColor,

      /// AppBar with soft brown color
      appBar: AppBar(
        backgroundColor: kSoftBrown,
        title: const Text('Edit Product', style: TextStyle(color: Colors.white)),
      ),

      /// Main Body
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
                : (widget.product.imageUrl.isNotEmpty
                    ? Image.network(widget.product.imageUrl, height: 200)
                    : const Text('No image selected.',
                        style: TextStyle(color: kDarkBrown))),

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

            /// Save Changes Button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _editProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSoftBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
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
