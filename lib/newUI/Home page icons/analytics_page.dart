// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:hisab_kitab/reuseable_widgets/app_bar.dart';
// import 'package:hisab_kitab/reuseable_widgets/appbar_data.dart';
// import 'package:intl/intl.dart';
// import 'dart:math';

// class AnalyticsPage extends StatefulWidget {
//   const AnalyticsPage({Key? key}) : super(key: key);

//   @override
//   _AnalyticsPageState createState() => _AnalyticsPageState();
// }

// class _AnalyticsPageState extends State<AnalyticsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   double _monthlyRevenue = 0;
//   double _quarterlyRevenue = 0;
//   double _yearlyRevenue = 0;
//   double _monthlyProfit = 0;
//   double _quarterlyProfit = 0;
//   double _yearlyProfit = 0;
//   List<FlSpot> _salesData = [];
//   List<Map<String, dynamic>> _topProducts = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAnalyticsData();
//   }

//   Future<void> _fetchAnalyticsData() async {
//     setState(() => _isLoading = true);
//     await Future.wait([
//       _calculateRevenueAndProfit(),
//       _generateSalesGraph(),
//       _getTopSellingProducts(),
//     ]);
//     setState(() => _isLoading = false);
//   }

//   Future<void> _calculateRevenueAndProfit() async {
//     final now = DateTime.now();
//     final monthStart = DateTime(now.year, now.month, 1);
//     final quarterStart = DateTime(now.year, (now.month - 1) ~/ 3 * 3 + 1, 1);
//     final yearStart = DateTime(now.year, 1, 1);

//     _monthlyRevenue = _quarterlyRevenue = _yearlyRevenue = 0;
//     _monthlyProfit = _quarterlyProfit = _yearlyProfit = 0;

//     final billsQuery = await _firestore
//         .collection('bills')
//         .where('PurchaseDate', isGreaterThanOrEqualTo: yearStart)
//         .get();

//     for (var doc in billsQuery.docs) {
//       final bill = doc.data() as Map<String, dynamic>;
//       final billDate = (bill['PurchaseDate'] as Timestamp).toDate();
//       final revenue = _calculateBillRevenue(bill);
//       final profit = await _calculateBillProfit(bill);

//       if (billDate.isAfter(monthStart)) {
//         _monthlyRevenue += revenue;
//         _monthlyProfit += profit;
//       }
//       if (billDate.isAfter(quarterStart)) {
//         _quarterlyRevenue += revenue;
//         _quarterlyProfit += profit;
//       }
//       _yearlyRevenue += revenue;
//       _yearlyProfit += profit;
//     }
//   }

//   double _calculateBillRevenue(Map<String, dynamic> bill) {
//     return (bill['Products'] as List<dynamic>)
//         .fold(0.0, (sum, product) => sum + (product['totalPrice'] as num));
//   }

//   Future<double> _calculateBillProfit(Map<String, dynamic> bill) async {
//     double profit = 0;
//     for (var product in bill['Products']) {
//       final productDoc = await _firestore
//           .collection('ProductsNew')
//           .doc(product['barcode'].toString())
//           .get();
//       if (productDoc.exists) {
//         final productData = productDoc.data() as Map<String, dynamic>;
//         final costPrice = productData['WholesalePrice'] as num;
//         final sellingPrice = product['price'] as num;
//         final quantity = product['quantity'] as num;
//         profit += (sellingPrice - costPrice) * quantity;
//       }
//     }
//     return profit;
//   }

//   Future<void> _generateSalesGraph() async {
//     final now = DateTime.now();
//     final thirtyDaysAgo = now.subtract(Duration(days: 30));

//     Map<DateTime, double> dailySales = {};
//     for (int i = 0; i < 30; i++) {
//       final date = now.subtract(Duration(days: i));
//       dailySales[DateTime(date.year, date.month, date.day)] = 0;
//     }

//     final billsQuery = await _firestore
//         .collection('bills')
//         .where('PurchaseDate', isGreaterThanOrEqualTo: thirtyDaysAgo)
//         .orderBy('PurchaseDate')
//         .get();

//     for (var doc in billsQuery.docs) {
//       final bill = doc.data() as Map<String, dynamic>;
//       final billDate = (bill['PurchaseDate'] as Timestamp).toDate();
//       final billTotal = _calculateBillRevenue(bill);

