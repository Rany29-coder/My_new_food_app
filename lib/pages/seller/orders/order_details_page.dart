import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_model.dart' as my_new_food_app_order;

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
    setState(() {
      _isLoading = true;
    });

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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${widget.order.id}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Customer ID: ${widget.order.buyerId}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Product Name: ${widget.order.productName}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Quantity: ${widget.order.quantity}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Total Amount: \$${widget.order.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Status: ${widget.order.status}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading) ...[
              ElevatedButton(
                onPressed: () => _updateOrderStatus('Processing'),
                child: const Text('Mark as Processing'),
              ),
              ElevatedButton(
                onPressed: () => _updateOrderStatus('Completed'),
                child: const Text('Mark as Completed'),
              ),
              ElevatedButton(
                onPressed: () => _updateOrderStatus('Cancelled'),
                child: const Text('Mark as Cancelled'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
