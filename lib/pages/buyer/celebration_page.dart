import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_new_food_app/pages/buyer/BuyerBottomNav.dart';

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
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 🎊 Mascot
          Positioned(
            top: 100,
            child: Image.asset(
              'images/mascot_celebration.jpg',
              height: 250,
              width: 250,
              fit: BoxFit.cover,
            ),
          ),

          // 🎉 Confetti
          Positioned(
            top: 80,
            child: Lottie.asset(
              'images/confetti.json',
              height: 300,
              repeat: false,
            ),
          ),

          // 🎇 Main Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 300),

                // 🎉 Title
                Text(
                  locale.celebrationTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5E3C),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // 🌱 Impact Statement
                Text(
                  locale.celebrationImpact(
                    totalSaved.toStringAsFixed(2),
                    foodSaved.toStringAsFixed(2),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A3D2B),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // 🌟 Motivation
                Text(
                  locale.celebrationMotivation,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // 🛒 Button
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
                      MaterialPageRoute(builder: (_) => const BuyerBottomNav()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    locale.continueShopping,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
