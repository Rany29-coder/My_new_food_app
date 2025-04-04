import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'order_model.dart' as my_new_food_app_order;

const kBackgroundColor = Color(0xFFFAF3E0);
const kDarkBrown = Color(0xFF5A3D2B);
const kSoftBrown = Color(0xFF8B5E3C);

class OrderDetailsPage extends StatefulWidget {
  final my_new_food_app_order.Order order;

  const OrderDetailsPage({required this.order, Key? key}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateOrderStatus(String status) async {
    final locale = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('orders').doc(widget.order.id).update({
        'status': status,
      });

      setState(() {
        widget.order.status = status;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.statusUpdated(status))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.statusUpdateError(e.toString()))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kSoftBrown,
        title: Text(locale.orderDetails, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailText('${locale.orderId}: ${widget.order.id}'),
            _buildDetailText('${locale.customer}: ${widget.order.buyerId}'),
            _buildDetailText('${locale.productName}: ${widget.order.productName}'),
            _buildDetailText('${locale.quantity}: ${widget.order.quantity}'),
            _buildDetailText('${locale.total}: \$${widget.order.totalPrice.toStringAsFixed(2)}'),
            _buildDetailText('${locale.status}: ${_localizedStatus(widget.order.status, locale)}'),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildStatusButton(locale.markAsProcessing, 'Processing'),
              _buildStatusButton(locale.markAsCompleted, 'Completed'),
              _buildStatusButton(locale.markAsCancelled, 'Cancelled'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: kDarkBrown),
      ),
    );
  }

  Widget _buildStatusButton(String label, String status) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () => _updateOrderStatus(status),
        style: ElevatedButton.styleFrom(
          backgroundColor: kSoftBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      case 'processing':
        return locale.statusProcessing;
      default:
        return status;
    }
  }
}
