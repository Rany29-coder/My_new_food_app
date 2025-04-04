import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'product_model.dart';

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
    final locale = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(locale.imagePickFailed(e.toString()))),
      );
    }
  }

  Future<void> _addProduct() async {
    final locale = AppLocalizations.of(context)!;
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _originalPriceController.text.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _detailsController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _ratingController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.fillAllFields)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final productId = _firestore.collection('products').doc().id;

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
            SnackBar(content: Text(locale.imageUploadFailed(e.toString()))),
          );
          return;
        }

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

        await _firestore.collection('products').doc(productId).set({
          ...product.toMap(),
          'userId': user.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(locale.productAdded)),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(locale.userNotAuthenticated)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.productAddFailed(e.toString()))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kSoftBrown,
        title: Text(locale.addProductTitle, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: _inputDecoration(locale.productName),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: _inputDecoration(locale.price),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _originalPriceController,
              decoration: _inputDecoration(locale.originalPrice),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _expiryDateController,
              decoration: _inputDecoration(locale.expiryDate),
              keyboardType: TextInputType.datetime,
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _detailsController,
              decoration: _inputDecoration(locale.details),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _weightController,
              decoration: _inputDecoration(locale.weight),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ratingController,
              decoration: _inputDecoration(locale.rating),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 20),
            _image != null
                ? Image.file(_image!, height: 200)
                : Text(locale.noImageSelected, style: const TextStyle(color: kDarkBrown)),
            TextButton(
              onPressed: _pickImage,
              style: TextButton.styleFrom(
                foregroundColor: kSoftBrown,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              child: Text(locale.pickImage),
            ),
            const SizedBox(height: 20),
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
                      child: Text(
                        locale.addProduct,
                        style: const TextStyle(
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