import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:my_new_food_app/pages/seller/dashboard/store_dashboard.dart';
import 'package:my_new_food_app/pages/seller/onboarding/SellerOnboardingStep1.dart';
import 'package:my_new_food_app/pages/seller/onboarding/SellerOnboardingStep2.dart';
class SellerSignUpPage extends StatefulWidget {
  const SellerSignUpPage({Key? key}) : super(key: key);

  @override
  _SellerSignUpPageState createState() => _SellerSignUpPageState();
}

class _SellerSignUpPageState extends State<SellerSignUpPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  String _storeName = '';
  String _storeLocation = '';
  File? _storeImage;
  String _nationalID = '';
  String _goals = '';

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _storeImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerSeller() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final user = _auth.currentUser;
        if (user != null) {
          // Upload store image if selected
          String imageUrl = '';
          if (_storeImage != null) {
            final storageRef =
                FirebaseStorage.instance.ref().child('store_images/${user.uid}');
            await storageRef.putFile(_storeImage!);
            imageUrl = await storageRef.getDownloadURL();
          }

          // Save seller data
          await _firestore.collection('sellers').doc(user.uid).set({
            'storeName': _storeName,
            'storeLocation': _storeLocation,
            'storeImage': imageUrl,
            'nationalID': _nationalID,
            'goals': _goals,
          });

          // Navigate to Store Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SellerOnboardingStep1()),
          );
        } else {
          setState(() {
            _errorMessage = 'User not authenticated. Please sign in again.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0), // Light beige background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🎉 Mascot & Welcome Message
                Image.asset('images/Seller_signup.jpg'), // Mascot image
                const SizedBox(height: 10),
                const Text(
                  "Welcome to Baraka!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A3D2B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                const Text(
                  "Join us in making a difference by reducing food waste and helping your community.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8B5E3C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // 📝 Form Section
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 🏬 Store Name
                      _buildInputField(
                        icon: Icons.store,
                        hintText: "Store Name",
                        onSaved: (value) => _storeName = value!,
                      ),

                      // 📍 Store Location
                      _buildInputField(
                        icon: Icons.location_on,
                        hintText: "Store Location",
                        onSaved: (value) => _storeLocation = value!,
                      ),

                      // 💳 National ID
                      _buildInputField(
                        icon: Icons.credit_card,
                        hintText: "National ID",
                        onSaved: (value) => _nationalID = value!,
                      ),

                      // 🎯 Business Goals
                      _buildInputField(
                        icon: Icons.emoji_objects,
                        hintText: "Business Goals",
                        onSaved: (value) => _goals = value!,
                      ),

                      const SizedBox(height: 10),

                      // 📷 Upload Image Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5E3C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _pickImage,
                        child: const Text("Upload Store Image"),
                      ),

                      const SizedBox(height: 15),

                      // 📸 Store Image Preview
                      if (_storeImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _storeImage!,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      else

                      const SizedBox(height: 15),

                      // 🔥 Register Button
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5E3C),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 60),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _registerSeller,
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📌 Input Field Widget with Icons
  Widget _buildInputField({
    required IconData icon,
    required String hintText,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF8B5E3C)),
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.brown, width: 1),
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Required field' : null,
        onSaved: onSaved,
      ),
    );
  }
}
