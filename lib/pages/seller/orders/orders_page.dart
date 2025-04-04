import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'order_details_page.dart';
import 'order_model.dart' as my_new_food_app_order;

/// Same color constants
const kBackgroundColor = Color(0xFFFAF3E0);
const kDarkBrown = Color(0xFF5A3D2B);
const kSoftBrown = Color(0xFF8B5E3C);

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _firestore = FirebaseFirestore.instance;
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kSoftBrown,
        title: Text(
          locale.myOrders,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('orders')
            .where('ownerId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var orders = snapshot.data?.docs
                  .map((doc) => my_new_food_app_order.Order.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ))
                  .toList() ??
              [];

          if (orders.isEmpty) {
            return Center(
              child: Text(
                locale.noOrdersFound,
                style: const TextStyle(color: kDarkBrown, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    '${locale.orderId}: ${order.id}',
                    style: const TextStyle(
                      color: kDarkBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${locale.customer}: ${order.buyerId}  •  '
                    '${locale.total}: \$${order.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(color: kSoftBrown),
                  ),
                  trailing: Text(
                    _localizedStatus(order.status, locale),
                    style: const TextStyle(
                      color: kDarkBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(order: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _localizedStatus(String status, AppLocalizations locale) {
    switch (status.toLowerCase()) {
      case 'pending':
        return locale.statusPending;
      case 'completed':
        return locale.statusCompleted;
      case 'cancelled':
        return locale.statusCancelled;
      default:
        return status;
    }
  }
}
