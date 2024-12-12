import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userId; // Nullable userId to handle initialization properly

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid; // Get the logged-in user's ID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: userId == null
          ? const Center(child: Text('User not logged in.'))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('orders')
                  .where('buyerId', isEqualTo: userId) // Filter by the buyer's ID
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                }

                final orders = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderData = order.data() as Map<String, dynamic>?;

                    if (orderData == null) {
                      return const SizedBox();
                    }

                    final productName = orderData['productName'] ?? 'Unknown Product';
                    final quantity = orderData['quantity'] ?? 0;
                    final totalPrice = orderData['totalPrice'] ?? 0.0;
                    final status = orderData['status'] ?? 'Pending';
                    final timestamp = orderData['timestamp'] != null
                        ? (orderData['timestamp'] as Timestamp).toDate()
                        : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(productName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity: $quantity'),
                            Text('Total: \$${totalPrice.toStringAsFixed(2)}'),
                            if (timestamp != null)
                              Text('Date: ${timestamp.toLocal()}'),
                            Text('Status: $status'),
                          ],
                        ),
                        trailing: Icon(
                          status == 'Completed'
                              ? Icons.check_circle
                              : status == 'Cancelled'
                                  ? Icons.cancel
                                  : Icons.hourglass_empty,
                          color: status == 'Completed'
                              ? Colors.green
                              : status == 'Cancelled'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
