import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  final String productId;
  final String? productName; // Made nullable to handle null values
  final double? productPrice; // Made nullable
  final double? originalPrice; // Made nullable
  final String? productDetails; // Made nullable
  final String? productImageUrl; // Made nullable
  final String? ownerId; // Made nullable
  final double? weight; // Made nullable
  final double? rating; // Made nullable

  const Details({
    required this.productId,
    this.productName,
    this.productPrice,
    this.originalPrice,
    this.productDetails,
    this.productImageUrl,
    this.ownerId,
    this.weight,
    this.rating,
    Key? key,
  }) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int _quantity = 1;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final order = {
        'orderId': DateTime.now().millisecondsSinceEpoch.toString(),
        'buyerId': user.uid,
        'ownerId': widget.ownerId ?? '',
        'productId': widget.productId,
        'productName': widget.productName ?? 'Unknown Product',
        'quantity': _quantity,
        'status': 'Pending',
        'totalPrice': (widget.productPrice ?? 0.0) * _quantity,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('orders').add(order);

      final storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.ownerId)
          .get();

      if (storeDoc.exists) {
        final totalSales = (storeDoc.data()?['totalSales'] ?? 0).toDouble();
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(widget.ownerId)
            .update({
          'totalSales': totalSales + order['totalPrice'],
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            widget.productImageUrl != null
                ? Image.network(
                    widget.productImageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : const Text('No image available'),
            const SizedBox(height: 16),
            Text(
              widget.productName ?? 'Product Name Unavailable',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.productDetails ?? 'No details available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              widget.originalPrice != null
                  ? 'Original Price: \$${widget.originalPrice!.toStringAsFixed(2)}'
                  : 'Original Price: N/A',
              style: const TextStyle(
                fontSize: 18,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Text(
              widget.productPrice != null
                  ? 'Discounted Price: \$${widget.productPrice!.toStringAsFixed(2)}'
                  : 'Discounted Price: N/A',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.weight != null
                  ? 'Weight: ${widget.weight} kg'
                  : 'Weight: N/A',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              widget.rating != null
                  ? 'Rating: ${widget.rating} / 5'
                  : 'Rating: N/A',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _decrementQuantity,
                  icon: const Icon(Icons.remove),
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 24)),
                IconButton(
                  onPressed: _incrementQuantity,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _placeOrder,
              child: const Text('Order Now'),
            ),
            const SizedBox(height: 8),
            Text(
              widget.originalPrice != null && widget.productPrice != null
                  ? 'You are saving \$${((widget.originalPrice! - widget.productPrice!) * _quantity).toStringAsFixed(2)}'
                  : 'Saving details unavailable',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            Text(
              widget.weight != null
                  ? 'You are saving ${(widget.weight! * _quantity).toStringAsFixed(2)} kg of food'
                  : 'Weight saving details unavailable',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: Don\'t take something without our label',
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
