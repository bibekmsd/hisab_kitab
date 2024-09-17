
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
      _getTopSellingProducts(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _calculateRevenueAndProfit() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final quarterStart = DateTime(now.year, (now.month - 1) ~/ 3 * 3 + 1, 1);
    final yearStart = DateTime(now.year, 1, 1);

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

  Future<void> _getTopSellingProducts() async {
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(Duration(days: 30));

  final billsQuery = await _firestore
      .collection('bills')
      .where('PurchaseDate', isGreaterThanOrEqualTo: thirtyDaysAgo)
      .get();

  Map<String, Map<String, dynamic>> productSales = {};

  for (var doc in billsQuery.docs) {
    final bill = doc.data() as Map<String, dynamic>;
    final products = bill['Products'] as List<dynamic>;

    for (var product in products) {
      final barcode = product['barcode'].toString();
      final name = product['name'] as String;
      final quantity = product['quantity'] as int;
      
      if (!productSales.containsKey(barcode)) {
        productSales[barcode] = {
          'name': name,
          'quantitySold': 0,
        };
      }
      productSales[barcode]!['quantitySold'] += quantity;
    }
  }

  List<MapEntry<String, Map<String, dynamic>>> sortedProducts = productSales.entries.toList()
    ..sort((a, b) => b.value['quantitySold'].compareTo(a.value['quantitySold']));

  _topProducts = sortedProducts.take(5).map((entry) {
    return {
      'name': entry.value['name'],
      'quantitySold': entry.value['quantitySold'],
    };
  }).toList();
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
        _buildSummaryCard('Monthly Revenue', _monthlyRevenue, Icons.trending_up),
        _buildSummaryCard('Monthly Profit', _monthlyProfit, Icons.attach_money),
        _buildSummaryCard('Quarterly Revenue', _quarterlyRevenue, Icons.timeline),
        _buildSummaryCard('Quarterly Profit', _quarterlyProfit, Icons.account_balance),
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
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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

  Widget _buildSalesGraph() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Trend (Last 30 Days)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: _calculateYAxisInterval(),
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '₹${NumberFormat.compact().format(value)}',
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: _calculateXAxisInterval(),
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(fontSize: 10),
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
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
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

  double _getMaxY() {
    if (_salesData.isNotEmpty) {
      return (_salesData.map((spot) => spot.y).reduce(max) * 1.2).roundToDouble();
    } else {
      return 1000.0; // Default max value if no data
    }
  }

  double _calculateYAxisInterval() {
    final maxY = _getMaxY();
    return (maxY / 5).roundToDouble(); // Display 5 Y-axis labels
  }

  double _calculateXAxisInterval() {
    if (_salesData.isNotEmpty) {
      final totalDays = (_salesData.last.x - _salesData.first.x) / (24 * 60 * 60 * 1000);
      return (totalDays / 6).roundToDouble() * 24 * 60 * 60 * 1000; // Display 6 X-axis labels
    } else {
      return 24 * 60 * 60 * 1000; // Default to 1 day if no data
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
          Text(
            'Top 5 Products',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          SizedBox(height: 16),
          _topProducts.isNotEmpty
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _topProducts.length,
                  itemBuilder: (context, index) {
                    final product = _topProducts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        product['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${NumberFormat.compact().format(product['quantitySold'])} sold',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(),
                )
              : Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
        ],
      ),
    ),
  );
}
}


