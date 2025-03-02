import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_new_food_app/pages/buyer/BuyerBottomNav.dart'; // Import the main navigation bar page

class CelebrationPage extends StatelessWidget {
  final String productName;
  final double totalSaved;
  final double foodSaved;

  const CelebrationPage({
    required this.productName,
    required this.totalSaved,
    required this.foodSaved,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0), // Light beige theme
      body: Stack(
        alignment: Alignment.center,
        children: [
          /// 🎊 Mascot Image (Appears Behind Confetti)
          Positioned(
            top: 100,
            child: Image.asset(
              'images/mascot_celebration.jpg',
              height: 250, // Increased size
              width: 250, // Ensure it's visible
              fit: BoxFit.cover,
            ),
          ),

          /// 🎉 Confetti Animation (Appears Over Image)
          Positioned(
            top: 80, // Adjusted to match image position
            child: Lottie.asset(
              'images/confetti.json',
              height: 300, // Covers a large area
              repeat: false, // Play once
            ),
          ),

          /// 🎇 Celebration Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 300), // To make space for confetti & image

                /// 🎉 Title
                const Text(
                  "Congratulations! 🎉",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5E3C),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                /// 🌱 Impact Statement
                Text(
                  "You just saved \$$totalSaved and prevented ${foodSaved.toStringAsFixed(2)} kg of food from being wasted! 🌍💚",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A3D2B),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                /// 🌟 Motivation Text
                Text(
                  "Every small action makes a big difference. Keep shopping and making an impact!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                /// 🛒 **Go Back to Home with Navbar**
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const BuyerBottomNav()), // Ensures navbar is present
                      (route) => false, // Clears all previous routes
                    );
                  },
                  child: const Text(
                    "Continue Shopping 🛍️",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
