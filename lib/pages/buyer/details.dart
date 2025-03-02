import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'celebration_page.dart'; // Import the new page

class Details extends StatefulWidget {
  final String productId;
  final String? productName;
  final double? productPrice;
  final double? originalPrice;
  final String? productDetails;
  final String? productImageUrl;
  final String? ownerId;
  final double? weight;
  final double? rating;

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
  bool _isLoading = true;
  List<DocumentSnapshot> _relatedProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchRelatedProducts();
  }

  /// Fetch related products dynamically
  Future<void> _fetchRelatedProducts() async {
    try {
      final relatedSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .limit(4)
          .get();

      setState(() {
        _relatedProducts = relatedSnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching related products: $e')),
      );
    }
  }

  /// Place Order
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      /// Navigate to celebration page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CelebrationPage(
            productName: widget.productName ?? 'Your Product',
            totalSaved: ((widget.originalPrice ?? 0) - (widget.productPrice ?? 0)) * _quantity,
            foodSaved: (widget.weight ?? 0) * _quantity,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5E3C),
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(widget.productImageUrl ?? 'https://via.placeholder.com/400'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),

            /// Product Name & Price
            Text(widget.productName ?? 'Product Name',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A3D2B))),
            const SizedBox(height: 4),
            Row(
              children: [
                if (widget.originalPrice! > widget.productPrice!)
                  Text('\$${widget.originalPrice}',
                      style: const TextStyle(
                          fontSize: 18,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey)),
                const SizedBox(width: 8),
                Text('\$${widget.productPrice}',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),

            /// Quantity Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      if (_quantity > 1) _quantity--;
                    });
                  },
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// Sustainability Impact
            Text(
              'Buying this product saves ${(widget.weight! * _quantity).toStringAsFixed(2)} kg of food!',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            /// CTA Button (Add to Cart)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5E3C),
                foregroundColor: Colors.white,
              ),
              onPressed: _placeOrder,
              child: const Text('Add to Cart'),
            ),
            const SizedBox(height: 16),

            /// Related Products Section
            const Text('Related Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildRelatedProducts(),
          ],
        ),
      ),
    );
  }

  /// Builds Related Products Grid using the same format as Home Page
  Widget _buildRelatedProducts() {
    return _relatedProducts.isEmpty
        ? const Text('No related products available.')
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Matches the Home Page layout
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: _relatedProducts.length,
            itemBuilder: (context, index) {
              final product = _relatedProducts[index].data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Details(
                        productId: _relatedProducts[index].id,
                        productName: product['productName'],
                        productPrice: (product['price'] as num?)?.toDouble(),
                        originalPrice: (product['originalPrice'] as num?)?.toDouble(),
                        productDetails: product['details'],
                        productImageUrl: product['imageUrl'],
                        ownerId: product['userId'],
                        weight: (product['weight'] as num?)?.toDouble(),
                        rating: (product['rating'] as num?)?.toDouble(),
                      ),
                    ),
                  );
                },
                child: _buildProductCard(product),
              );
            },
          );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      child: Column(
        children: [
          Image.network(product['imageUrl'], height: 80, fit: BoxFit.cover),
          Text(product['productName']),
        ],
      ),
    );
  }
}
