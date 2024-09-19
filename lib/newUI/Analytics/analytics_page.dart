// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
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
//       appBar: AppBar(
//         title: Text('Analytics Dashboard'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _fetchAnalyticsData,
//           ),
//         ],
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

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import 'dart:math';

// class AnalyticsPage extends StatefulWidget {
//   const AnalyticsPage({Key? key}) : super(key: key);

//   @override
//   _AnalyticsPageState createState() => _AnalyticsPageState();
// }

// class _AnalyticsPageState extends State<AnalyticsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final Color _primaryColor = Color(0xFF146EB4);

//   double _dailyRevenue = 0;
//   double _weeklyRevenue = 0;
//   double _monthlyRevenue = 0;
//   double _quarterlyRevenue = 0;
//   double _yearlyRevenue = 0;
//   double _dailyProfit = 0;
//   double _weeklyProfit = 0;
//   double _monthlyProfit = 0;
//   double _quarterlyProfit = 0;
//   double _yearlyProfit = 0;
//   List<FlSpot> _salesData = [];
//   List<Map<String, dynamic>> _topProducts = [];
//   bool _isLoading = true;
//   String _selectedTimePeriod = 'Today';

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
//     final dayStart = DateTime(now.year, now.month, now.day);
//     final weekStart = now.subtract(Duration(days: now.weekday - 1));
//     final monthStart = DateTime(now.year, now.month, 1);
//     final quarterStart = DateTime(now.year, (now.month - 1) ~/ 3 * 3 + 1, 1);
//     final yearStart = DateTime(now.year, 1, 1);

//     _dailyRevenue = _weeklyRevenue = _monthlyRevenue = _quarterlyRevenue = _yearlyRevenue = 0;
//     _dailyProfit = _weeklyProfit = _monthlyProfit = _quarterlyProfit = _yearlyProfit = 0;

//     final billsQuery = await _firestore
//         .collection('bills')
//         .where('PurchaseDate', isGreaterThanOrEqualTo: yearStart)
//         .get();

//     for (var doc in billsQuery.docs) {
//       final bill = doc.data() as Map<String, dynamic>;
//       final billDate = (bill['PurchaseDate'] as Timestamp).toDate();
//       final revenue = _calculateBillRevenue(bill);
//       final profit = await _calculateBillProfit(bill);

//       if (billDate.isAfter(dayStart)) {
//         _dailyRevenue += revenue;
//         _dailyProfit += profit;
//       }
//       if (billDate.isAfter(weekStart)) {
//         _weeklyRevenue += revenue;
//         _weeklyProfit += profit;
//       }
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

  // double _calculateBillRevenue(Map<String, dynamic> bill) {
  //   return (bill['Products'] as List<dynamic>)
  //       .fold(0.0, (sum, product) => sum + (product['totalPrice'] as num));
  // }

  // Future<double> _calculateBillProfit(Map<String, dynamic> bill) async {
  //   double profit = 0;
  //   for (var product in bill['Products']) {
  //     final productDoc = await _firestore
  //         .collection('ProductsNew')
  //         .doc(product['barcode'].toString())
  //         .get();
  //     if (productDoc.exists) {
  //       final productData = productDoc.data() as Map<String, dynamic>;
  //       final costPrice = productData['WholesalePrice'] as num;
  //       final sellingPrice = product['price'] as num;
  //       final quantity = product['quantity'] as num;
  //       profit += (sellingPrice - costPrice) * quantity;
  //     }
  //   }
  //   return profit;
  // }

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
//     DateTime startDate;
//     final now = DateTime.now();

//     switch (_selectedTimePeriod) {
//       case 'Today':
//         startDate = DateTime(now.year, now.month, now.day);
//         break;
//       case 'This Week':
//         startDate = now.subtract(Duration(days: now.weekday - 1));
//         break;
//       case 'This Month':
//         startDate = DateTime(now.year, now.month, 1);
//         break;
//       default:
//         startDate = now.subtract(Duration(days: 30));
//     }

//     final billsQuery = await _firestore
//         .collection('bills')
//         .where('PurchaseDate', isGreaterThanOrEqualTo: startDate)
//         .get();

//     Map<String, Map<String, dynamic>> productSales = {};

//     for (var doc in billsQuery.docs) {
//       final bill = doc.data() as Map<String, dynamic>;
//       final products = bill['Products'] as List<dynamic>;

//       for (var product in products) {
//         final barcode = product['barcode'].toString();
//         final name = product['name'] as String;
//         final quantity = product['quantity'] as int;
//         final totalPrice = product['totalPrice'] as num;

