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
    _pageController = PageController(); // Initialize the PageController here
    homepage = const Home();
    profilepage = const Profile();
    walletpage = const Wallet();
    orderpage = const Order();
    pages = [homepage, walletpage, orderpage, profilepage];
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of the PageController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.account_balance_wallet, size: 30, color: Colors.white),
          Icon(Icons.shopping_cart, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        index: currentTabIndex,
        height: 60.0,
        color: Colors.black,
        buttonBackgroundColor: Colors.black,
        backgroundColor: Colors.white,
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
}
