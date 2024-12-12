import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContributions();
  }

  Future<void> _fetchContributions() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Fetch all orders for the current user
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

          // Fetch product details using productId
          final productDoc =
              await _firestore.collection('products').doc(productId).get();
          final productData = productDoc.data();

          if (productData != null) {
            final originalPrice =
                (productData['originalPrice'] as num?)?.toDouble() ?? 0.0;
            final productPrice =
                (productData['price'] as num?)?.toDouble() ?? 0.0;
            final weight = (productData['weight'] as num?)?.toDouble() ?? 0.0;

            // Calculate total savings and total weight saved
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
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch contributions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Contributions'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.green[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Savings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '\$${_totalSavings.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'This is the total amount of money you have saved by purchasing discounted food.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.blue[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Food Saved',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${_totalWeight.toStringAsFixed(2)} kg',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'This is the total weight of food you have saved from going to waste.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Thank you for contributing!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
