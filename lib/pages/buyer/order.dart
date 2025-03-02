import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userId;
  List<DocumentSnapshot> _orders = []; // Stores previous order data to prevent flickering

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  void _fetchUser() {
    setState(() {
      userId = _auth.currentUser?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF5EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5E3C),
        title: const Text(
          'My Orders',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: userId == null
          ? const Center(
              child: Text(
                'User not logged in.',
                style: TextStyle(fontSize: 18, color: Colors.brown),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('orders')
                  .where('buyerId', isEqualTo: userId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // **Fix: Ensure orders list persists even when snapshot is temporarily empty**
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  _orders = snapshot.data!.docs;
                }

                if (_orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'No orders found.',
                      style: TextStyle(fontSize: 18, color: Colors.brown),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final orderData = order.data() as Map<String, dynamic>?;

                    if (orderData == null) return const SizedBox();

                    final productName = orderData['productName'] ?? 'Unknown Product';
                    final quantity = orderData['quantity'] ?? 0;
                    final totalPrice = (orderData['totalPrice'] as num?)?.toDouble() ?? 0.0;
                    final status = orderData['status'] ?? 'Pending';
                    final timestamp = orderData['timestamp'] != null
                        ? (orderData['timestamp'] as Timestamp).toDate()
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
                          /// **Product Name**
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A3D2B),
                            ),
                          ),
                          const SizedBox(height: 6),

                          /// **Quantity & Price**
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Quantity: $quantity",
                                style: const TextStyle(fontSize: 16, color: Colors.brown),
                              ),
                              Text(
                                "Total: \$${totalPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8B5E3C)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          /// **Date Formatting**
                          if (timestamp != null)
                            Text(
                              "Date: ${DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp)}",
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),

                          /// **Status with Icon**
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _getStatusIcon(status),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Status: $status",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(status),
                                    ),
                                  ),
                                ],
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

  /// **Get Icon for Order Status**
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

  /// **Get Color for Order Status**
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
}
