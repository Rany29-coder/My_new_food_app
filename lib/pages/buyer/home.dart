import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_new_food_app/pages/buyer/details.dart';

import 'package:my_new_food_app/widget/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = '';
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = userData['name'] ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF5EE), // Light beige background
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with User Greeting and Cart Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hello, $userName!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E342E),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Color(0xFF71452E)),
                  onPressed: () {
                    // Navigate to cart page
                  },
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              "Shop now!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
              ),
            ),
            Text(
              "Ready to save the food!",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8C5C41),
              ),
            ),
            const SizedBox(height: 20),

            // Category Selection (Rounded Buttons)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Frozen', 'Dairy', 'Baked', 'Snacks'].map((category) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedCategory == category
                            ? Color(0xFF71452E) // Selected category color
                            : Color(0xFFEDEAE7), // Unselected category color
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          color: selectedCategory == category
                              ? Colors.white
                              : Color(0xFF4E342E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Product Grid (Firestore)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No products found. Please check your database.",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  final products = snapshot.data!.docs.where((doc) {
                    final productData = doc.data() as Map<String, dynamic>?;
                    if (productData == null) return false;
                    return selectedCategory == 'All' ||
                        (productData.containsKey('category') &&
                            productData['category'] == selectedCategory);
                  }).toList();

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two-column grid layout
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final productData = product.data() as Map<String, dynamic>?;

                      if (productData == null) {
                        return Container();
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Details(
                                ownerId: productData['userId'],
                                productId: product.id,
                                productName: productData['productName'],
                                productPrice: productData['price'],
                                productDetails: productData['details'],
                                productImageUrl: productData['imageUrl'],
                                originalPrice: productData['originalPrice'],
                                weight: productData['weight'],
                                rating: productData['rating'],
                              ),
                            ),
                          );
                        },
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    productData['imageUrl'],
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  productData['productName'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4E342E),
                                  ),
                                ),
                                Text(
                                  productData['details'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8C5C41),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "\$${productData['price']}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF009688),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "\$${productData['originalPrice']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.red,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
