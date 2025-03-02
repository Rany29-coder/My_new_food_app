import 'package:flutter/material.dart';
import 'package:my_new_food_app/pages/login.dart';
import 'package:my_new_food_app/widget/content_model.dart';
import 'package:my_new_food_app/widget/widget_support.dart';

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0), // Background matching theme
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding:
                      const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
                  child: Column(
                    children: [
                      Image.asset(
                        contents[i].image,
                        height: 450,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(height: 40.0),
                      Text(
                        contents[i].title,
                        style: AppWidget.headlineTextFieldStyle.copyWith(
                          color: const Color(0xFF5A3D2B), // Dark brown text
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        contents[i].description,
                        textAlign: TextAlign.center,
                        style: AppWidget.lightlineTextFieldStyle.copyWith(
                          color: const Color(0xFF8B5E3C), // Soft brown
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              contents.length,
              (index) => buildDot(index, context),
            ),
          ),
          const SizedBox(height: 20),

          /// Navigation Button
          GestureDetector(
            onTap: () {
              if (currentIndex == contents.length - 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              } else {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8B5E3C), // Brown button color
                borderRadius: BorderRadius.circular(20),
              ),
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: Center(
                child: Text(
                  currentIndex == contents.length - 1 ? "Start" : "Next",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          /// Skip Button
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
            child: const Text(
              "Skip",
              style: TextStyle(
                color: Color(0xFF5A3D2B), // Dark brown
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  /// Dot indicator for page navigation
  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10.0,
      width: currentIndex == index ? 18 : 7,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: currentIndex == index
            ? const Color(0xFF8B5E3C) // Active: Brown
            : const Color(0xFF5A3D2B).withOpacity(0.3), // Inactive: Lighter brown
      ),
    );
  }
}
