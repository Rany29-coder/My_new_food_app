import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userId;

  @override
  void initState() {
    super.initState();
    // Wait a bit to allow Firebase to initialize on Web
    Future.delayed(const Duration(milliseconds: 300), () {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        setState(() {
          userId = currentUser.uid;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF5EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5E3C),
        title: Text(
          locale.myOrders,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: userId == null
          ? Center(
              child: Text(
                locale.userNotLoggedIn,
                style: const TextStyle(fontSize: 18, color: Colors.brown),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('orders')
                  .where('buyerId', isEqualTo: userId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading orders: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      locale.noOrdersFound,
                      style: const TextStyle(fontSize: 18, color: Colors.brown),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final order = docs[index].data() as Map<String, dynamic>;
                    final productName = order['productName'] ?? locale.unknownProduct;
                    final quantity = order['quantity'] ?? 0;
                    final totalPrice = (order['totalPrice'] as num?)?.toDouble() ?? 0.0;
                    final status = order['status'] ?? 'Pending';
                    final timestamp = order['timestamp'] != null
                        ? (order['timestamp'] as Timestamp).toDate()
                        : null;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A3D2B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${locale.quantity}: $quantity"),
                              Text("${locale.total}: \$${totalPrice.toStringAsFixed(2)}"),
                            ],
                          ),
                          if (timestamp != null)
                            Text(
                              "${locale.date}: ${DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp)}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _getStatusIcon(status),
                              const SizedBox(width: 6),
                              Text(
                                "${locale.status}: ${_getLocalizedStatus(status, locale)}",
                                style: TextStyle(color: _getStatusColor(status)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'Completed':
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case 'Cancelled':
        return const Icon(Icons.cancel, color: Colors.red, size: 20);
      default:
        return const Icon(Icons.hourglass_empty, color: Colors.orange, size: 20);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getLocalizedStatus(String status, AppLocalizations locale) {
    switch (status) {
      case 'Completed':
        return locale.statusCompleted;
      case 'Cancelled':
        return locale.statusCancelled;
      default:
        return locale.statusPending;
    }
  }
}
