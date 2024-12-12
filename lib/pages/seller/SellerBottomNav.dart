import 'package:flutter/material.dart';
import 'package:my_new_food_app/pages/seller/dashboard/store_dashboard.dart';
import 'package:my_new_food_app/pages/seller/product/manage_products.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'orders/orders_page.dart';
import 'profile_page.dart';

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
    _pageController = PageController(); // Initialize the PageController here
    storeDashboard = const StoreDashboard();
    manageProducts = const ManageProducts();
    ordersPage = const OrdersPage();
    profilePage = const ProfilePage();
    pages = [storeDashboard, manageProducts, ordersPage, profilePage];
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
          Icon(Icons.dashboard, size: 30, color: Colors.white),
          Icon(Icons.store, size: 30, color: Colors.white),
          Icon(Icons.shopping_cart, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white), // Profile icon
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
