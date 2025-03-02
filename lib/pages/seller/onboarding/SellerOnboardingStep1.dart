import 'package:flutter/material.dart';
import 'package:my_new_food_app/pages/seller/onboarding/SellerOnboardingStep2.dart';

class SellerOnboardingStep1 extends StatelessWidget {
  const SellerOnboardingStep1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('images/board3.jpg'),
            const SizedBox(height: 20),
            const Text(
              "Welcome to Baraka! 🎉",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A3D2B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "You're now part of a movement to reduce food waste and make a real impact in your community! 💚",
              style: TextStyle(fontSize: 18, color: Color(0xFF8B5E3C)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5E3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SellerOnboardingStep2()),
                );
              },
              child: const Text(
                "Next →",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
