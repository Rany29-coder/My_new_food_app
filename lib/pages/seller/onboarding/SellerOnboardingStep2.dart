import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_new_food_app/pages/seller/SellerBottomNav.dart';
import 'package:my_new_food_app/pages/seller/dashboard/store_dashboard.dart';

class SellerOnboardingStep2 extends StatefulWidget {
  const SellerOnboardingStep2({Key? key}) : super(key: key);

  @override
  _SellerOnboardingStep2State createState() => _SellerOnboardingStep2State();
}

class _SellerOnboardingStep2State extends State<SellerOnboardingStep2> {
  double _communityFoodSaved = 0.0;
  double _communityMoneySaved = 0.0;
  int _totalOrders = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCommunityImpact();
  }

  /// Fetches Community-wide Impact Data
  Future<void> _fetchCommunityImpact() async {
    try {
      print("Fetching community impact...");

      final ordersCollection = FirebaseFirestore.instance.collection('orders');
      final productsCollection = FirebaseFirestore.instance.collection('products');

      // Fetch orders count directly
      final ordersSnapshot = await ordersCollection.get();
      int totalOrders = ordersSnapshot.docs.length;

      if (totalOrders == 0) {
        print("No orders found. Setting impact to zero.");
        setState(() {
          _totalOrders = 0;
          _communityFoodSaved = 0.0;
          _communityMoneySaved = 0.0;
          _isLoading = false;
        });
        return;
      }

      double communityFoodSaved = 0.0;
      double communityMoneySaved = 0.0;

      // Fetch all products once
      final productsSnapshot = await productsCollection.get();
      final Map<String, Map<String, dynamic>> productDataMap = {
        for (var product in productsSnapshot.docs) product.id: product.data()
      };

      // Fetch all orders at once
      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data();
        final productId = orderData['productId'];
        final quantity = (orderData['quantity'] as num?)?.toInt() ?? 1;

        print("Processing order for product ID: $productId");

        // Check if product exists
        if (productDataMap.containsKey(productId)) {
          final productData = productDataMap[productId];

          if (productData != null) {
            final weight = (productData['weight'] as num?)?.toDouble() ?? 0.0;
            final originalPrice = (productData['originalPrice'] as num?)?.toDouble() ?? 0.0;
            final productPrice = (productData['price'] as num?)?.toDouble() ?? 0.0;

            communityFoodSaved += weight * quantity;
            communityMoneySaved += (originalPrice - productPrice) * quantity;

            print("Updated stats: Food Saved = $communityFoodSaved kg, Money Saved = $communityMoneySaved");
          } else {
            print("⚠️ Product data is null for ID: $productId");
          }
        } else {
          print("⚠️ Product not found in Firestore for ID: $productId");
        }
      }

      // Update UI
      setState(() {
        _totalOrders = totalOrders;
        _communityFoodSaved = communityFoodSaved;
        _communityMoneySaved = communityMoneySaved;
        _isLoading = false;
      });

      print("✅ Fetching complete! Food Saved: $_communityFoodSaved kg, Money Saved: $_communityMoneySaved");

    } catch (e) {
      print("❌ Error fetching community impact: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch community data: $e')),
      );
    }
  }

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
            Image.asset('images/board4.jpg'),
            const SizedBox(height: 20),
            const Text(
              "Your Impact Matters! 🌍",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A3D2B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Text(
                        "🍎 ${_communityFoodSaved.toStringAsFixed(2)} kg of food saved",
                        style: const TextStyle(fontSize: 18, color: Color(0xFF8B5E3C)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "💰 \$${_communityMoneySaved.toStringAsFixed(2)} saved",
                        style: const TextStyle(fontSize: 18, color: Color(0xFF8B5E3C)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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
                  MaterialPageRoute(builder: (context) => const SellerBottomNav()),
                );
              },
              child: const Text(
                "Go to Dashboard →",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
