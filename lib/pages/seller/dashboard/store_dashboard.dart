import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart' as pc
    show PieChart, ChartType, LegendPosition, ChartValuesOptions, LegendOptions;
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Color constants
const kBackgroundColor = Color(0xFFFAF3E0);
const kDarkBrown = Color(0xFF5A3D2B);
const kSoftBrown = Color(0xFF8B5E3C);

class StoreDashboard extends StatefulWidget {
  const StoreDashboard({Key? key}) : super(key: key);

  @override
  _StoreDashboardState createState() => _StoreDashboardState();
}

class _StoreDashboardState extends State<StoreDashboard> {
  final _firestore = FirebaseFirestore.instance;

  double _totalSales = 0.0;
  int _totalOrders = 0;
  double _averageOrderValue = 0.0;
  double _totalFoodSaved = 0.0;
  double _communityFoodSaved = 0.0;
  double _communityMoneySaved = 0.0;

  bool _isLoading = true;
  List<LeaderboardEntry> _topSellers = [];

  Map<String, double> _productSalesMap = {};
  Map<String, String> _productNames = {};
  Map<String, int> _ordersByMonth = {};

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _fetchLeaderboard().then((_) => _fetchCommunityImpact());
  }

  Future<void> _fetchDashboardData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ordersSnapshot = await _firestore
            .collection('orders')
            .where('ownerId', isEqualTo: user.uid)
            .get();

        final productsSnapshot = await _firestore
            .collection('products')
            .where('userId', isEqualTo: user.uid)
            .get();

        await _calculateStats(ordersSnapshot.docs, productsSnapshot.docs);
      }
    } catch (e) {
      print("⚠️ Error fetching seller data: $e");
    }
  }

  Future<void> _calculateStats(List<QueryDocumentSnapshot> orders, List<QueryDocumentSnapshot> products) async {
    double totalSales = 0.0;
    int totalOrders = orders.length;
    double totalFoodSaved = 0.0;

    final productMap = {
      for (var p in products) p.id: p.data() as Map<String, dynamic>
    };

    for (var orderDoc in orders) {
      final data = orderDoc.data() as Map<String, dynamic>;
      final orderTotal = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
      final productId = data['productId'] as String?;
      final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

      totalSales += orderTotal;

      if (productId != null && productMap.containsKey(productId)) {
        final productData = productMap[productId]!;
        final weight = (productData['weight'] as num?)?.toDouble() ?? 0.0;
        final productName = productData['productName'] ?? 'Unknown Product';

        totalFoodSaved += weight * quantity;
        _productNames[productId] = productName;
        _productSalesMap[productId] =
            (_productSalesMap[productId] ?? 0) + orderTotal;
      }

      if (data['timestamp'] is Timestamp) {
        final DateTime date = (data['timestamp'] as Timestamp).toDate();
        final String monthKey = DateFormat('yyyy-MM').format(date);
        _ordersByMonth[monthKey] = (_ordersByMonth[monthKey] ?? 0) + 1;
      }
    }

    if (mounted) {
      setState(() {
        _totalSales = totalSales;
        _totalOrders = totalOrders;
        _averageOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0.0;
        _totalFoodSaved = totalFoodSaved;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCommunityImpact() async {
    try {
      double totalFoodSaved = 0.0;
      double totalMoneySaved = 0.0;

      for (var seller in _topSellers) {
        totalFoodSaved += seller.totalFoodSaved;
      }

      final ordersSnapshot = await _firestore.collection('orders').get();
      final productsSnapshot = await _firestore.collection('products').get();
      final productMap = {
        for (var doc in productsSnapshot.docs) doc.id: doc.data()
      };

      for (var order in ordersSnapshot.docs) {
        final data = order.data();
        final productId = data['productId'] as String?;
        final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

        if (productId != null && productMap.containsKey(productId)) {
          final productData = productMap[productId]!;
          final originalPrice = (productData['originalPrice'] as num?)?.toDouble() ?? 0.0;
          final currentPrice = (productData['price'] as num?)?.toDouble() ?? 0.0;
          totalMoneySaved += (originalPrice - currentPrice) * quantity;
        }
      }

      if (mounted) {
        setState(() {
          _communityFoodSaved = totalFoodSaved;
          _communityMoneySaved = totalMoneySaved;
        });
      }
    } catch (e) {
      print("⚠️ Error updating community impact: $e");
    }
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final sellersSnapshot = await _firestore.collection('sellers').get();
      final Map<String, LeaderboardEntry> sellerStats = {
        for (var s in sellersSnapshot.docs)
          s.id: LeaderboardEntry(
            storeName: s.data()['storeName'] ?? 'Unknown Store',
            totalFoodSaved: 0.0,
          )
      };

      final ordersSnapshot = await _firestore.collection('orders').get();
      final productsSnapshot = await _firestore.collection('products').get();
      final productMap = {
        for (var doc in productsSnapshot.docs) doc.id: doc.data()
      };

      for (var order in ordersSnapshot.docs) {
        final data = order.data();
        final ownerId = data['ownerId'] as String?;
        final productId = data['productId'] as String?;
        final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

        if (ownerId != null && productId != null && sellerStats.containsKey(ownerId)) {
          if (productMap.containsKey(productId)) {
            final productData = productMap[productId]!;
            final weight = (productData['weight'] as num?)?.toDouble() ?? 0.0;
            sellerStats[ownerId]!.totalFoodSaved += weight * quantity;
          }
        }
      }

      final topSellers = sellerStats.values.toList()
        ..sort((a, b) => b.totalFoodSaved.compareTo(a.totalFoodSaved));

      if (mounted) {
        setState(() {
          _topSellers = topSellers.take(5).toList();
        });
      }
    } catch (e) {
      print("⚠️ Error fetching leaderboard: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kSoftBrown,
        title: Text(locale.storeDashboardTitle, style: const TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(locale),
                  const SizedBox(height: 20),
                  _buildPieChart(locale),
                  const SizedBox(height: 20),
                  _buildLeaderboard(locale),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsRow(AppLocalizations locale) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(locale.totalSales, "\$${_totalSales.toStringAsFixed(2)}", Icons.attach_money),
          _buildStatCard(locale.totalOrders, "$_totalOrders", Icons.shopping_cart),
          _buildStatCard(locale.averageOrderValue, "\$${_averageOrderValue.toStringAsFixed(2)}", Icons.bar_chart),
          _buildStatCard(locale.foodSaved(''), "${_totalFoodSaved.toStringAsFixed(1)} kg", Icons.eco),
          _buildStatCard(locale.communityFoodSaved, "${_communityFoodSaved.toStringAsFixed(1)} kg", Icons.people),
          _buildStatCard(locale.communityMoneySaved, "\$${_communityMoneySaved.toStringAsFixed(2)}", Icons.savings),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 28, color: kDarkBrown),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kDarkBrown)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kSoftBrown)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(AppLocalizations locale) {
    if (_productSalesMap.isEmpty) {
      return _noDataCard(locale.noProductSalesData);
    }

    final dataMap = {
      for (var entry in _productSalesMap.entries)
        _productNames[entry.key] ?? entry.key: entry.value
    };

    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(locale.productsSalesTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkBrown)),
            const SizedBox(height: 16),
            pc.PieChart(
              dataMap: dataMap,
              chartType: pc.ChartType.disc,
              chartRadius: 200,
              animationDuration: const Duration(milliseconds: 800),
              legendOptions: const pc.LegendOptions(
                showLegends: true,
                legendPosition: pc.LegendPosition.right,
              ),
              chartValuesOptions: const pc.ChartValuesOptions(
                showChartValuesInPercentage: false,
                showChartValuesOutside: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noDataCard(String message) => Card(
        color: Colors.white,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: Text(message, style: const TextStyle(color: kDarkBrown))),
        ),
      );

  Widget _buildLeaderboard(AppLocalizations locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.topSellersTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkBrown)),
        Column(
          children: _topSellers.map((seller) {
            return ListTile(
              leading: const Icon(Icons.store, color: kDarkBrown),
              title: Text("${locale.sellerName}: ${seller.storeName}", style: const TextStyle(color: kSoftBrown)),
              subtitle: Text(locale.foodSaved(seller.totalFoodSaved.toStringAsFixed(1)), style: const TextStyle(color: kDarkBrown)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class LeaderboardEntry {
  String storeName;
  double totalFoodSaved;

  LeaderboardEntry({required this.storeName, required this.totalFoodSaved});
}
