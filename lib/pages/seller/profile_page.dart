import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Use the same color constants as your other pages
const kBackgroundColor = Color(0xFFFAF3E0);
const kDarkBrown = Color(0xFF5A3D2B);
const kSoftBrown = Color(0xFF8B5E3C);

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

  /// Common InputDecoration for consistency
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching store info: $e')),
      );
    }
  }

  Future<void> _updateStoreInfo() async {
    if (_storeNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _contactDetailsController.text.isEmpty ||
        _businessHoursController.text.isEmpty ||
        _deliveryOptionsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        String? storeLogoUrl;

        // Upload store logo if changed
        if (_storeLogo != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('store_logos')
              .child('${user.uid}.jpg');
          await storageRef.putFile(_storeLogo!);
          storeLogoUrl = await storageRef.getDownloadURL();
        }

        await _firestore.collection('stores').doc(user.uid).update({
          'storeName': _storeNameController.text.trim(),
          'address': _addressController.text.trim(),
          'contactDetails': _contactDetailsController.text.trim(),
          'businessHours': _businessHoursController.text.trim(),
          'deliveryOptions': _deliveryOptionsController.text.trim(),
          if (storeLogoUrl != null) 'storeLogo': storeLogoUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Store information updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating store info: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickStoreLogo() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _storeLogo = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking store logo: $e')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    _contactDetailsController.dispose();
    _businessHoursController.dispose();
    _deliveryOptionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Off-white background
      backgroundColor: kBackgroundColor,

      /// Soft brown appBar
      appBar: AppBar(
        backgroundColor: kSoftBrown,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),

      /// Main content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Store Name
            TextField(
              controller: _storeNameController,
              decoration: _inputDecoration('Store Name'),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),

            /// Address
            TextField(
              controller: _addressController,
              decoration: _inputDecoration('Address'),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),

            /// Contact Details
            TextField(
              controller: _contactDetailsController,
              decoration: _inputDecoration('Contact Details'),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),

            /// Business Hours
            TextField(
              controller: _businessHoursController,
              decoration: _inputDecoration('Business Hours'),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),

            /// Delivery Options
            TextField(
              controller: _deliveryOptionsController,
              decoration: _inputDecoration('Delivery Options'),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 20),

            /// Store Logo
            _storeLogo != null
                ? Image.file(_storeLogo!, height: 200)
                : const Text('No store logo selected.',
                    style: TextStyle(color: kDarkBrown)),

            /// Pick Logo Button
            TextButton(
              onPressed: _pickStoreLogo,
              style: TextButton.styleFrom(
                foregroundColor: kSoftBrown,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Pick Store Logo'),
            ),
            const SizedBox(height: 20),

            /// Update Button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateStoreInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSoftBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Update Store Information',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
