import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../orders/orders_page.dart';

class StoreDashboard extends StatefulWidget {
  const StoreDashboard({Key? key}) : super(key: key);

  @override
  _StoreDashboardState createState() => _StoreDashboardState();
}

class _StoreDashboardState extends State<StoreDashboard> {
  final _firestore = FirebaseFirestore.instance;
  double _totalSales = 0.0;
  int _activeListings = 0;
  List<ProductSales> _popularProducts = [];
  List<Sales> _salesData = [];

  @override
  void initState() {
    super.initState();
    _fetchTotalSales();
    _fetchSalesData();
    _fetchActiveListings();
    _fetchPopularProductsData();
  }

  /// Fetch Total Sales for this Store
  Future<void> _fetchTotalSales() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ordersSnapshot = await _firestore
            .collection('orders')
            .where('ownerId', isEqualTo: user.uid)
            .get();

        double totalSales = 0.0;

        for (var doc in ordersSnapshot.docs) {
          final orderData = doc.data();
          totalSales += (orderData['totalPrice'] as num?)?.toDouble() ?? 0.0;
        }

        setState(() {
          _totalSales = totalSales;
        });
      }
    } catch (e) {
      print("Error fetching total sales: $e");
    }
  }

  /// Fetch Active Listings for this Store
  Future<void> _fetchActiveListings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final productsSnapshot = await _firestore
            .collection('products')
            .where('userId', isEqualTo: user.uid)
            .get();

        setState(() {
          _activeListings = productsSnapshot.docs.length;
        });
      }
    } catch (e) {
      print("Error fetching active listings: $e");
    }
  }

  /// Fetch Sales Data for Line Chart
  Future<void> _fetchSalesData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ordersSnapshot = await _firestore
            .collection('orders')
            .where('ownerId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: false)
            .get();

        Map<DateTime, int> salesMap = {};
        for (var doc in ordersSnapshot.docs) {
          final orderData = doc.data();
          final timestamp = orderData['timestamp'] as Timestamp;
          final date = DateTime(timestamp.toDate().year,
              timestamp.toDate().month, timestamp.toDate().day);

          salesMap[date] = (salesMap[date] ?? 0) + 1;
        }

        final salesData = salesMap.entries.map((entry) {
          return Sales(entry.key, entry.value);
        }).toList();

        setState(() {
          _salesData = salesData;
        });
      }
    } catch (e) {
      print("Error fetching sales data: $e");
    }
  }

  /// Fetch Popular Products Data
  Future<void> _fetchPopularProductsData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ordersSnapshot = await _firestore
            .collection('orders')
            .where('ownerId', isEqualTo: user.uid)
            .get();

        Map<String, int> productsMap = {};
        for (var doc in ordersSnapshot.docs) {
          final productId = doc.data()['productId'] as String;
          productsMap[productId] = (productsMap[productId] ?? 0) + 1;
        }

        final popularProducts = <ProductSales>[];
        for (var entry in productsMap.entries) {
          final productDoc =
              await _firestore.collection('products').doc(entry.key).get();
          if (productDoc.exists) {
            final productName = productDoc.data()?['productName'] ?? 'Unknown';
            popularProducts.add(ProductSales(productName, entry.value));
          }
        }

        popularProducts.sort((a, b) => b.sales.compareTo(a.sales));

        setState(() {
          _popularProducts = popularProducts;
        });
      }
    } catch (e) {
      print("Error fetching popular products data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrdersPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildSummaryCard('Total Sales', _totalSales)),
                Expanded(
                    child: _buildSummaryCard(
                        'Active Listings', _activeListings.toDouble())),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Sales Trends',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSalesChart(),
            const SizedBox(height: 24),
            const Text(
              'Popular Products',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPopularProductsChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _salesData
                  .map((data) => FlSpot(data.day.millisecondsSinceEpoch
                      .toDouble(), data.sales.toDouble()))
                  .toList(),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    Colors.lightBlueAccent.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularProductsChart() {
    return Container(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: _popularProducts.map((data) {
            return BarChartGroupData(
              x: _popularProducts.indexOf(data),
              barRods: [
                BarChartRodData(
                  toY: data.sales.toDouble(),
                  width: 16,
                  color: Colors.red,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class Sales {
  final DateTime day;
  final int sales;

  Sales(this.day, this.sales);
}

class ProductSales {
  final String product;
  final int sales;

  ProductSales(this.product, this.sales);
}