//       final dateKey = DateTime(billDate.year, billDate.month, billDate.day);
//       dailySales[dateKey] = (dailySales[dateKey] ?? 0) + billTotal;
//     }

//     _salesData = dailySales.entries.map((entry) {
//       return FlSpot(
//         entry.key.millisecondsSinceEpoch.toDouble(),
//         entry.value,
//       );
//     }).toList();

//     _salesData.sort((a, b) => a.x.compareTo(b.x));
//   }

//   Future<void> _getTopSellingProducts() async {
//     final now = DateTime.now();
//     final thirtyDaysAgo = now.subtract(Duration(days: 30));

//     final billsQuery = await _firestore
//         .collection('bills')
//         .where('PurchaseDate', isGreaterThanOrEqualTo: thirtyDaysAgo)
//         .get();

//     Map<String, Map<String, dynamic>> productSales = {};

//     for (var doc in billsQuery.docs) {
//       final bill = doc.data() as Map<String, dynamic>;
//       final products = bill['Products'] as List<dynamic>;

//       for (var product in products) {
//         final barcode = product['barcode'].toString();
//         final name = product['name'] as String;
//         final quantity = product['quantity'] as int;

//         if (!productSales.containsKey(barcode)) {
//           productSales[barcode] = {
//             'name': name,
//             'quantitySold': 0,
//           };
//         }
//         productSales[barcode]!['quantitySold'] += quantity;
//       }
//     }

//     List<MapEntry<String, Map<String, dynamic>>> sortedProducts = productSales
//         .entries
//         .toList()
//       ..sort(
//           (a, b) => b.value['quantitySold'].compareTo(a.value['quantitySold']));

