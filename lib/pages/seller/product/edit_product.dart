import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'product_model.dart';

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
    _originalPriceController = TextEditingController(text: widget.product.originalPrice.toString());
    _expiryDateController = TextEditingController(text: widget.product.expiryDate.toIso8601String());
    _detailsController = TextEditingController(text: widget.product.details);
    _weightController = TextEditingController(text: widget.product.weight.toString());
    _ratingController = TextEditingController(text: widget.product.rating.toString());
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final product = Product(
          id: widget.product.id,
          name: _nameController.text,
          price: double.parse(_priceController.text),
          originalPrice: double.parse(_originalPriceController.text),
          expiryDate: DateTime.parse(_expiryDateController.text),
          details: _detailsController.text,
          imageUrl: widget.product.imageUrl, // TODO: Upload new image if changed
          weight: double.parse(_weightController.text),
          rating: double.parse(_ratingController.text),
        );

        await _firestore.collection('products').doc(widget.product.id).update(product.toMap());

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _originalPriceController,
              decoration: InputDecoration(labelText: 'Original Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _expiryDateController,
              decoration: InputDecoration(labelText: 'Expiry Date (YYYY-MM-DD)'),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(labelText: 'Details'),
            ),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ratingController,
              decoration: InputDecoration(labelText: 'Rating (0-5)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            _image != null
                ? Image.file(_image!, height: 200)
                : widget.product.imageUrl.isNotEmpty
                    ? Image.network(widget.product.imageUrl, height: 200)
                    : Text('No image selected.'),
            TextButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _editProduct,
                    child: Text('Save Changes'),
                  ),
          ],
        ),
      ),
    );
  }
}
