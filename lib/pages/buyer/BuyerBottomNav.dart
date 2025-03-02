import 'package:flutter/material.dart';
import 'package:my_new_food_app/pages/buyer/home.dart';
import 'package:my_new_food_app/pages/buyer/order.dart';
import 'package:my_new_food_app/pages/buyer/profile.dart';
import 'package:my_new_food_app/pages/buyer/wallet.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BuyerBottomNav extends StatefulWidget {
  const BuyerBottomNav({super.key});

  @override
  State<BuyerBottomNav> createState() => _BuyerBottomNavState();
}

class _BuyerBottomNavState extends State<BuyerBottomNav> {
  int currentTabIndex = 0;
  late PageController _pageController;

  late List<Widget> pages;
  late Home homepage;
  late Profile profilepage;
  late Wallet walletpage;
  late Order orderpage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    homepage = const Home();
    profilepage = const Profile();
    walletpage = const Wallet();
    orderpage = const Order();
    pages = [homepage, walletpage, orderpage, profilepage];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF5EE), // Light beige background
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: pages,
              onPageChanged: (index) {
                setState(() {
                  currentTabIndex = index;
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: <Widget>[
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.account_balance_wallet, 1),
          _buildNavItem(Icons.shopping_cart, 2),
          _buildNavItem(Icons.person, 3),
        ],
        index: currentTabIndex,
        height: 60.0,
        color: const Color(0xFF6D4C41), // Warm brown navbar
        buttonBackgroundColor: const Color(0xFFBCAAA4), // Lighter brown when selected
        backgroundColor: const Color(0xFFFCF5EE), // Beige background
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = currentTabIndex == index;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 30,
          color: isSelected ? Colors.white : const Color(0xFFFCF5EE), // White when selected
        ),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? Colors.white : Colors.transparent, // Dot only when selected
          ),
        ),
      ],
    );
  }
}
