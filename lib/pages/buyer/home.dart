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
  bool icecream = false, pizza = false, burger = false, diet = false;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void selectCategory(String category) {
    setState(() {
      icecream = category == 'icecream';
      pizza = category == 'pizza';
      burger = category == 'burger';
      diet = category == 'diet';
    });
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
      body: Container(
        margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hello, $userName!",
                  style: AppWidget.boldTextFieldStyle,
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_cart, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Shop now!",
                  style: AppWidget.headlineTextFieldStyle,
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Ready to Save the food!",
                  style: AppWidget.lightlineTextFieldStyle,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppWidget.showItem(
                  imagePath: "images/diet.png",
                  isSelected: icecream,
                  onTap: () {
                    selectCategory('icecream');
                  },
                ),
                AppWidget.showItem(
                  imagePath: "images/diet.png",
                  isSelected: diet,
                  onTap: () {
                    selectCategory('diet');
                  },
                ),
                AppWidget.showItem(
                  imagePath: "images/diet.png",
                  isSelected: burger,
                  onTap: () {
                    selectCategory('burger');
                  },
                ),
                AppWidget.showItem(
                  imagePath: "images/diet.png",
                  isSelected: pizza,
                  onTap: () {
                    selectCategory('pizza');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
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

                  final products = snapshot.data!.docs;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final productData =
                          product.data() as Map<String, dynamic>?;
                      if (productData == null) {
                        return Container();
                      }

                      // Debug log for missing fields
                      if (!productData.containsKey('productName') ||
                          !productData.containsKey('originalPrice') ||
                          !productData.containsKey('price') ||
                          !productData.containsKey('details') ||
                          !productData.containsKey('imageUrl')) {
                        debugPrint(
                            'Missing required fields in product: ${product.id}');
                        return Container();
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Details(
                                ownerId: productData['userId'],
                                productId: product.id, // Pass the product ID
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
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    productData['imageUrl'],
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    productData['productName'],
                                    style: AppWidget.semiboldTextFieldStyle,
                                  ),
                                  Text(
                                    productData['details'],
                                    style: AppWidget.lightlineTextFieldStyle,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${productData['originalPrice']} جنيه",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.red,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${productData['price']} جنيه",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
