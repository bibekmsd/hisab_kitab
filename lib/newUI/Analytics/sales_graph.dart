import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class SalesGraphPage extends StatefulWidget {
  const SalesGraphPage({Key? key}) : super(key: key);

  @override
  _SalesGraphPageState createState() => _SalesGraphPageState();
}

class _SalesGraphPageState extends State<SalesGraphPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color _primaryColor = Color(0xFF146EB4);

  String _selectedTimeFrame = '1 Month';
  List<FlSpot> _salesData = [];
  Map<String, double> _categoryData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Try to load cached data first
    final cachedData = await _getCachedData();
    if (cachedData != null) {
      _updateStateWithData(cachedData);
    } else {
      // If no cached data, fetch from Firestore
      await _fetchDataFromFirestore();
    }

    setState(() => _isLoading = false);
  }

  Future<Map<String, dynamic>?> _getCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedDataString = prefs.getString('sales_graph_data');
    if (cachedDataString != null) {
      return json.decode(cachedDataString);
    }
    return null;
  }

  Future<void> _cacheData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sales_graph_data', json.encode(data));
  }

  void _updateStateWithData(Map<String, dynamic> data) {
    setState(() {
      _salesData = (data['salesData'] as List)
          .map((item) => FlSpot(item['x'], item['y']))
          .toList();
      _categoryData = Map<String, double>.from(data['categoryData']);
    });
  }

  Future<void> _fetchDataFromFirestore() async {
    final now = DateTime.now();
    final startDate = _getStartDate(now);

    final billsQuery = await _firestore
        .collection('bills')
        .where('PurchaseDate', isGreaterThanOrEqualTo: startDate)
        .orderBy('PurchaseDate')
        .get();

    Map<DateTime, double> dailySales = {};
    Map<String, double> categorySales = {};

    for (var doc in billsQuery.docs) {
      final bill = doc.data();
      final purchaseDate = (bill['PurchaseDate'] as Timestamp).toDate();
      final totalAmount = _calculateBillTotal(bill);

      // Aggregate daily sales
      final dateKey = DateTime(purchaseDate.year, purchaseDate.month, purchaseDate.day);
      dailySales[dateKey] = (dailySales[dateKey] ?? 0) + totalAmount;

      // Aggregate category sales
      for (var product in bill['Products']) {
        final category = product['category'] as String? ?? 'Uncategorized';
        categorySales[category] = (categorySales[category] ?? 0) + (product['totalPrice'] as num);
      }
    }

    _salesData = dailySales.entries
        .map((entry) => FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value))
        .toList();

    _categoryData = categorySales;

    // Cache the fetched data
    await _cacheData({
      'salesData': _salesData.map((spot) => {'x': spot.x, 'y': spot.y}).toList(),
      'categoryData': _categoryData,
    });
  }

  DateTime _getStartDate(DateTime now) {
    switch (_selectedTimeFrame) {
      case '1 Day':
        return DateTime(now.year, now.month, now.day);
      case '1 Week':
        return now.subtract(Duration(days: 7));
      case '1 Month':
        return DateTime(now.year, now.month - 1, now.day);
      case '1 Quarter':
        return DateTime(now.year, now.month - 3, now.day);
      case '1 Year':
        return DateTime(now.year - 1, now.month, now.day);
      default:
        return DateTime(now.year, now.month - 1, now.day);
    }
  }

  double _calculateBillTotal(Map<String, dynamic> bill) {
    return (bill['Products'] as List<dynamic>)
        .fold(0.0, (sum, product) => sum + (product['totalPrice'] as num));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Graph'),
        backgroundColor: _primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeFrameSelector(),
                    SizedBox(height: 24),
                    _buildSalesLineChart(),
                    SizedBox(height: 24),
                    _buildCategoryPieChart(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ['1 Day', '1 Week', '1 Month', '1 Quarter', '1 Year'].map((timeFrame) {
        return ElevatedButton(
          onPressed: () {
            setState(() => _selectedTimeFrame = timeFrame);
            _loadData();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedTimeFrame == timeFrame ? _primaryColor : Colors.grey,
          ),
          child: Text(timeFrame),
        );
      }).toList(),
    );
  }

  Widget _buildSalesLineChart() {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Text(DateFormat('MM/dd').format(date), style: TextStyle(fontSize: 10));
                    },
                    reservedSize: 22,
                  ),
                ),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
              minX: _salesData.first.x,
              maxX: _salesData.last.x,
              minY: 0,
              maxY: _salesData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2,
              lineBarsData: [
                LineChartBarData(
                  spots: _salesData,
                  isCurved: true,
                  color: _primaryColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: _primaryColor.withOpacity(0.2)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: Colors.white,
        child: Row(
          children: <Widget>[
            const SizedBox(height: 18),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 40,
                    sections: _getCategorySections(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getCategorySections() {
    return _categoryData.entries.map((entry) {
      final color = Colors.primaries[entry.key.hashCode % Colors.primaries.length];
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key}\n${(entry.value / _categoryData.values.reduce((a, b) => a + b) * 100).toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}