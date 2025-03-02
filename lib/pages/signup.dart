import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_new_food_app/pages/buyer/BuyerBottomNav.dart';
import 'package:my_new_food_app/pages/seller/seller_signup.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedUserType = 'Buyer';

  void _signUp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_passwordController.text == _confirmPasswordController.text) {
        final newUser = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (newUser != null) {
          await _firestore.collection('users').doc(newUser.user!.uid).set({
            'name': _nameController.text,
            'email': _emailController.text,
            'userType': _selectedUserType,
          });

          if (_selectedUserType == 'Seller') {
            await _firestore.collection('sellers').doc(newUser.user!.uid).set({
              'storeName': '',
              'categories': [],
              'storeLocation': '',
              'storeImage': '',
              'nationalID': '',
              'goals': '',
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SellerSignUpPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BuyerBottomNav()),
            );
          }
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
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
      backgroundColor: Color(0xFFFCF5EE),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40), // Pushes content down for centering
                
                // ✅ Image at the top
                Image.asset(
                  'images/signup.png',
                  height: 180,  // Adjust height as needed
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                
                SizedBox(height: 20), // Space below image
                
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF38333C),
                  ),
                ),
                Text(
                  'Please sign up to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF71452E),
                  ),
                ),
                
                SizedBox(height: 25), // More space before form
                
                _buildInputField(_nameController, 'Name'),
                SizedBox(height: 10),
                _buildInputField(_emailController, 'Email'),
                SizedBox(height: 10),
                _buildPasswordField(_passwordController, 'Password', true),
                SizedBox(height: 10),
                _buildPasswordField(_confirmPasswordController, 'Retype Password', false),
                
                SizedBox(height: 15), // Space before radio buttons
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRadioButton('Buyer'),
                    _buildRadioButton('Seller'),
                  ],
                ),
                
                SizedBox(height: 20), // Space before button
                
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF984A2B),
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                SizedBox(height: 40), // Adds bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF8C5C41)),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hintText, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : _obscureConfirmPassword,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF8C5C41)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPassword
                ? (_obscurePassword ? Icons.visibility_off : Icons.visibility)
                : (_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
            color: Color(0xFF8C5C41),
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildRadioButton(String title) {
    return Row(
      children: [
        Radio<String>(
          value: title,
          groupValue: _selectedUserType,
          onChanged: (value) {
            setState(() {
              _selectedUserType = value!;
            });
          },
          activeColor: Color(0xFF8C5C41),
        ),
        Text(
          title,
          style: TextStyle(color: Color(0xFF38333C), fontSize: 16),
        ),
      ],
    );
  }
}
