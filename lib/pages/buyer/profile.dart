import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_new_food_app/pages/buyer/order.dart' as myOrder;
import 'package:my_new_food_app/pages/settings.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userName;
  String? userEmail;
  String? profileImageUrl;
  double walletBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData =
          await _firestore.collection('users').doc(user.uid).get();

      if (userData.exists) {
        setState(() {
          userName = userData['name'] ?? 'User';
          userEmail = userData['email'] ?? 'No email';
          profileImageUrl = userData['profileImageUrl'] ??
              'https://www.w3schools.com/w3images/avatar2.png';
          walletBalance = (userData['wallet'] ?? 0.0).toDouble();
        });
      }
    }
  }

  Future<void> _logout() async {
    final locale = AppLocalizations.of(context)!;
    try {
      await _auth.signOut();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${locale.logoutError}: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        title: Text(locale.profile),
        backgroundColor: const Color(0xFF8B5E3C),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileImageUrl ??
                        'https://www.w3schools.com/w3images/avatar2.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName ?? locale.loading,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A3D2B)),
                  ),
                  Text(
                    userEmail ?? locale.noEmail,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(locale.editProfile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // Navigate to edit profile page
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// Wallet Balance
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    locale.walletBalance,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A3D2B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${walletBalance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.brown),
              title: Text(locale.myOrders),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const myOrder.Order()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: Text(locale.settings),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(locale.rateUs),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle rating
              },
            ),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: Text(locale.logout),
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
