import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_product.dart';
import 'product_model.dart';
import 'add_product.dart';

/// Reuse these palette constants to stay consistent
const kBackgroundColor = Color(0xFFFAF3E0);   // Off-white, Onboard BG
const kDarkBrown = Color(0xFF5A3D2B);        // Dark brown
const kSoftBrown = Color(0xFF8B5E3C);        // Soft brown

class ManageProducts extends StatefulWidget {
  const ManageProducts({Key? key}) : super(key: key);

  @override
  _ManageProductsState createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid ?? '';
  }

  Future<void> _deleteProduct(String productId) async {
    setState(() => _isLoading = true);

    try {
      await _firestore.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 1) Match Onboard's BG color
      backgroundColor: kBackgroundColor,

      /// 2) Style the AppBar with the Soft Brown
      appBar: AppBar(
        backgroundColor: kSoftBrown, 
        title: const Text(
          'Manage Products',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );
            },
          ),
        ],
      ),

      /// 3) Show loading or data
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('products')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                /// Handle connection states
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                /// If no data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                /// Build the List
                final products = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final productData = product.data() as Map<String, dynamic>?;

                    final productName =
                        productData?['productName'] ?? 'Unnamed Product';
                    final productPrice =
                        productData?['price']?.toString() ?? '0.0';
                    final productImage = productData?['imageUrl'] ??
                        'https://via.placeholder.com/150';

                    return Card(
                      /// 4) Slightly different card style
                      color: Colors.white, // or a very light brown if you prefer
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            productImage,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          productName,
                          style: const TextStyle(
                            color: kDarkBrown,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Price: \$${productPrice}',
                          style: const TextStyle(color: kSoftBrown),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.blue, // Keep or change to brown
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProductPage(
                                      product: Product.fromMap(
                                        productData!,
                                        product.id,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red, // Keep or change to a red/brown
                              onPressed: () async {
                                await _deleteProduct(product.id);
                              },
                            ),
                          ],
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
