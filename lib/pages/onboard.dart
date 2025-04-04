// onboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_new_food_app/pages/login.dart';
import 'package:my_new_food_app/widget/content_model.dart';
import 'package:my_new_food_app/widget/widget_support.dart';
class UnboardingContent {
  final String image;
  final String titleKey;
  final String descriptionKey;

  UnboardingContent({
    required this.image,
    required this.titleKey,
    required this.descriptionKey,
  });
}

List<UnboardingContent> contents = [
  UnboardingContent(
    image: "images/board1.png",
    titleKey: "onboardingTitle1",
    descriptionKey: "onboardingDesc1",
  ),
  UnboardingContent(
    image: "images/board2.png",
    titleKey: "onboardingTitle2",
    descriptionKey: "onboardingDesc2",
  ),
];




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
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
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
                  padding: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
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
                        _getLocalizedString(locale, contents[i].titleKey),
                        style: AppWidget.headlineTextFieldStyle.copyWith(color: const Color(0xFF5A3D2B)),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        _getLocalizedString(locale, contents[i].descriptionKey),
                        textAlign: TextAlign.center,
                        style: AppWidget.lightlineTextFieldStyle.copyWith(color: const Color(0xFF8B5E3C)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(contents.length, (index) => buildDot(index)),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              if (currentIndex == contents.length - 1) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Login()));
              } else {
                _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              }
            },
            child: Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5E3C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
  currentIndex == contents.length - 1 ? locale.onboardingStart : locale.onboardingNext,
  style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
),

              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Login()));
            },
            child: Text(
  locale.onboardingSkip,
  style: const TextStyle(color: Color(0xFF5A3D2B), fontWeight: FontWeight.bold, fontSize: 16),
),

          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Container buildDot(int index) {
    return Container(
      height: 10.0,
      width: currentIndex == index ? 18 : 7,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: currentIndex == index ? const Color(0xFF8B5E3C) : const Color(0xFF5A3D2B).withOpacity(0.3),
      ),
    );
  }

  String _getLocalizedString(AppLocalizations locale, String key) {
    switch (key) {
      case 'onboardingTitle1':
        return locale.onboardingTitle1;
      case 'onboardingTitle2':
        return locale.onboardingTitle2;
      case 'onboardingDesc1':
        return locale.onboardingDesc1;
      case 'onboardingDesc2':
        return locale.onboardingDesc2;
      default:
        return '';
    }
  }
}