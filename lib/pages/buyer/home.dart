import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_new_food_app/pages/buyer/details.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = '';
  String selectedCategoryKey = 'all';

  final List<String> categoryKeys = ['all', 'frozen', 'dairy', 'baked', 'snacks'];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userName = userData['name'] ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    // Map category keys to their localized labels
    final Map<String, String> localizedCategories = {
      'all': locale.all,
      'frozen': locale.frozen,
      'dairy': locale.dairy,
      'baked': locale.baked,
      'snacks': locale.snacks,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFFCF5EE),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${locale.hello} $userName!",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E342E),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Color(0xFF71452E)),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              locale.shopNow,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
              ),
            ),
            Text(
              locale.readyToSave,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8C5C41),
              ),
            ),
            const SizedBox(height: 20),

            // Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categoryKeys.map((key) {
                  final isSelected = selectedCategoryKey == key;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedCategoryKey = key);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF71452E) : const Color(0xFFEDEAE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        localizedCategories[key] ?? key,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.white : const Color(0xFF4E342E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Products
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        locale.noProductsFound,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  final products = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>?;
                    if (data == null) return false;
                    return selectedCategoryKey == 'all' ||
                        (data['category']?.toString().toLowerCase() == selectedCategoryKey);
                  }).toList();

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final data = product.data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Details(
                                ownerId: data['userId'],
                                productId: product.id,
                                productName: data['productName'],
                                productPrice: data['price'],
                                productDetails: data['details'],
                                productImageUrl: data['imageUrl'],
                                originalPrice: data['originalPrice'],
                                weight: data['weight'],
                                rating: data['rating'],
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
                                    data['imageUrl'],
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  data['productName'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4E342E),
                                  ),
                                ),
                                Text(
                                  data['details'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8C5C41),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "\$${data['price']}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF009688),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "\$${data['originalPrice']}",
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