//         if (!productSales.containsKey(barcode)) {
//           productSales[barcode] = {
//             'name': name,
//             'quantitySold': 0,
//             'revenue': 0.0,
//             'profit': 0.0,
//           };
//         }
//         productSales[barcode]!['quantitySold'] += quantity;
//         productSales[barcode]!['revenue'] += totalPrice;

//         // Calculate profit
//         final productDoc = await _firestore
//             .collection('ProductsNew')
//             .doc(barcode)
//             .get();
//         if (productDoc.exists) {
//           final productData = productDoc.data() as Map<String, dynamic>;
//           final costPrice = productData['WholesalePrice'] as num;
//           productSales[barcode]!['profit'] += (totalPrice - (costPrice * quantity));
//         }
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
//         'revenue': entry.value['revenue'],
//         'profit': entry.value['profit'],
//       };
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Analytics Dashboard'),
//         backgroundColor: _primaryColor,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _fetchAnalyticsData,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator(color: _primaryColor))
//           : RefreshIndicator(
//               onRefresh: _fetchAnalyticsData,
//               color: _primaryColor,
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
//         _buildSummaryCard('Daily Revenue', _dailyRevenue, Icons.today),
//         _buildSummaryCard('Daily Profit', _dailyProfit, Icons.attach_money),
//         _buildSummaryCard('Weekly Revenue', _weeklyRevenue, Icons.view_week),
//         _buildSummaryCard('Weekly Profit', _weeklyProfit, Icons.account_balance_wallet),
//         _buildSummaryCard('Monthly Revenue', _monthlyRevenue, Icons.calendar_today),
//         _buildSummaryCard('Monthly Profit', _monthlyProfit, Icons.account_balance),
//         _buildSummaryCard('Quarterly Revenue', _quarterlyRevenue, Icons.pie_chart),
//         _buildSummaryCard('Quarterly Profit', _quarterlyProfit, Icons.donut_large),
//         _buildSummaryCard('Yearly Revenue', _yearlyRevenue, Icons.bar_chart),
//         _buildSummaryCard('Yearly Profit', _yearlyProfit, Icons.trending_up),
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
//             Icon(icon, size: 40, color: _primaryColor),
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
//                       color: _primaryColor,
//                       barWidth: 3,
//                       isStrokeCapRound: true,
//                       dotData: FlDotData(
//                         show: false,
//                       ),
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: _primaryColor.withOpacity(0.2),
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
//                   maxY:_getMaxY(),
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
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Top 5 Products',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                 ),
//                 DropdownButton<String>(
//                   value: _selectedTimePeriod,
//                   items: ['Today', 'This Week', 'This Month', 'Last 30 Days']
//                       .map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     if (newValue != null) {
//                       setState(() {
//                         _selectedTimePeriod = newValue;
//                       });
//                       _getTopSellingProducts();
//                     }
//                   },
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             _topProducts.isNotEmpty
//                 ? ListView.separated(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: _topProducts.length,
//                     itemBuilder: (context, index) {
//                       final product = _topProducts[index];
//                       return ExpansionTile(
//                         leading: CircleAvatar(
//                           backgroundColor: _primaryColor,
//                           child: Text('${index + 1}'),
//                         ),
//                         title: Text(
//                           product['name'],
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               '${NumberFormat.compact().format(product['quantitySold'])} sold',
//                               style: TextStyle(
//                                 color: _primaryColor,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(width: 8),
//                             _buildRankIcon(index),
//                           ],
//                         ),
//                         children: [
//                           Padding(
//                             padding: EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Total Sold: ${product['quantitySold']}'),
//                                 Text('Revenue: ${NumberFormat.currency(symbol: '₹').format(product['revenue'])}'),
//                                 Text('Profit: ${NumberFormat.currency(symbol: '₹').format(product['profit'])}'),
//                               ],
//                             ),
//                           ),
//                         ],
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

//   Widget _buildRankIcon(int index) {
//     if (index > 2) return SizedBox.shrink();
    
//     IconData iconData;
//     Color color;
    
//     switch (index) {
//       case 0:
//         iconData = Icons.looks_one;
//         color = Colors.amber;
//         break;
//       case 1:
//         iconData = Icons.looks_two;
//         color = Colors.grey[400]!;
//         break;
//       case 2:
//         iconData = Icons.looks_3;
//         color = Colors.brown[300]!;
//         break;
//       default:
//         return SizedBox.shrink();
//     }

