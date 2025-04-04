import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  double _totalSavings = 0.0;
  double _totalWeight = 0.0;
  double _communityFoodSaved = 0.0;
  double _communityMoneySaved = 0.0;
  int _totalOrders = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContributions();
    _fetchCommunityImpact();
  }

  Future<void> _fetchContributions() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final ordersSnapshot = await _firestore
            .collection('orders')
            .where('buyerId', isEqualTo: user.uid)
            .get();

        double totalSavings = 0.0;
        double totalWeight = 0.0;

        for (var orderDoc in ordersSnapshot.docs) {
          final orderData = orderDoc.data();
          final productId = orderData['productId'];
          final quantity = orderData['quantity'] ?? 1;

          final productDoc = await _firestore.collection('products').doc(productId).get();
          final productData = productDoc.data();

          if (productData != null) {
            final originalPrice = (productData['originalPrice'] as num?)?.toDouble() ?? 0.0;
            final productPrice = (productData['price'] as num?)?.toDouble() ?? 0.0;
            final weight = (productData['weight'] as num?)?.toDouble() ?? 0.0;

            totalSavings += (originalPrice - productPrice) * quantity;
            totalWeight += weight * quantity;
          }
        }

        setState(() {
          _totalSavings = totalSavings;
          _totalWeight = totalWeight;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.fetchUserDataError}: $e')),
      );
    }
  }

  Future<void> _fetchCommunityImpact() async {
    try {
      final ordersSnapshot = await _firestore.collection('orders').get();
      final productsSnapshot = await _firestore.collection('products').get();

      int totalOrders = ordersSnapshot.docs.length;
      double communityFoodSaved = 0.0;
      double communityMoneySaved = 0.0;

      for (var productDoc in productsSnapshot.docs) {
        final productData = productDoc.data();
        final weight = (productData['weight'] as num?)?.toDouble() ?? 0.0;
        final originalPrice = (productData['originalPrice'] as num?)?.toDouble() ?? 0.0;
        final productPrice = (productData['price'] as num?)?.toDouble() ?? 0.0;

        final ordersForProduct = ordersSnapshot.docs
            .where((order) => order.data()['productId'] == productDoc.id)
            .length;

        communityFoodSaved += weight * ordersForProduct;
        communityMoneySaved += (originalPrice - productPrice) * ordersForProduct;
      }

      setState(() {
        _totalOrders = totalOrders;
        _communityFoodSaved = communityFoodSaved;
        _communityMoneySaved = communityMoneySaved;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.fetchCommunityDataError}: $e')),
      );
    }
  }

  void _shareImpact() {
    final locale = AppLocalizations.of(context)!;
    String message = locale.shareMessage(
      _totalSavings.toStringAsFixed(2),
      _totalWeight.toStringAsFixed(2),
      _communityFoodSaved.toStringAsFixed(2),
      _communityMoneySaved.toStringAsFixed(2),
    );

    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        title: Text(locale.yourContributions),
        backgroundColor: const Color(0xFF8B5E3C),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      locale.yourImpactTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A3D2B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Center(
                    child: Image.asset(
                      'images/impact.png',
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${locale.moneySaved}: \$${_totalSavings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B5E3C),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          locale.foodSaved(_totalWeight),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A3D2B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${locale.mealsSaved}: $_totalOrders',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A3D2B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${locale.communityFoodSaved}: ${_communityFoodSaved.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A3D2B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${locale.communityMoneySaved}: \$${_communityMoneySaved.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A3D2B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _shareImpact,
                    child: Text(locale.shareImpactButton),
                  ),
                ],
              ),
            ),
    );
  }
}
