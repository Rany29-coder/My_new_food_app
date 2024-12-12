import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostProduct extends StatefulWidget {
  @override
  _PostProductState createState() => _PostProductState();
}

class _PostProductState extends State<PostProduct> {
  final _priceController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _detailsController = TextEditingController();
  final _productNameController = TextEditingController();
  File? _image;
  String? _imageUrl;
  bool _isLoading = false;
  bool _isPosted = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      final storageRef = FirebaseStorage.instance.ref().child('products/${DateTime.now().toIso8601String()}.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask;
      _imageUrl = await snapshot.ref.getDownloadURL();
    }
  }

  Future<void> _postProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _uploadImage();

      await FirebaseFirestore.instance.collection('products').add({
        'product_name': _productNameController.text,
        'price': _priceController.text,
        'expiry_date': _expiryDateController.text,
        'details': _detailsController.text,
        'image_url': _imageUrl,
        'created_at': Timestamp.now(),
      });

      setState(() {
        _isPosted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product posted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post product: $e')),
      );
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
        title: Text('Post a Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Original Price'),
            ),
            TextField(
              controller: _expiryDateController,
              decoration: InputDecoration(labelText: 'Expiry Date'),
            ),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(labelText: 'Product Details'),
            ),
            SizedBox(height: 20),
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!, height: 200),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Image'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _postProduct,
                    child: Text(_isPosted ? 'Product Posted Successfully' : 'Post Product'),
                  ),
          ],
        ),
      ),
    );
  }
}
