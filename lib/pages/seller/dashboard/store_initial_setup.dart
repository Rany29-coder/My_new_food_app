import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_new_food_app/pages/seller/dashboard/store_dashboard.dart';

class StoreInitialSetup extends StatefulWidget {
  const StoreInitialSetup({super.key});

  @override
  _StoreInitialSetupState createState() => _StoreInitialSetupState();
}

class _StoreInitialSetupState extends State<StoreInitialSetup> {
  final _storeNameController = TextEditingController();
  final _businessHoursController = TextEditingController();
  final _deliveryOptionsController = TextEditingController();
  File? _storeLogo;
  bool _isLoading = false;

  Future<void> _pickStoreLogo() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _storeLogo = File(pickedFile.path);
      });
    }
  }

  void _completeRegistration() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(user.uid)
            .set({
          'storeName': _storeNameController.text,
          'businessHours': _businessHoursController.text,
          'deliveryOptions': _deliveryOptionsController.text,
          'storeLogo': _storeLogo?.path ?? '',
        });
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StoreDashboard()),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.storeInitialSetup),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(locale.storeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _storeNameController,
              decoration: InputDecoration(
                hintText: locale.storeNameHint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            Text(locale.businessHours, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _businessHoursController,
              decoration: InputDecoration(
                hintText: locale.businessHoursHint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            Text(locale.deliveryOptions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _deliveryOptionsController,
              decoration: InputDecoration(
                hintText: locale.deliveryOptionsHint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            Text(locale.storeLogo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  _storeLogo != null
                      ? Image.file(_storeLogo!, height: 100)
                      : const Icon(Icons.image, size: 100, color: Colors.grey),
                  ElevatedButton(
                    onPressed: _pickStoreLogo,
                    child: Text(locale.uploadStoreLogo),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _completeRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(locale.completeRegistration),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