//     return Icon(iconData, color: color);
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color _primaryColor = Color(0xFF146EB4);

  bool _isLoadingRevenue = true;
  bool _isLoadingSalesGraph = true;
  bool _isLoadingTopProducts = true;

  Map<String, double> _revenue = {};
  Map<String, double> _profit = {};
  List<FlSpot> _salesData = [];
  Map<String, List<Map<String, dynamic>>> _topProductsCache = {};
  String _selectedTimePeriod = 'Today';

  @override
  void initState() {
    super.initState();
    _loadDataProgressively();
  }

Future<void> _loadDataProgressively() async {
  await _calculateRevenueAndProfit();
  setState(() => _isLoadingRevenue = false);

  await _generateSalesGraph();
  setState(() => _isLoadingSalesGraph = false);

  await _loadTopProductsFromCache();
  if (_topProductsCache.isEmpty) {
    _fetchAndCacheTopProducts();
  } else {
    setState(() => _isLoadingTopProducts = false);
  }
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
          _revenue[key] = (_revenue[key] ?? 0) + revenue;
          _profit[key] = (_profit[key] ?? 0) + profit;
        }
      });
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

  Future<void> _loadTopProductsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('topProductsCache');
    if (cachedData != null) {
      final decodedData = json.decode(cachedData) as Map<String, dynamic>;
      _topProductsCache = decodedData.map((key, value) =>
          MapEntry(key, (value as List).cast<Map<String, dynamic>>()));
    }
  }

  Future<void> _fetchAndCacheTopProducts() async {
    final periods = ['Today', 'This Week', 'This Month', 'Last 30 Days'];
    for (var period in periods) {
      await _getTopSellingProducts(period);
    }
    await _cacheTopProducts();
    setState(() => _isLoadingTopProducts = false);
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

        // Calculate profit
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
      ..sort(
          (a, b) => b.value['quantitySold'].compareTo(a.value['quantitySold']));

    _topProductsCache[period] = sortedProducts.take(5).map((entry) {
      return {
        'name': entry.value['name'],
        'quantitySold': entry.value['quantitySold'],
        'revenue': entry.value['revenue'],
        'profit': entry.value['profit'],
      };
    }).toList();
  }

  Future<void> _cacheTopProducts() async {
    final prefs = await SharedPreferences.getInstance();
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
    return _isLoadingRevenue
        ? Center(child: CircularProgressIndicator(color: _primaryColor))
        : GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildSummaryCard('Daily Revenue', _revenue['Daily'] ?? 0, Icons.today),
              _buildSummaryCard('Daily Profit', _profit['Daily'] ?? 0, Icons.attach_money),
              _buildSummaryCard('Weekly Revenue', _revenue['Weekly'] ?? 0, Icons.view_week),
              _buildSummaryCard('Weekly Profit', _profit['Weekly'] ?? 0, Icons.account_balance_wallet),
              _buildSummaryCard('Monthly Revenue', _revenue['Monthly'] ?? 0, Icons.calendar_today),
              _buildSummaryCard('Monthly Profit', _profit['Monthly'] ?? 0, Icons.account_balance),
              _buildSummaryCard('Quarterly Revenue', _revenue['Quarterly'] ?? 0, Icons.pie_chart),
              _buildSummaryCard('Quarterly Profit', _profit['Quarterly'] ?? 0, Icons.donut_large),
              _buildSummaryCard('Yearly Revenue', _revenue['Yearly'] ?? 0, Icons.bar_chart),
              _buildSummaryCard('Yearly Profit', _profit['Yearly'] ?? 0, Icons.trending_up),
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
            Icon(icon, size: 40, color: _primaryColor),
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

  Widget _buildSalesGraph() {
    return _isLoadingSalesGraph
        ? Center(child: CircularProgressIndicator(color: _primaryColor))
        : Card(
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
                          rightTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _salesData,
                            isCurved: true,
                            color: _primaryColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: false,
                            ),
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

  Widget _buildTopProductsSection() {
    return _isLoadingTopProducts
        ? Center(child: CircularProgressIndicator(color: _primaryColor))
        : Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top 5 Products',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                      DropdownButton<String>(
                        value: _selectedTimePeriod,
                        items: ['Today', 'This Week', 'This Month', 'Last 30 Days']
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
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _topProductsCache[_selectedTimePeriod]?.isNotEmpty == true
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
                        ),
                ],
              ),
            ),
          );
  }

  Widget _buildProductItem(Map<String, dynamic> product, int index) {
    return InkWell(
      onTap: () => _showProductDetails(product),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _buildRankIcon(index),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${NumberFormat.compact().format(product['quantitySold'])} sold',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(symbol: '₹').format(product['revenue']),
                  style: TextStyle(fontWeight: FontWeight.bold, color: _primaryColor),
                ),
                SizedBox(height: 4),
                Text(
                  'Profit: ${NumberFormat.currency(symbol: '₹').format(product['profit'])}',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankIcon(int index) {
    if (index > 2) return SizedBox(width: 40);
    
    IconData iconData;
    Color color;
    
    switch (index) {
      case 0:
        iconData = Icons.looks_one;
        color = Colors.amber;
        break;
      case 1:
        iconData = Icons.looks_two;
        color = Colors.grey[400]!;
        break;
      case 2:
        iconData = Icons.looks_3;
        color = Colors.brown[300]!;
        break;
      default:
        return SizedBox(width: 40);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color),
    );
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product['name'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildDetailRow('Quantity Sold', '${product['quantitySold']}'),
            _buildDetailRow('Revenue', NumberFormat.currency(symbol: '₹').format(product['revenue'])),
            _buildDetailRow('Profit', NumberFormat.currency(symbol: '₹').format(product['profit'])),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'sales_graph.dart';

// class AnalyticsPage extends StatefulWidget {
//   const AnalyticsPage({Key? key}) : super(key: key);

//   @override
//   _AnalyticsPageState createState() => _AnalyticsPageState();
// }

// class _AnalyticsPageState extends State<AnalyticsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final Color _primaryColor = Color(0xFF146EB4);

//   Map<String, double> _revenueMetrics = {};
//   Map<String, double> _profitMetrics = {};
//   List<Map<String, dynamic>> _topProducts = [];
//   bool _isLoading = true;
//   String _selectedTimeFrame = 'Month';
//   DateTime _lastUpdateTime = DateTime.now().subtract(Duration(days: 1));

//   @override
//   void initState() {
//     super.initState();
//     _loadCachedData();
//   }

//   Future<void> _loadCachedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cachedData = prefs.getString('analytics_cache');
//     if (cachedData != null) {
//       final decodedData = json.decode(cachedData);
//       setState(() {
//         _revenueMetrics = Map<String, double>.from(decodedData['revenueMetrics']);
//         _profitMetrics = Map<String, double>.from(decodedData['profitMetrics']);
//         _topProducts = List<Map<String, dynamic>>.from(decodedData['topProducts']);
//         _lastUpdateTime = DateTime.parse(decodedData['lastUpdateTime']);
//         _isLoading = false;
//       });
//     }
//     _fetchNewData();
//   }

//   Future<void> _fetchNewData() async {
//     final now = DateTime.now();
//     final timeDifference = now.difference(_lastUpdateTime);

//     if (timeDifference.inMinutes < 5) {
//       // If less than 5 minutes have passed since the last update, don't fetch new data
//       return;
//     }

//     final newData = await _fetchAnalyticsData();
    
//     if (newData != null) {
//       setState(() {
//         _revenueMetrics = newData['revenueMetrics'];
//         _profitMetrics = newData['profitMetrics'];
//         _topProducts = newData['topProducts'];
//         _lastUpdateTime = now;
//         _isLoading = false;
//       });

//       // Cache the new data
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('analytics_cache', json.encode({
//         'revenueMetrics': _revenueMetrics,
//         'profitMetrics': _profitMetrics,
//         'topProducts': _topProducts,
//         'lastUpdateTime': now.toIso8601String(),
//       }));
//     }
//   }

//   Future<Map<String, dynamic>?> _fetchAnalyticsData() async {
//     try {
//       final revenueAndProfit = await _calculateRevenueAndProfit();
//       final topProducts = await _getTopSellingProducts();

//       return {
//         'revenueMetrics': revenueAndProfit['revenue'],
//         'profitMetrics': revenueAndProfit['profit'],
//         'topProducts': topProducts,
//       };
//     } catch (e) {
//       print('Error fetching analytics data: $e');
//       return null;
//     }
//   }

//   Future<Map<String, Map<String, double>>> _calculateRevenueAndProfit() async {
//     final now = DateTime.now();
//     final timeFrames = {
//       'Day': now.subtract(Duration(days: 1)),
//       'Week': now.subtract(Duration(days: 7)),
//       'Month': DateTime(now.year, now.month, 1),
//       'Quarter': DateTime(now.year, (now.month - 1) ~/ 3 * 3 + 1, 1),
//       'Year': DateTime(now.year, 1, 1),
//     };

//     Map<String, double> revenueMetrics = {};
//     Map<String, double> profitMetrics = {};

//     for (var entry in timeFrames.entries) {
//       final startDate = entry.value;
//       final billsQuery = await _firestore
//           .collection('bills')
//           .where('PurchaseDate', isGreaterThanOrEqualTo: startDate)
//           .get();

//       double revenue = 0;
//       double profit = 0;

//       for (var doc in billsQuery.docs) {
//         final bill = doc.data();
//         revenue += _calculateBillRevenue(bill);
//         profit += await _calculateBillProfit(bill);
//       }

//       revenueMetrics[entry.key] = revenue;
//       profitMetrics[entry.key] = profit;
//     }

//     return {'revenue': revenueMetrics, 'profit': profitMetrics};
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

//   Future<List<Map<String, dynamic>>> _getTopSellingProducts() async {
//     final now = DateTime.now();
//     final startDate = _getStartDateForTimeFrame(_selectedTimeFrame);

//     final billsQuery = await _firestore
//         .collection('bills')
//         .where('PurchaseDate', isGreaterThanOrEqualTo: startDate)
//         .get();

//     Map<String, Map<String, dynamic>> productSales = {};

//     for (var doc in billsQuery.docs) {
//       final bill = doc.data();
//       final products = bill['Products'] as List<dynamic>;

//       for (var product in products) {
//         final barcode = product['barcode'].toString();
//         final name = product['name'] as String;
//         final quantity = product['quantity'] as int;
//         final revenue = product['totalPrice'] as num;

//         if (!productSales.containsKey(barcode)) {
//           final productDoc = await _firestore.collection('ProductsNew').doc(barcode).get();
//           final productData = productDoc.data() as Map<String, dynamic>;
          
//           productSales[barcode] = {
//             'name': name,
//             'quantitySold': 0,
//             'revenue': 0.0,
//             'profit': 0.0,
//             'imageUrl': productData['ImageUrl'] as String,
//           };
//         }
//         productSales[barcode]!['quantitySold'] += quantity;
//         productSales[barcode]!['revenue'] += revenue;
//         productSales[barcode]!['profit'] += await _calculateProductProfit(barcode, quantity, revenue);
//       }
//     }

//     return productSales.entries
//         .map((entry) => {
//               'barcode': entry.key,
//               ...entry.value,
//             })
//         .toList()
//       ..sort((a, b) => b['quantitySold'].compareTo(a['quantitySold']))
//       ..take(5)
//       .toList();
//   }

//   Future<double> _calculateProductProfit(String barcode, int quantity, num revenue) async {
//   try {
//     final productDoc = await _firestore.collection('ProductsNew').doc(barcode).get();
//     if (productDoc.exists) {
//       final productData = productDoc.data() as Map<String, dynamic>?;
//       if (productData != null && productData.containsKey('WholesalePrice')) {
//         final costPrice = productData['WholesalePrice'];
//         if (costPrice is num) {
//           return (revenue - (costPrice * quantity)).toDouble();
//         }
//       }
//     }
//     // If any of the above conditions are not met, return 0.0
//     return 0.0;
//   } catch (e) {
//     print('Error calculating product profit: $e');
//     return 0.0;
//   }
// }

//   DateTime _getStartDateForTimeFrame(String timeFrame) {
//     final now = DateTime.now();
//     switch (timeFrame) {
//       case 'Day':
//         return DateTime(now.year, now.month, now.day);
//       case 'Week':
//         return now.subtract(Duration(days: now.weekday - 1));
//       case 'Month':
//         return DateTime(now.year, now.month, 1);
//       case 'Quarter':
//         return DateTime(now.year, (now.month - 1) ~/ 3 * 3 + 1, 1);
//       case 'Year':
//         return DateTime(now.year, 1, 1);
//       default:
//         return DateTime(now.year, now.month, 1);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Analytics Dashboard'),
//         backgroundColor: _primaryColor,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _fetchAnalyticsData,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator(color: _primaryColor))
//           : RefreshIndicator(
//               onRefresh: _fetchAnalyticsData,
//               color: _primaryColor,
//               child: SingleChildScrollView(
//                 physics: AlwaysScrollableScrollPhysics(),
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildSummaryCards(),
//                       SizedBox(height: 24),
//                       _buildSalesGraphButton(),
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
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Revenue & Profit Metrics',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryColor),
//         ),
//         SizedBox(height: 16),
//         Wrap(
//           spacing: 16,
//           runSpacing: 16,
//           children: [
//             _buildMetricCard('Day', Icons.today),
//             _buildMetricCard('Week', Icons.view_week),
//             _buildMetricCard('Month', Icons.calendar_today),
//             _buildMetricCard('Quarter', Icons.pie_chart),
//             _buildMetricCard('Year', Icons.timeline),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildMetricCard(String timeFrame, IconData icon) {
//     final revenue = _revenueMetrics[timeFrame] ?? 0;
//     final profit = _profitMetrics[timeFrame] ?? 0;

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   timeFrame,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor),
//                 ),
//                 Icon(icon, color: _primaryColor),
//               ],
//             ),
//             SizedBox(height: 12),
//             _buildMetricRow('Revenue', revenue),
//             SizedBox(height: 8),
//             _buildMetricRow('Profit', profit),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMetricRow(String label, double amount) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: TextStyle(fontSize: 14)),
//         Text(
//           NumberFormat.currency(symbol: '₹').format(amount),
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: amount >= 0 ? Colors.green : Colors.red,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSalesGraphButton() {
//     return ElevatedButton.icon(
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SalesGraphPage()),
//         );
//       },
//       icon: Icon(Icons.show_chart),
//       label: Text('Show Sales Graph'),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _primaryColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       ),
//     );
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
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Top 5 Products',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryColor),
//                 ),
//                 DropdownButton<String>(
//                   value: _selectedTimeFrame,
//                   items: ['Day', 'Week', 'Month', 'Quarter', 'Year']
//                       .map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     if (newValue != null) {
//                       setState(() {
//                         _selectedTimeFrame = newValue;
//                         _getTopSellingProducts();
//                       });
//                     }
//                   },
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             _topProducts.isNotEmpty
//                 ? ListView.separated(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: _topProducts.length,
//                     itemBuilder: (context, index) {
//                       final product = _topProducts[index];
//                       return _buildProductListItem(product, index);
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

//   Widget _buildProductListItem(Map<String, dynamic> product, int index) {
//     return ExpansionTile(
//       leading: Stack(
//         alignment: Alignment.center,
//         children: [
//           CircleAvatar(
//             backgroundColor: _primaryColor,
//             child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
//           ),
//           CachedNetworkImage(
//             imageUrl: product['imageUrl'],
//             placeholder: (context, url) => CircularProgressIndicator(),
//             errorWidget: (context, url, error) => Icon(Icons.error),
//             width: 40,
//             height: 40,
//             fit: BoxFit.cover,
//           ),
//         ],
//       ),
//       title: Text(
//         product['name'],
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       subtitle: Text(
//         '${NumberFormat.compact().format(product['quantitySold'])} sold',
//         style: TextStyle(color: _primaryColor),
//       ),
//       children: [
//         Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildProductDetailRow('Quantity Sold', product['quantitySold'].toString()),
//               _buildProductDetailRow('Revenue', NumberFormat.currency(symbol: '₹').format(product['revenue'])),
//               _buildProductDetailRow('Profit', NumberFormat.currency(symbol: '₹').format(product['profit'])),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProductDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//           Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'sales_graph.dart';

// class AnalyticsPage extends StatefulWidget {
//   const AnalyticsPage({Key? key}) : super(key: key);

//   @override
//   _AnalyticsPageState createState() => _AnalyticsPageState();
// }

// class _AnalyticsPageState extends State<AnalyticsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final Color _primaryColor = Color(0xFF146EB4);

//   Map<String, double> _revenueMetrics = {};
//   Map<String, double> _profitMetrics = {};
//   List<Map<String, dynamic>> _topProducts = [];
//   bool _isLoading = true;
//   String _selectedTimeFrame = 'Month';
//   DateTime _lastUpdateTime = DateTime.now().subtract(Duration(days: 1));

//   @override
//   void initState() {
//     super.initState();
//     _loadCachedData();
//   }

//   Future<void> _loadCachedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cachedData = prefs.getString('analytics_cache');
//     if (cachedData != null) {
//       final decodedData = json.decode(cachedData);
//       setState(() {
//         _revenueMetrics = Map<String, double>.from(decodedData['revenueMetrics']);
//         _profitMetrics = Map<String, double>.from(decodedData['profitMetrics']);
//         _topProducts = List<Map<String, dynamic>>.from(decodedData['topProducts']);
//         _lastUpdateTime = DateTime.parse(decodedData['lastUpdateTime']);
//         _isLoading = false;
//       });
//     }
//     _fetchNewData();
//   }

//   Future<void> _fetchNewData() async {
//     final now = DateTime.now();
//     final timeDifference = now.difference(_lastUpdateTime);

//     if (timeDifference.inMinutes < 5) {
//       // If less than 5 minutes have passed since the last update, don't fetch new data
//       return;
//     }

//     final newData = await _fetchAnalyticsData();
    
//     if (newData != null) {
//       setState(() {
//         _revenueMetrics = newData['revenueMetrics'];
//         _profitMetrics = newData['profitMetrics'];
//         _topProducts = newData['topProducts'];
//         _lastUpdateTime = now;
//         _isLoading = false;
//       });

//       // Cache the new data
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('analytics_cache', json.encode({
//         'revenueMetrics': _revenueMetrics,
//         'profitMetrics': _profitMetrics,
//         'topProducts': _topProducts,
//         'lastUpdateTime': now.toIso8601String(),
//       }));
//     }
//   }

//   Future<Map<String, dynamic>?> _fetchAnalyticsData() async {
//     try {
//       final revenueAndProfit = await _calculateRevenueAndProfit();
//       final topProducts = await _getTopSellingProducts();

//       return {
//         'revenueMetrics': revenueAndProfit['revenue'],
//         'profitMetrics': revenueAndProfit['profit'],
//         'topProducts': topProducts,
//       };
//     } catch (e) {
//       print('Error fetching analytics data: $e');
//       return null;
//     }
//   }

//   Future<Map<String, Map<String, double>>> _calculateRevenueAndProfit() async {
//     final now = DateTime.now();
//     final timeFrames = {
//       'Day': now.subtract(Duration(days: 1)),
//       'Week': now.subtract(Duration(days: 7)),
//       'Month': DateTime(now.year, now.month, 1),
//       'Quarter': DateTime(now.year, (now.month - 1) ~/ 3 * 3 + 1, 1),
//       'Year': DateTime(now.year, 1, 1),
//     };

//     Map<String, double> revenueMetrics = {};
//     Map<String, double> profitMetrics = {};

//     for (var entry in timeFrames.entries) {
//       final startDate = entry.value;
//       final billsQuery = await _firestore
//           .collection('bills')
//           .where('PurchaseDate', isGreaterThanOrEqualTo: startDate)
//           .get();

//       double revenue = 0;
//       double profit = 0;

//       for (var doc in billsQuery.docs) {
//         final bill = doc.data();
//         revenue += _calculateBillRevenue(bill);
//         profit += await _calculateBillProfit(bill);
//       }

//       revenueMetrics[entry.key] = revenue;
//       profitMetrics[entry.key] = profit;
//     }

//     return {'revenue': revenueMetrics, 'profit': profitMetrics};
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

//   Future<List<Map<String, dynamic>>> _getTopSellingProducts() async {
//     final now = DateTime.now();
//     final startDate = _getStartDateForTimeFrame(_selectedTimeFrame);

//     final billsQuery = await _firestore
//         .collection('bills')
//         .where('PurchaseDate', isGreaterThanOrEqualTo: startDate)
//         .get();

//     Map<String, Map<String, dynamic>> productSales = {};

//     for (var doc in billsQuery.docs) {
//       final bill = doc.data();
//       final products = bill['Products'] as List<dynamic>;

//       for (var product in products) {
//         final barcode = product['barcode'].toString();
//         final name = product['name'] as String;
//         final quantity = product['quantity'] as int;
//         final revenue = product['totalPrice'] as num;

//         if (!productSales.containsKey(barcode)) {
//           final productDoc = await _firestore.collection('ProductsNew').doc(barcode).get();
//           final productData = productDoc.data() as Map<String, dynamic>;
          
//           productSales[barcode] = {
//             'name': name,
//             'quantitySold': 0,
//             'revenue': 0.0,
//             'profit': 0.0,
//             'imageUrl': productData['ImageUrl'] as String,
//           };
//         }
//         productSales[barcode]!['quantitySold'] += quantity;
//         productSales[barcode]!['revenue'] += revenue;
//         productSales[barcode]!['profit'] += await _calculateProductProfit(barcode, quantity, revenue);
//       }
//     }

//     return productSales.entries
//         .map((entry) => {
//               'barcode': entry.key,
//               ...entry.value,
//             })
//         .toList()
//       ..sort((a, b) => b['quantitySold'].compareTo(a['quantitySold']))
//       ..take(5)
//       .toList();
//   }

//   Future<double> _calculateProductProfit(String barcode, int quantity, num revenue) async {
//     try {
//       final productDoc = await _firestore.collection('ProductsNew').doc(barcode).get();
//       if (productDoc.exists) {
//         final productData = productDoc.data() as Map<String, dynamic>?;
//         if (productData != null && productData.containsKey('WholesalePrice')) {
//           final costPrice = productData['WholesalePrice'];
//           if (costPrice is num) {
//             return (revenue - (costPrice * quantity)).toDouble();
//           }
//         }
//       }
//       // If any of the above conditions are not met, return 0.0
//       return 0.0;
//     } catch (e) {
//       print('Error calculating product profit: $e');
//       return 0.0;
//     }
//   }

//   DateTime _getStartDateForTimeFrame(String timeFrame) {
//     final now = DateTime.now();
//     switch (timeFrame) {
//       case 'Day':
//         return DateTime(now.year, now.month, now.day);
//       case 'Week':
//         return now.subtract(Duration(days: now.weekday - 1));
//       case 'Month':
//         return DateTime(now.year, now.month, 1);
//       case 'Quarter':
//         return DateTime(now.year, (now.month - 1) ~/ 3 * 3 + 1, 1);
//       case 'Year':
//         return DateTime(now.year, 1, 1);
//       default:
//         return DateTime(now.year, now.month, 1);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Analytics Dashboard'),
//         backgroundColor: _primaryColor,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _fetchNewData,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator(color: _primaryColor))
//           : RefreshIndicator(
//               onRefresh: _fetchNewData,
//               color: _primaryColor,
//               child: SingleChildScrollView(
//                 physics: AlwaysScrollableScrollPhysics(),
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildSummaryCards(),
//                       SizedBox(height: 24),
//                      // _buildSalesGraphButton(),
//                       SizedBox(height: 24),
//                       _buildTopProductsSection(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// Widget _buildSummaryCards() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Revenue & Profit Metrics',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryColor),
//         ),
//         SizedBox(height: 16),
//         Wrap(
//           spacing: 16,
//           runSpacing: 16,
//           children: [
//             _buildMetricCard('Day', Icons.today),
//             _buildMetricCard('Week', Icons.view_week),
//             _buildMetricCard('Month', Icons.calendar_today),
//             _buildMetricCard('Quarter', Icons.pie_chart),
//             _buildMetricCard('Year', Icons.timeline),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildMetricCard(String timeFrame, IconData icon) {
//     final revenue = _revenueMetrics[timeFrame] ?? 0;
//     final profit = _profitMetrics[timeFrame] ?? 0;

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   timeFrame,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor),
//                 ),
//                 Icon(icon, color: _primaryColor),
//               ],
//             ),
//             SizedBox(height: 12),
//             _buildMetricRow('Revenue', revenue),
//             SizedBox(height: 8),
//             _buildMetricRow('Profit', profit),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMetricRow(String label, double amount) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: TextStyle(fontSize: 14)),
//         Text(
//           NumberFormat.currency(symbol: '₹').format(amount),
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: amount >= 0 ? Colors.green : Colors.red,
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget _buildSalesGraphButton() {
//   //   return ElevatedButton.icon(
//   //     onPressed: () {
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(builder: (context) => SalesGraphPage()),
//   //       );
//   //     },
//   //     icon: Icon(Icons.show_chart),
//   //     label: Text('Show Sales Graph'),
//   //     style: ElevatedButton.styleFrom(
//   //       backgroundColor: _primaryColor,
//   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//   //       padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//   //     ),
//   //   );
//   // }

//   Widget _buildTopProductsSection() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Top 5 Products',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryColor),
//                 ),
//                 DropdownButton<String>(
//                   value: _selectedTimeFrame,
//                   items: ['Day', 'Week', 'Month', 'Quarter', 'Year']
//                       .map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     if (newValue != null) {
//                       setState(() {
//                         _selectedTimeFrame = newValue;
//                         _getTopSellingProducts();
//                       });
//                     }
//                   },
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             _topProducts.isNotEmpty
//                 ? ListView.separated(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: _topProducts.length,
//                     itemBuilder: (context, index) {
//                       final product = _topProducts[index];
//                       return _buildProductListItem(product, index);
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

//   Widget _buildProductListItem(Map<String, dynamic> product, int index) {
//     return ExpansionTile(
//       leading: Stack(
//         alignment: Alignment.center,
//         children: [
//           // CircleAvatar(
//           //   backgroundColor: _primaryColor,
//           //   child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
//           // ),
//           // CachedNetworkImage(
//           //   imageUrl: product['imageUrl'],
//           //   placeholder: (context, url) => CircularProgressIndicator(),
//           //   errorWidget: (context, url, error) => Icon(Icons.error),
//           //   width: 40,
//           //   height: 40,
//           //   fit: BoxFit.cover,
//           // ),
//         ],
//       ),
//       title: Text(
//         product['name'],
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       subtitle: Text(
//         '${NumberFormat.compact().format(product['quantitySold'])} sold',
//         style: TextStyle(color: _primaryColor),
//       ),
//       children: [
//         Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildProductDetailRow('Quantity Sold', product['quantitySold'].toString()),
//               _buildProductDetailRow('Revenue', NumberFormat.currency(symbol: '₹').format(product['revenue'])),
//               _buildProductDetailRow('Profit', NumberFormat.currency(symbol: '₹').format(product['profit'])),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProductDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//           Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }