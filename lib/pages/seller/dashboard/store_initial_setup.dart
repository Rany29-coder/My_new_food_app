import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          MaterialPageRoute(builder: (context) => StoreDashboard()),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Initial Setup'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Store Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your store name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Business Hours',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _businessHoursController,
                decoration: InputDecoration(
                  hintText: 'Enter your business hours',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Delivery Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _deliveryOptionsController,
                decoration: InputDecoration(
                  hintText: 'Enter your delivery options',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Store Logo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    _storeLogo != null
                        ? Image.file(_storeLogo!, height: 100)
                        : Icon(Icons.image, size: 100, color: Colors.grey),
                    ElevatedButton(
                      onPressed: _pickStoreLogo,
                      child: Text('Upload Store Logo'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _completeRegistration,
                        child: Text('Complete Registration'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
