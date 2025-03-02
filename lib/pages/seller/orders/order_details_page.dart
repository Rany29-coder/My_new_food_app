import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_model.dart' as my_new_food_app_order;

/// Same palette constants as the rest of your UI
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
    setState(() => _isLoading = true);

    try {
      await _firestore.collection('orders').doc(widget.order.id).update({
        'status': status,
      });

      setState(() {
        widget.order.status = status; // Update the local state
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order status: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Off-white background
      backgroundColor: kBackgroundColor,

      /// Soft Brown AppBar
      appBar: AppBar(
        backgroundColor: kSoftBrown,
        title: const Text('Order Details', style: TextStyle(color: Colors.white)),
      ),

      /// Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailText('Order ID: ${widget.order.id}'),
            _buildDetailText('Customer ID: ${widget.order.buyerId}'),
            _buildDetailText('Product Name: ${widget.order.productName}'),
            _buildDetailText('Quantity: ${widget.order.quantity}'),
            _buildDetailText(
                'Total Amount: \$${widget.order.totalPrice.toStringAsFixed(2)}'),
            _buildDetailText('Status: ${widget.order.status}'),
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildStatusButton('Mark as Processing', 'Processing'),
              _buildStatusButton('Mark as Completed', 'Completed'),
              _buildStatusButton('Mark as Cancelled', 'Cancelled'),
            ],
          ],
        ),
      ),
    );
  }

  /// Reusable text widget with dark brown color
  Widget _buildDetailText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: kDarkBrown),
      ),
    );
  }

  /// Reusable ElevatedButton for updating status
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
}
