import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final locale = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(locale.storeFetchError.replaceFirst('{error}', e.toString()))),
      );
    }
  }

  Future<void> _updateStoreInfo() async {
    final locale = AppLocalizations.of(context)!;

    if (_storeNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _contactDetailsController.text.isEmpty ||
        _businessHoursController.text.isEmpty ||
        _deliveryOptionsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.fillAllFields)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        String? storeLogoUrl;
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
          SnackBar(content: Text(locale.updateSuccess)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.updateError.replaceFirst('{error}', e.toString()))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickStoreLogo() async {
    final locale = AppLocalizations.of(context)!;
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _storeLogo = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.imagePickFailed(e.toString())
)),
      );
    }
  }

  Future<void> _logout() async {
    final locale = AppLocalizations.of(context)!;
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.logoutError.replaceFirst('{error}', e.toString()))),
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
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kSoftBrown,
        title: Text(locale.profileTitle, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _storeNameController,
              decoration: _inputDecoration(locale.storeName),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: _inputDecoration(locale.address),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactDetailsController,
              decoration: _inputDecoration(locale.contactDetails),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _businessHoursController,
              decoration: _inputDecoration(locale.businessHours),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _deliveryOptionsController,
              decoration: _inputDecoration(locale.deliveryOptions),
              style: const TextStyle(color: kDarkBrown),
            ),
            const SizedBox(height: 20),
            _storeLogo != null
                ? Image.file(_storeLogo!, height: 200)
                : Text(locale.noStoreLogo,
                    style: const TextStyle(color: kDarkBrown)),
            TextButton(
              onPressed: _pickStoreLogo,
              style: TextButton.styleFrom(
                foregroundColor: kSoftBrown,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: Text(locale.pickStoreLogo),
            ),
            const SizedBox(height: 20),
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
                      child: Text(
                        locale.updateStoreInfo,
                        style: const TextStyle(
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
