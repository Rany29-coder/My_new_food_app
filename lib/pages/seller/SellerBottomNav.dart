import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:my_new_food_app/pages/seller/dashboard/store_dashboard.dart';
import 'package:my_new_food_app/pages/seller/product/manage_products.dart';
import 'orders/orders_page.dart';
import 'profile_page.dart';

/// If you have these constants in a separate file, import them.
// import 'package:my_new_food_app/theme.dart';

/// Otherwise define them here:
const kBackgroundColor = Color(0xFFFAF3E0); // Off-white
const kDarkBrown = Color(0xFF5A3D2B);
const kSoftBrown = Color(0xFF8B5E3C);

class SellerBottomNav extends StatefulWidget {
  const SellerBottomNav({super.key});

  @override
  State<SellerBottomNav> createState() => _SellerBottomNavState();
}

class _SellerBottomNavState extends State<SellerBottomNav> {
  int currentTabIndex = 0;
  late PageController _pageController;

  late List<Widget> pages;
  late StoreDashboard storeDashboard;
  late ManageProducts manageProducts;
  late OrdersPage ordersPage;
  late ProfilePage profilePage;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    storeDashboard = const StoreDashboard();
    manageProducts = const ManageProducts();
    ordersPage = const OrdersPage();
    profilePage = const ProfilePage();

    pages = [
      storeDashboard,
      manageProducts,
      ordersPage,
      profilePage,
    ];
  }

  @override
  void dispose() {
    _pageController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Off-white background
      backgroundColor: kBackgroundColor,

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

      /// Curved Nav at bottom
      bottomNavigationBar: CurvedNavigationBar(
        items: const <Widget>[
          Icon(Icons.dashboard, size: 30, color: Colors.white),
          Icon(Icons.store, size: 30, color: Colors.white),
          Icon(Icons.shopping_cart, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        index: currentTabIndex,
        height: 60.0,

        /// The main color of the nav bar
        color: kSoftBrown,

        /// The color behind the button (active highlight)
        buttonBackgroundColor: kDarkBrown,

        /// The background of the space behind the nav bar
        backgroundColor: kBackgroundColor,

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
