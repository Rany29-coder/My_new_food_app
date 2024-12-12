import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late TextEditingController _storeNameController;
  late TextEditingController _addressController;
  late TextEditingController _contactDetailsController;
  late TextEditingController _businessHoursController;
  late TextEditingController _deliveryOptionsController;

  File? _storeLogo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _addressController = TextEditingController();
    _contactDetailsController = TextEditingController();
    _businessHoursController = TextEditingController();
    _deliveryOptionsController = TextEditingController();
    _fetchStoreData();
  }

  Future<void> _fetchStoreData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final storeDoc = await _firestore.collection('stores').doc(user.uid).get();
        if (storeDoc.exists) {
          final storeData = storeDoc.data();
          setState(() {
            _storeNameController.text = storeData?['storeName'] ?? '';
            _addressController.text = storeData?['address'] ?? '';
            _contactDetailsController.text = storeData?['contactDetails'] ?? '';
            _businessHoursController.text = storeData?['businessHours'] ?? '';
            _deliveryOptionsController.text = storeData?['deliveryOptions'] ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _updateStoreInfo() async {
    if (_storeNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _contactDetailsController.text.isEmpty ||
        _businessHoursController.text.isEmpty ||
        _deliveryOptionsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        String? storeLogoUrl;

        // Save store logo to Firebase Storage
        if (_storeLogo != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('store_logos')
              .child(user.uid + '.jpg');
          await storageRef.putFile(_storeLogo!);
          storeLogoUrl = await storageRef.getDownloadURL();
        }

        await _firestore.collection('stores').doc(user.uid).update({
          'storeName': _storeNameController.text,
          'address': _addressController.text,
          'contactDetails': _contactDetailsController.text,
          'businessHours': _businessHoursController.text,
          'deliveryOptions': _deliveryOptionsController.text,
          if (storeLogoUrl != null) 'storeLogo': storeLogoUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Store information updated successfully')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickStoreLogo() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _storeLogo = File(pickedFile.path);
      });
    }
  }

  Future<void> _logout() async {
  try {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _storeNameController,
              decoration: InputDecoration(labelText: 'Store Name'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _contactDetailsController,
              decoration: InputDecoration(labelText: 'Contact Details'),
            ),
            TextField(
              controller: _businessHoursController,
              decoration: InputDecoration(labelText: 'Business Hours'),
            ),
            TextField(
              controller: _deliveryOptionsController,
              decoration: InputDecoration(labelText: 'Delivery Options'),
            ),
            SizedBox(height: 10),
            _storeLogo != null
                ? Image.file(_storeLogo!, height: 200)
                : Text('No store logo selected.'),
            TextButton(
              onPressed: _pickStoreLogo,
              child: Text('Pick Store Logo'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _updateStoreInfo,
                    child: Text('Update Store Information'),
                  ),
          ],
        ),
      ),
    );
  }
}
