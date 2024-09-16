import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _monthlyRevenue = 0;
  double _quarterlyRevenue = 0;
  double _yearlyRevenue = 0;
  double _monthlyProfit = 0;
  double _quarterlyProfit = 0;
  double _yearlyProfit = 0;
  List<FlSpot> _salesData = [];
  List<Map<String, dynamic>> _topProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _calculateRevenueAndProfit(),
      _generateSalesGraph(),
      // _getTopSellingProducts(), // Uncomment if you want to implement this feature
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _calculateRevenueAndProfit() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final quarterStart = DateTime(now.year, (now.month - 1) ~/ 3 * 3 + 1, 1);
    final yearStart = DateTime(now.year, 1, 1);

    // Reset all values to 0
    _monthlyRevenue = _quarterlyRevenue = _yearlyRevenue = 0;
    _monthlyProfit = _quarterlyProfit = _yearlyProfit = 0;

    final billsQuery = await _firestore
        .collection('bills')
        .where('PurchaseDate', isGreaterThanOrEqualTo: yearStart)
        .get();

    for (var doc in billsQuery.docs) {
      final bill = doc.data() as Map<String, dynamic>;
      final billDate = (bill['PurchaseDate'] as Timestamp).toDate();
      final revenue = _calculateBillRevenue(bill);
      final profit = await _calculateBillProfit(bill);

      if (billDate.isAfter(monthStart)) {
        _monthlyRevenue += revenue;
        _monthlyProfit += profit;
      }
      if (billDate.isAfter(quarterStart)) {
        _quarterlyRevenue += revenue;
        _quarterlyProfit += profit;
      }
      _yearlyRevenue += revenue;
      _yearlyProfit += profit;
    }
  }

  double _calculateBillRevenue(Map<String, dynamic> bill) {
    return (bill['Products'] as List<dynamic>)
        .fold(0.0, (sum, product) => sum + (product['totalPrice'] as num));
  }

  Future<double> _calculateBillProfit(Map<String, dynamic> bill) async {
    double profit = 0;
    for (var product in bill['Products']) {
      final productDoc = await _firestore
          .collection('ProductsNew')
          .doc(product['barcode'].toString())
          .get();
      if (productDoc.exists) {
        final productData = productDoc.data() as Map<String, dynamic>;
        final costPrice = productData['WholesalePrice'] as num;
        final sellingPrice = product['price'] as num;
        final quantity = product['quantity'] as num;
        profit += (sellingPrice - costPrice) * quantity;
      }
    }
    return profit;
  }

  Future<void> _generateSalesGraph() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30));

    // Initialize daily sales for the last 30 days with 0
    Map<DateTime, double> dailySales = {};
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      dailySales[DateTime(date.year, date.month, date.day)] = 0;
    }

    final billsQuery = await _firestore
        .collection('bills')
        .where('PurchaseDate', isGreaterThanOrEqualTo: thirtyDaysAgo)
        .orderBy('PurchaseDate')
        .get();

    for (var doc in billsQuery.docs) {
      final bill = doc.data() as Map<String, dynamic>;
      final billDate = (bill['PurchaseDate'] as Timestamp).toDate();
      final billTotal = _calculateBillRevenue(bill);

      final dateKey = DateTime(billDate.year, billDate.month, billDate.day);
      dailySales[dateKey] = (dailySales[dateKey] ?? 0) + billTotal;
    }

    _salesData = dailySales.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value,
      );
    }).toList();

    _salesData.sort((a, b) => a.x.compareTo(b.x));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchAnalyticsData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchAnalyticsData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(),
                      SizedBox(height: 24),
                      _buildSalesGraph(),
                      SizedBox(height: 24),
                      _buildTopProductsSection(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
            'Monthly Revenue', _monthlyRevenue, Icons.trending_up),
        _buildSummaryCard('Monthly Profit', _monthlyProfit, Icons.attach_money),
        _buildSummaryCard(
            'Quarterly Revenue', _quarterlyRevenue, Icons.timeline),
        _buildSummaryCard(
            'Quarterly Profit', _quarterlyProfit, Icons.account_balance),
        _buildSummaryCard('Yearly Revenue', _yearlyRevenue, Icons.bar_chart),
        _buildSummaryCard('Yearly Profit', _yearlyProfit, Icons.pie_chart),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
              NumberFormat.currency(symbol: '₹').format(amount),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: amount >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildSalesGraph() {
  //   return Card(
  //     elevation: 4,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Sales Trend (Last 30 Days)', style: Theme.of(context).textTheme.titleLarge),
  //           SizedBox(height: 16),
  //           Container(
  //             height: 300,
  //             child: LineChart(
  //               LineChartData(
  //                 gridData: FlGridData(show: false),
  //                 titlesData: FlTitlesData(
  //                   leftTitles: AxisTitles(
  //                     sideTitles: SideTitles(
  //                       showTitles: true,
  //                       reservedSize: 40,
  //                       getTitlesWidget: (value, meta) {
  //                         return Text(
  //                           '₹${value.toInt()}',
  //                           style: TextStyle(fontSize: 10),
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                   bottomTitles: AxisTitles(
  //                     sideTitles: SideTitles(
  //                       showTitles: true,
  //                       getTitlesWidget: (value, meta) {
  //                         final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
  //                         return Padding(
  //                           padding: EdgeInsets.only(top: 8),
  //                           child: Text(
  //                             DateFormat('dd/MM').format(date),
  //                             style: TextStyle(fontSize: 10),
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //                 lineBarsData: [
  //                   LineChartBarData(
  //                     spots: _salesData,
  //                     isCurved: true,
  //                     dotData: FlDotData(show: false),
  //                     color: Colors.blue,
  //                     barWidth: 2,
  //                   ),
  //                 ],
  //                 borderData: FlBorderData(
  //                   show: true,
  //                   border: Border.all(color: Colors.black12),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  
Widget _buildSalesGraph() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sales Trend (Last 30 Days)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true), // Show grid lines for reference
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      interval: (_getMaxY() / 5).roundToDouble(), // Dynamic interval for Y-axis
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${value.toInt()}', // Format as currency or sales number
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _getXAxisInterval(), // Dynamic interval for X-axis
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('dd/MM').format(date), // Format as 'day/month'
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _salesData,
                    isCurved: true,
                    dotData: FlDotData(show: false),
                    color: Colors.blue,
                    barWidth: 3,
                  ),
                ],
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black12),
                ),
                minX: _salesData.first.x,
                maxX: _salesData.last.x,
                minY: 0,
                maxY: _getMaxY(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Function to get the max Y value dynamically from the sales data
double _getMaxY() {
  if (_salesData.isNotEmpty) {
    return (_salesData.map((spot) => spot.y).reduce(max) * 1.2).roundToDouble();
  } else {
    return 0.0; // Handle empty data
  }
}

// Function to get the interval for X-axis based on date range
double _getXAxisInterval() {
  if (_salesData.isNotEmpty) {
    final dateRange = _salesData.last.x - _salesData.first.x;
    return (dateRange / 5).roundToDouble(); // Display 5 date labels evenly
  } else {
    return 1.0; // Default interval for empty or minimal data
  }
}
  Widget _buildTopProductsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top 5 Products',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            _topProducts.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _topProducts.length,
                    itemBuilder: (context, index) {
                      final product = _topProducts[index];
                      return ListTile(
                        title: Text(product['name']),
                        trailing: Text('${product['quantitySold']} units sold'),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                  )
                : Text('No data available'),
          ],
        ),
      ),
    );
  }
}