//     _topProducts = sortedProducts.take(5).map((entry) {
//       return {
//         'name': entry.value['name'],
//         'quantitySold': entry.value['quantitySold'],
//       };
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         // backgroundColor: AppBarData.appBarColor,
//         title: "Analytics Dashboard", // Localized title
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchAnalyticsData,
//           ),
//         ],
//         titleColor: AppBarData.titleColor,
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _fetchAnalyticsData,
//               child: SingleChildScrollView(
//                 physics: AlwaysScrollableScrollPhysics(),
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildSummaryCards(),
//                       SizedBox(height: 24),
//                       _buildSalesGraph(),
//                       SizedBox(height: 24),
//                       _buildTopProductsSection(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildSummaryCards() {
//     return GridView.count(
//       crossAxisCount: 2,
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       children: [
//         _buildSummaryCard(
//             'Monthly Revenue', _monthlyRevenue, Icons.trending_up),
//         _buildSummaryCard('Monthly Profit', _monthlyProfit, Icons.attach_money),
//         _buildSummaryCard(
//             'Quarterly Revenue', _quarterlyRevenue, Icons.timeline),
//         _buildSummaryCard(
//             'Quarterly Profit', _quarterlyProfit, Icons.account_balance),
//         _buildSummaryCard('Yearly Revenue', _yearlyRevenue, Icons.bar_chart),
//         _buildSummaryCard('Yearly Profit', _yearlyProfit, Icons.pie_chart),
//       ],
//     );
//   }

//   Widget _buildSummaryCard(String title, double amount, IconData icon) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: Theme.of(context).primaryColor),
//             SizedBox(height: 8),
//             Text(title,
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//             SizedBox(height: 4),
//             Text(
//               NumberFormat.currency(symbol: '₹').format(amount),
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: amount >= 0 ? Colors.green : Colors.red,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSalesGraph() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Sales Trend (Last 30 Days)',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               height: 300,
//               child: LineChart(
//                 LineChartData(
//                   gridData: FlGridData(
//                     show: true,
//                     drawVerticalLine: true,
//                     getDrawingHorizontalLine: (value) {
//                       return FlLine(
//                         color: Colors.grey.shade300,
//                         strokeWidth: 1,
//                       );
//                     },
//                     getDrawingVerticalLine: (value) {
//                       return FlLine(
//                         color: Colors.grey.shade300,
//                         strokeWidth: 1,
//                       );
//                     },
//                   ),
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 60,
//                         interval: _calculateYAxisInterval(),
//                         getTitlesWidget: (value, meta) {
//                           return Padding(
//                             padding: const EdgeInsets.only(right: 8),
//                             child: Text(
//                               '₹${NumberFormat.compact().format(value)}',
//                               style: const TextStyle(fontSize: 10),
//                               textAlign: TextAlign.right,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 40,
//                         interval: _calculateXAxisInterval(),
//                         getTitlesWidget: (value, meta) {
//                           final date = DateTime.fromMillisecondsSinceEpoch(
//                               value.toInt());
//                           return Transform.rotate(
//                             angle: -0.5,
//                             child: Text(
//                               DateFormat('dd/MM').format(date),
//                               style: const TextStyle(fontSize: 10),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     rightTitles:
//                         AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     topTitles:
//                         AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   ),
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: _salesData,
//                       isCurved: true,
//                       color: Colors.blue,
//                       barWidth: 3,
//                       isStrokeCapRound: true,
//                       dotData: FlDotData(
//                         show: false,
//                       ),
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: Colors.blue.withOpacity(0.2),
//                       ),
//                     ),
//                   ],
//                   borderData: FlBorderData(
//                     show: true,
//                     border: Border.all(color: Colors.black12),
//                   ),
//                   minX: _salesData.first.x,
//                   maxX: _salesData.last.x,
//                   minY: 0,
//                   maxY: _getMaxY(),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   double _getMaxY() {
//     if (_salesData.isNotEmpty) {
//       return (_salesData.map((spot) => spot.y).reduce(max) * 1.2)
//           .roundToDouble();
//     } else {
//       return 1000.0; // Default max value if no data
//     }
//   }

//   double _calculateYAxisInterval() {
//     final maxY = _getMaxY();
//     return (maxY / 5).roundToDouble(); // Display 5 Y-axis labels
//   }

//   double _calculateXAxisInterval() {
//     if (_salesData.isNotEmpty) {
//       final totalDays =
//           (_salesData.last.x - _salesData.first.x) / (24 * 60 * 60 * 1000);
//       return (totalDays / 6).roundToDouble() *
//           24 *
//           60 *
//           60 *
//           1000; // Display 6 X-axis labels
//     } else {
//       return 24 * 60 * 60 * 1000; // Default to 1 day if no data
//     }
//   }

//   Widget _buildTopProductsSection() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Top 5 Products',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//             ),
//             SizedBox(height: 16),
//             _topProducts.isNotEmpty
//                 ? ListView.separated(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: _topProducts.length,
//                     itemBuilder: (context, index) {
//                       final product = _topProducts[index];
//                       return ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Theme.of(context).primaryColor,
//                           child: Text('${index + 1}'),
//                         ),
//                         title: Text(
//                           product['name'],
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         trailing: Text(
//                           '${NumberFormat.compact().format(product['quantitySold'])} sold',
//                           style: TextStyle(
//                             color: Theme.of(context).primaryColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       );
//                     },
//                     separatorBuilder: (context, index) => Divider(),
//                   )
//                 : Center(
//                     child: Text(
//                       'No data available',
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shimmer/shimmer.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color _primaryColor = Color(0xFF146EB4);

  bool _isLoading = true;
  Map<String, double> _revenue = {};
  Map<String, double> _profit = {};
  List<FlSpot> _salesData = [];
  Map<String, List<Map<String, dynamic>>> _topProductsCache = {};
  String _selectedTimePeriod = 'Today';

  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadDataProgressively();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedRevenue = prefs.getString('revenue');
    final cachedProfit = prefs.getString('profit');
    final cachedSalesData = prefs.getString('salesData');
    final cachedTopProducts = prefs.getString('topProductsCache');

    if (cachedRevenue != null) {
      setState(() {
        _revenue = Map<String, double>.from(json.decode(cachedRevenue));
      });
    }
    if (cachedProfit != null) {
      setState(() {
        _profit = Map<String, double>.from(json.decode(cachedProfit));
      });
    }
    if (cachedSalesData != null) {
      setState(() {
        _salesData = (json.decode(cachedSalesData) as List)
            .map((item) => FlSpot(item['x'], item['y']))
            .toList();
      });
    }
    if (cachedTopProducts != null) {
      setState(() {
        _topProductsCache = Map<String, List<Map<String, dynamic>>>.from(
          json.decode(cachedTopProducts).map(
                (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
              ),
        );
      });
    }

    if (cachedRevenue != null && cachedProfit != null && cachedSalesData != null && cachedTopProducts != null) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDataProgressively() async {
    await _calculateRevenueAndProfit();
    await _generateSalesGraph();
    await _fetchAndCacheTopProducts();
    await _cacheData();

    setState(() => _isLoading = false);
  }

  Future<void> _calculateRevenueAndProfit() async {
    final now = DateTime.now();
    final periods = {
      'Daily': DateTime(now.year, now.month, now.day),
      'Weekly': now.subtract(Duration(days: now.weekday - 1)),
      'Monthly': DateTime(now.year, now.month, 1),
      'Quarterly': DateTime(now.year, (now.month - 1) ~/ 3 * 3 + 1, 1),
      'Yearly': DateTime(now.year, 1, 1),
    };

    Map<String, double> newRevenue = {};
    Map<String, double> newProfit = {};

    final billsQuery = await _firestore
        .collection('bills')
        .where('PurchaseDate', isGreaterThanOrEqualTo: periods['Yearly'])
        .get();

    for (var doc in billsQuery.docs) {
      final bill = doc.data() as Map<String, dynamic>;
      final billDate = (bill['PurchaseDate'] as Timestamp).toDate();
      final revenue = _calculateBillRevenue(bill);
      final profit = await _calculateBillProfit(bill);

      periods.forEach((key, startDate) {
        if (billDate.isAfter(startDate)) {
          newRevenue[key] = (newRevenue[key] ?? 0) + revenue;
          newProfit[key] = (newProfit[key] ?? 0) + profit;
        }
      });
    }

    setState(() {
      _revenue = newRevenue;
      _profit = newProfit;
    });
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

    List<FlSpot> newSalesData = dailySales.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value,
      );
    }).toList();

    newSalesData.sort((a, b) => a.x.compareTo(b.x));

    setState(() {
      _salesData = newSalesData;
    });
  }

  Future<void> _fetchAndCacheTopProducts() async {
    final periods = ['Today', 'This Week', 'This Month', 'This Year'];
    for (var period in periods) {
      await _getTopSellingProducts(period);
    }
  }

  Future<void> _getTopSellingProducts(String period) async {
    DateTime startDate;
    final now = DateTime.now();

    switch (period) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(Duration(days: 30));
    }

    final billsQuery = await _firestore
        .collection('bills')
        .where('PurchaseDate', isGreaterThanOrEqualTo: startDate)
        .get();

    Map<String, Map<String, dynamic>> productSales = {};

    for (var doc in billsQuery.docs) {
      final bill = doc.data() as Map<String, dynamic>;
      final products = bill['Products'] as List<dynamic>;

      for (var product in products) {
        final barcode = product['barcode'].toString();
        final name = product['name'] as String;
        final quantity = product['quantity'] as int;
        final totalPrice = product['totalPrice'] as num;

        if (!productSales.containsKey(barcode)) {
          productSales[barcode] = {
            'name': name,
            'quantitySold': 0,
            'revenue': 0.0,
            'profit': 0.0,
          };
        }
        productSales[barcode]!['quantitySold'] += quantity;
        productSales[barcode]!['revenue'] += totalPrice;

        final productDoc = await _firestore
            .collection('ProductsNew')
            .doc(barcode)
            .get();
        if (productDoc.exists) {
          final productData = productDoc.data() as Map<String, dynamic>;
          final costPrice = productData['WholesalePrice'] as num;
          productSales[barcode]!['profit'] += (totalPrice - (costPrice * quantity));
        }
      }
    }

    List<MapEntry<String, Map<String, dynamic>>> sortedProducts = productSales
        .entries
        .toList()
      ..sort((a, b) => b.value['quantitySold'].compareTo(a.value['quantitySold']));

    setState(() {
      _topProductsCache[period] = sortedProducts.take(5).map((entry) {
        return {
          'name': entry.value['name'],
          'quantitySold': entry.value['quantitySold'],
          'revenue': entry.value['revenue'],
          'profit': entry.value['profit'],
        };
      }).toList();
    });
  }

  Future<void> _cacheData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('revenue', json.encode(_revenue));
    await prefs.setString('profit', json.encode(_profit));
    await prefs.setString('salesData', json.encode(_salesData.map((spot) => {'x': spot.x, 'y': spot.y}).toList()));
    await prefs.setString('topProductsCache', json.encode(_topProductsCache));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics Dashboard'),
        backgroundColor: _primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDataProgressively,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDataProgressively,
        color: _primaryColor,
        child: _isLoading ? _buildLoadingScreen() : _buildDashboard(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryColor),
          SizedBox(height: 20),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Loading Analytics...',
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                speed: Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
            pause: Duration(milliseconds: 1000),
            displayFullTextOnTap: true,
            stopPauseOnTap: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard('Daily Revenue', _revenue['Daily'] ?? 0, Icons.today),
        _buildSummaryCard('Daily Profit', _profit['Daily'] ?? 0, Icons.attach_money),
        _buildSummaryCard('Weekly Revenue', _revenue['Weekly'] ?? 0, Icons.view_week),
        _buildSummaryCard('Weekly Profit', _profit['Weekly'] ?? 0, Icons.account_balance_wallet),
        _buildSummaryCard('Monthly Revenue', _revenue['Monthly'] ?? 0, Icons.calendar_today),
        _buildSummaryCard('Monthly Profit', _profit['Monthly'] ?? 0, Icons.account_balance),
        _buildSummaryCard('Yearly Revenue', _revenue['Yearly'] ?? 0, Icons.event),
        _buildSummaryCard('Yearly Profit', _profit['Yearly'] ?? 0, Icons.trending_up),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: _primaryColor),
                SizedBox(width: 8),
                Text(title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            Spacer(),
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
              child: _salesData.isEmpty
                  ? Center(child: Text('No sales data available'))
                  : LineChart(
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
                                final date = DateTime.fromMillisecondsSinceEpoch(
                                    value.toInt());
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
                            color: _primaryColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: _primaryColor.withOpacity(0.2),
                            ),
                          ),
                        ],
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black12),
                        ),
                        minX: _salesData.isNotEmpty ? _salesData.first.x : 0,
                        maxX: _salesData.isNotEmpty ? _salesData.last.x : 0,
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


  Widget _buildTopProductsSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildProductsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Top 5 Products',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        _buildTimePeriodDropdown(),
      ],
    );
  }

  Widget _buildProductsList() {
    return _topProductsCache[_selectedTimePeriod]?.isNotEmpty == true
        ? ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _topProductsCache[_selectedTimePeriod]!.length,
            itemBuilder: (context, index) {
              final product = _topProductsCache[_selectedTimePeriod]![index];
              return _buildProductItem(product, index);
            },
            separatorBuilder: (context, index) => Divider(height: 1),
          )
        : Center(
            child: Text(
              'No data available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
  }

  Widget _buildProductItem(Map<String, dynamic> product, int index) {
    final isExpanded = _expandedIndex == index;
    return Column(
      children: [
        InkWell(
          onTap: () => _toggleProductExpansion(index),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _buildRankBadge(index),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    product['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (isExpanded) _buildExpandedProductDetails(product),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTimePeriodDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: _selectedTimePeriod,
        items: ['Today', 'This Week', 'This Month', 'This Year']
            .map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedTimePeriod = newValue;
              _expandedIndex = null;
            });
          }
        },
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down),
      ),
    );
  }

  Widget _buildRankBadge(int index) {
    final colors = [
      Colors.amber,
      Colors.grey[400]!,
      Colors.brown[300]!,
      Colors.blue[200]!,
      Colors.green[200]!,
    ];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors[index].withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: colors[index],
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedProductDetails(Map<String, dynamic> product) {
    return SizeTransition(
      sizeFactor: _animation,
      child: Container(
        margin: EdgeInsets.only(left: 56, top: 8, bottom: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Quantity Sold', NumberFormat.compact().format(product['quantitySold'])),
            _buildDetailRow('Revenue', NumberFormat.currency(symbol: '₹').format(product['revenue'])),
            _buildDetailRow('Profit', NumberFormat.currency(symbol: '₹').format(product['profit'])),
          ],
        ),
      ),
    );
  }

  void _toggleProductExpansion(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
        _animationController.reverse();
      } else {
        _expandedIndex = index;
        _animationController.forward();
      }
    });
  }
  double _getMaxY() {
    if (_salesData.isNotEmpty) {
      return (_salesData.map((spot) => spot.y).reduce(max) * 1.2)
          .roundToDouble();
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
      final totalDays =
          (_salesData.last.x - _salesData.first.x) / (24 * 60 * 60 * 1000);
      return (totalDays / 6).roundToDouble() *
          24 *
          60 *
          60 *
          1000; // Display 6 X-axis labels
    } else {
      return 24 * 60 * 60 * 1000; // Default to 1 day if no data
    }
  }
}
