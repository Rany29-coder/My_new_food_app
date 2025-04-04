import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'celebration_page.dart';

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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _cardController = TextEditingController(text: "1234123412341234");
  final TextEditingController _expiryController = TextEditingController(text: "12/12");
  final TextEditingController _cvcController = TextEditingController(text: "121");

  @override
  void initState() {
    super.initState();
    _fetchRelatedProducts();
  }

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
        SnackBar(content: Text('Error fetching related products: \$e')),
      );
    }
  }

  void _showPaymentBottomSheet() {
    final locale = AppLocalizations.of(context)!;
    final totalPrice = (widget.productPrice ?? 0.0) * _quantity;
    final totalSaved = ((widget.originalPrice ?? 0.0) - (widget.productPrice ?? 0.0)) * _quantity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Wrap(
            runSpacing: 16,
            children: [
              Text(locale.paymentDetails, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(locale.youAreSaving(totalSaved.toStringAsFixed(2)), style: const TextStyle(color: Colors.green)),
              Text(locale.totalPrice(totalPrice.toStringAsFixed(2))),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: locale.nameOnCard, border: const OutlineInputBorder()),
              ),
              TextField(
                controller: _zipController,
                decoration: InputDecoration(labelText: locale.zipCode, border: const OutlineInputBorder()),
              ),
              TextField(
                controller: _cardController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: locale.cardNumber, border: const OutlineInputBorder()),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(labelText: locale.mmYy, border: const OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvcController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: locale.cvc, border: const OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _placeOrder();
                },
                icon: const Icon(Icons.lock),
                label: Text(locale.payNow),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  Widget _buildRelatedProducts() {
    final locale = AppLocalizations.of(context)!;

    return _relatedProducts.isEmpty
        ? Text(locale.noRelatedProducts)
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
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
                child: Column(
                  children: [
                    Image.network(product['imageUrl'], height: 80, fit: BoxFit.cover),
                    Text(product['productName']),
                  ],
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5E3C),
        title: Text(locale.productDetails),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(widget.productName ?? 'Product Name',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5A3D2B))),
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
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              locale.foodSaved((widget.weight! * _quantity).toStringAsFixed(2)),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _showPaymentBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5E3C),
                foregroundColor: Colors.white,
              ),
              child: Text(locale.buyNow),
            ),
            const SizedBox(height: 16),
            Text(locale.relatedProducts, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildRelatedProducts(),
          ],
        ),
      ),
    );
  }
}