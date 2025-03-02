import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart' as pc
    show PieChart, ChartType, LegendPosition, ChartValuesOptions, LegendOptions;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Define color constants to match your Onboard screen
const kBackgroundColor = Color(0xFFFAF3E0); // Off-white from Onboard
const kDarkBrown = Color(0xFF5A3D2B);
const kSoftBrown = Color(0xFF8B5E3C);

class StoreDashboard extends StatefulWidget {
  const StoreDashboard({Key? key}) : super(key: key);

  @override
  _StoreDashboardState createState() => _StoreDashboardState();
}

class _StoreDashboardState extends State<StoreDashboard> {
  final _firestore = FirebaseFirestore.instance;

  // Seller metrics
  double _totalSales = 0.0;
  int _totalOrders = 0;
  double _averageOrderValue = 0.0;
  int _activeListings = 0;
  double _totalFoodSaved = 0.0;

  // Community metrics
  double _communityFoodSaved = 0.0;
  double _communityMoneySaved = 0.0;

  bool _isLoading = true;
  List<LeaderboardEntry> _topSellers = [];

  // Pie chart data
  Map<String, double> _productSalesMap = {};
  Map<String, String> _productNames = {};

  // Bar chart data (# of orders each month)
  Map<String, int> _ordersByMonth = {};

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _fetchLeaderboard().then((_) => _fetchCommunityImpact());
  }

  /// 1) Fetch all orders for this seller
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

  /// 2) Calculate stats & # of orders per month
  Future<void> _calculateStats(
    List<QueryDocumentSnapshot> orders,
    List<QueryDocumentSnapshot> products,
  ) async {
    double totalSales = 0.0;
    int totalOrders = orders.length;
    double totalFoodSaved = 0.0;

    final productMap = {
      for (var p in products) p.id: p.data() as Map<String, dynamic>?
    };

    for (var orderDoc in orders) {
      final data = orderDoc.data() as Map<String, dynamic>;
      final orderTotal = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
      final productId = data['productId'] as String?;
      final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

      totalSales += orderTotal;

      // For Pie Chart
      if (productId != null && productMap.containsKey(productId)) {
        final productData = productMap[productId]!;
        final weight = (productData['weight'] as num?)?.toDouble() ?? 0.0;
        final productName = productData['productName'] ?? 'Unknown Product';

        totalFoodSaved += weight * quantity;
        _productNames[productId] = productName;

        _productSalesMap[productId] =
            (_productSalesMap[productId] ?? 0) + orderTotal;
      }

      // For monthly orders bar chart
      if (data['timestamp'] is Timestamp) {
        final Timestamp ts = data['timestamp'];
        final DateTime date = ts.toDate();
        final String monthKey = DateFormat('yyyy-MM').format(date);
        _ordersByMonth[monthKey] = (_ordersByMonth[monthKey] ?? 0) + 1;
      }
    }

    if (mounted) {
      setState(() {
        _totalSales = totalSales;
        _totalOrders = totalOrders;
        _averageOrderValue =
            (totalOrders > 0) ? (totalSales / totalOrders) : 0.0;
        _activeListings = products.length;
        _totalFoodSaved = totalFoodSaved;
        _isLoading = false;
      });
    }
  }

  /// 3) Community Impact
  Future<void> _fetchCommunityImpact() async {
    try {
      double totalFoodSaved = 0.0;
      double totalMoneySaved = 0.0;

      for (var seller in _topSellers) {
        totalFoodSaved += seller.totalFoodSaved;
      }

      final ordersSnapshot = await _firestore.collection('orders').get();
      final productsSnapshot = await _firestore.collection('products').get();

      for (var order in ordersSnapshot.docs) {
        final data = order.data();
        final productId = data['productId'] as String?;
        final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

        if (productId != null) {
          final productDoc = productsSnapshot.docs.firstWhere(
            (p) => p.id == productId,
            orElse: () => throw Exception('Product not found'),
          );

          if (productDoc != null) {
            final productData = productDoc.data();
            final originalPrice =
                (productData['originalPrice'] as num?)?.toDouble() ?? 0.0;
            final currentPrice =
                (productData['price'] as num?)?.toDouble() ?? 0.0;

            totalMoneySaved += (originalPrice - currentPrice) * quantity;
          }
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

  /// 4) Leaderboard
  Future<void> _fetchLeaderboard() async {
    try {
      final sellersSnapshot = await _firestore.collection('sellers').get();
      final Map<String, LeaderboardEntry> sellerStats = {};

      for (var seller in sellersSnapshot.docs) {
        final sellerId = seller.id;
        final storeName = seller.data()['storeName'] ?? "Unknown Store";
        sellerStats[sellerId] =
            LeaderboardEntry(storeName: storeName, totalFoodSaved: 0.0);
      }

      final ordersSnapshot = await _firestore.collection('orders').get();
      final productsSnapshot = await _firestore.collection('products').get();

      for (var order in ordersSnapshot.docs) {
        final data = order.data();
        final ownerId = data['ownerId'] as String?;
        final productId = data['productId'] as String?;
        final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

        if (ownerId != null &&
            productId != null &&
            sellerStats.containsKey(ownerId)) {
          final productDoc = productsSnapshot.docs.firstWhere(
            (p) => p.id == productId,
            orElse: () => throw Exception('Product not found'),
          );

          if (productDoc != null) {
            final productData = productDoc.data();
            final weight = (productData['weight'] as num?)?.toDouble() ?? 0.0;
            sellerStats[ownerId]!.totalFoodSaved += weight * quantity;
          }
        }
      }

      // Sort & take top 5
      List<LeaderboardEntry> topSellers = sellerStats.values.toList();
      topSellers.sort((a, b) => b.totalFoodSaved.compareTo(a.totalFoodSaved));
      topSellers = topSellers.take(5).toList();

      if (mounted) {
        setState(() {
          _topSellers = topSellers;
        });
      }
    } catch (e) {
      print("⚠️ Error fetching leaderboard: $e");
    }
  }

  /// BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1) Match Onboard's BG color
      backgroundColor: kBackgroundColor,

      // 2) Soft brown appbar
      appBar: AppBar(
        backgroundColor: kSoftBrown,
        title: const Text(
          'Store Dashboard',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  _buildStatsRow(),
                  const SizedBox(height: 20),

                  // Pie chart of product sales
                  _buildPieChart(),
                  const SizedBox(height: 20),

                  // Bar chart: # of orders each month
                  _buildMonthlyOrdersBarChart(),
                  const SizedBox(height: 20),

                  // Leaderboard
                  _buildLeaderboard(),
                ],
              ),
            ),
    );
  }

  /// Stats row (horizontal scroll)
  Widget _buildStatsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
              "Total Sales", "\$${_totalSales.toStringAsFixed(2)}", Icons.attach_money),
          _buildStatCard("Total Orders", "$_totalOrders", Icons.shopping_cart),
          _buildStatCard("Avg Order Value",
              "\$${_averageOrderValue.toStringAsFixed(2)}", Icons.bar_chart),
          _buildStatCard("Food Saved", "${_totalFoodSaved.toStringAsFixed(1)} kg", Icons.eco),
          _buildStatCard("Community Food Saved",
              "${_communityFoodSaved.toStringAsFixed(1)} kg", Icons.people),
          _buildStatCard("Community Money Saved",
              "\$${_communityMoneySaved.toStringAsFixed(2)}", Icons.savings),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.white, // or a subtle brown if you prefer
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 28, color: kDarkBrown),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDarkBrown,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kSoftBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pie Chart: product-level sales
  Widget _buildPieChart() {
    if (_productSalesMap.isEmpty) {
      return Card(
        color: Colors.white,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              "No product sales data available.",
              style: TextStyle(color: kDarkBrown),
            ),
          ),
        ),
      );
    }

    final dataMap = <String, double>{};
    _productSalesMap.forEach((productId, sales) {
      final productName = _productNames[productId] ?? productId;
      dataMap[productName] = sales;
    });

    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Products & Their Sales",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kDarkBrown,
              ),
            ),
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

  /// Bar Chart: monthly orders
  Widget _buildMonthlyOrdersBarChart() {
    if (_ordersByMonth.isEmpty) {
      return Card(
        color: Colors.white,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text("No monthly orders data available.")),
        ),
      );
    }

    final sortedKeys = _ordersByMonth.keys.toList()..sort();
    final barGroups = <BarChartGroupData>[];
    double maxValue = 0;

    for (int i = 0; i < sortedKeys.length; i++) {
      final monthKey = sortedKeys[i];
      final ordersCount = _ordersByMonth[monthKey] ?? 0;
      if (ordersCount > maxValue) maxValue = ordersCount.toDouble();

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: ordersCount.toDouble(),
              color: kDarkBrown,
              width: 16,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    final suggestedMaxY = (maxValue < 5) ? 5 : maxValue + 1;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Monthly Orders",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kDarkBrown,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Number of orders placed each month.",
              style: TextStyle(fontSize: 12, color: kSoftBrown),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  groupsSpace: 20,
                  barGroups: barGroups,
                  minY: 0,
                  maxY: suggestedMaxY.toDouble(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameSize: 14,
                      axisNameWidget: const Text(
                        "Orders",
                        style: TextStyle(fontWeight: FontWeight.bold, color: kDarkBrown),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 40,
                        // label styling if needed
                        getTitlesWidget: (value, meta) {
                          // you can style the numeric labels too
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(color: kDarkBrown, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameSize: 14,
                      axisNameWidget: const Text(
                        "Month",
                        style: TextStyle(fontWeight: FontWeight.bold, color: kDarkBrown),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= sortedKeys.length) {
                            return const SizedBox();
                          }
                          final raw = sortedKeys[index]; // e.g. "2025-02"
                          final monthNum = raw.substring(5); // "02"
                          final monthInt = int.parse(monthNum);
                          final shortMonth = DateFormat('MMM')
                              .format(DateTime(0, monthInt)); // "Feb"
                          return Text(
                            shortMonth,
                            style: const TextStyle(
                                fontSize: 11, color: kDarkBrown),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Leaderboard
  Widget _buildLeaderboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🏆 Top 5 Sellers of the Month",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kDarkBrown,
          ),
        ),
        Column(
          children: _topSellers.map((seller) {
            return ListTile(
              leading: const Icon(Icons.store, color: kDarkBrown),
              title: Text(
                "Seller Name: ${seller.storeName}",
                style: const TextStyle(color: kSoftBrown),
              ),
              subtitle: Text(
                "Food Saved: ${seller.totalFoodSaved.toStringAsFixed(1)} kg",
                style: const TextStyle(color: kDarkBrown),
              ),
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
