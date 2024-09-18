import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Transactions', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFilteredStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.hourglass_empty,
                    size: 50,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No transactions found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Please check back later.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildTransactionsList(snapshot.data!.docs);
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    var query = FirebaseFirestore.instance
        .collection('bills')
        .orderBy('PurchaseDate', descending: true);
    if (_selectedDate != null) {
      var startOfDay = DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      var endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .where('PurchaseDate', isGreaterThanOrEqualTo: startOfDay)
          .where('PurchaseDate', isLessThan: endOfDay);
    }
    return query.snapshots();
  }

  Widget _buildTransactionsList(List<DocumentSnapshot> documents) {
    Map<String, List<DocumentSnapshot>> groupedDocs = {};
    Map<String, double> dailyTotals = {};

    for (var doc in documents) {
      var data = doc.data() as Map<String, dynamic>;
      var date = (data['PurchaseDate'] as Timestamp).toDate();
      var dateString = DateFormat('yyyy-MM-dd').format(date);

      if (!groupedDocs.containsKey(dateString)) {
        groupedDocs[dateString] = [];
        dailyTotals[dateString] = 0;
      }
      groupedDocs[dateString]!.add(doc);

      var total = (data['Products'] as List<dynamic>).fold<double>(
          0,
          (sum, product) =>
              sum +
              ((product['quantity'] as num?) ?? 0) *
                  ((product['price'] as num?) ?? 0));
      dailyTotals[dateString] = (dailyTotals[dateString] ?? 0) + total;
    }

    return ListView.builder(
      itemCount: groupedDocs.length,
      itemBuilder: (context, index) {
        var date = groupedDocs.keys.elementAt(index);
        var docs = groupedDocs[date]!;
        return _buildDateGroup(date, docs, dailyTotals[date]!);
      },
    );
  }

  Widget _buildDateGroup(
      String date, List<DocumentSnapshot> docs, double dailyTotal) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              DateFormat('MMMM d, yyyy').format(DateTime.parse(date)),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            trailing: Text(
              'Total: ₹${dailyTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
          ...docs.map((doc) => _buildBillCard(doc)).toList(),
        ],
      ),
    );
  }

  Widget _buildBillCard(DocumentSnapshot bill) {
    var billData = bill.data() as Map<String, dynamic>;
    var customerPhone = billData['CustomerPhone'] as String? ?? 'N/A';
    var total = (billData['Products'] as List<dynamic>).fold<double>(
        0,
        (sum, product) =>
            sum +
            ((product['quantity'] as num?) ?? 0) *
                ((product['price'] as num?) ?? 0));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Bill #${bill.id}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Customer: $customerPhone'),
        trailing: Text('₹${total.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () => _showBillDetails(bill),
      ),
    );
  }

  void _showBillDetails(DocumentSnapshot bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => _buildBillDetailsSheet(bill, controller),
      ),
    );
  }

  Widget _buildBillDetailsSheet(
      DocumentSnapshot bill, ScrollController controller) {
    var billData = bill.data() as Map<String, dynamic>;
    var products = billData['Products'] as List<dynamic>;
    var customerPhone = billData['CustomerPhone'] as String? ?? 'N/A';
    var purchaseDate = (billData['PurchaseDate'] as Timestamp).toDate();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: controller,
        children: [
          const Text('Bill Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text('Bill #${bill.id}',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Date: ${DateFormat('MMM d, yyyy HH:mm').format(purchaseDate)}'),
          Text('Customer: $customerPhone'),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: ['Product', 'Qty', 'Price', 'Total']
                    .map((text) => _buildTableCell(text, isHeader: true))
                    .toList(),
              ),
              ...products.map((product) {
                var name = product['name'] as String? ?? 'N/A';
                var quantity = product['quantity'] as num? ?? 0;
                var price = product['price'] as num? ?? 0;
                var totalPrice = quantity * price;
                return TableRow(
                  children: [
                    _buildTableCell(name),
                    _buildTableCell(quantity.toString()),
                    _buildTableCell('₹${price.toStringAsFixed(2)}'),
                    _buildTableCell('₹${totalPrice.toStringAsFixed(2)}'),
                  ],
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total: ₹${products.fold<double>(0, (sum, product) => sum + ((product['quantity'] as num?) ?? 0) * ((product['price'] as num?) ?? 0)).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:heroicons/heroicons.dart';
// import 'package:intl/intl.dart';

// class TransactionsPage extends StatefulWidget {
//   const TransactionsPage({super.key});

//   @override
//   _TransactionsPageState createState() => _TransactionsPageState();
// }

// class _TransactionsPageState extends State<TransactionsPage> {
//   DateTime? _selectedDate;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Transactions'),
//         actions: [
//           IconButton(
//             icon: const HeroIcon(HeroIcons.calendarDays),
//             onPressed: () => _selectDate(context),
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _getFilteredStream(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.hourglass_empty,
//                     size: 50,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'No transactions found',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       // color: Colors.grey[700],
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     'Please check back later.',
//                     style: TextStyle(
//                       fontSize: 14,
//                       // color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return _buildTransactionsList(snapshot.data!.docs);
//         },
//       ),
//     );
//   }

//   Stream<QuerySnapshot> _getFilteredStream() {
//     var query = FirebaseFirestore.instance
//         .collection('bills')
//         .orderBy('PurchaseDate', descending: true);
//     if (_selectedDate != null) {
//       var startOfDay = DateTime(
//           _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
//       var endOfDay = startOfDay.add(const Duration(days: 1));
//       query = query
//           .where('PurchaseDate', isGreaterThanOrEqualTo: startOfDay)
//           .where('PurchaseDate', isLessThan: endOfDay);
//     }
//     return query.snapshots();
//   }

//   Widget _buildTransactionsList(List<DocumentSnapshot> documents) {
//     Map<String, List<DocumentSnapshot>> groupedDocs = {};
//     Map<String, double> dailyTotals = {};

//     for (var doc in documents) {
//       var data = doc.data() as Map<String, dynamic>;
//       var date = (data['PurchaseDate'] as Timestamp).toDate();
//       var dateString = DateFormat('yyyy-MM-dd').format(date);

//       if (!groupedDocs.containsKey(dateString)) {
//         groupedDocs[dateString] = [];
//         dailyTotals[dateString] = 0;
//       }
//       groupedDocs[dateString]!.add(doc);

//       var total = (data['Products'] as List<dynamic>).fold<double>(
//           0,
//           (sum, product) =>
//               sum +
//               ((product['quantity'] as num?) ?? 0) *
//                   ((product['price'] as num?) ?? 0));
//       dailyTotals[dateString] = (dailyTotals[dateString] ?? 0) + total;
//     }

//     return ListView.builder(
//       itemCount: groupedDocs.length,
//       itemBuilder: (context, index) {
//         var date = groupedDocs.keys.elementAt(index);
//         var docs = groupedDocs[date]!;
//         return _buildDateGroup(date, docs, dailyTotals[date]!);
//       },
//     );
//   }

//   Widget _buildDateGroup(
//       String date, List<DocumentSnapshot> docs, double dailyTotal) {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: Column(
//         children: [
//           ListTile(
//             title: Text(
//               DateFormat('MMMM d, yyyy').format(DateTime.parse(date)),
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             trailing: Text(
//               'Total: ₹${dailyTotal.toStringAsFixed(2)}',
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green,
//                   fontSize: 18),
//             ),
//           ),
//           ...docs.map((doc) => _buildBillCard(doc)).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildBillCard(DocumentSnapshot bill) {
//     var billData = bill.data() as Map<String, dynamic>;
//     var customerPhone = billData['CustomerPhone'] as String? ?? 'N/A';
//     var total = (billData['Products'] as List<dynamic>).fold<double>(
//         0,
//         (sum, product) =>
//             sum +
//             ((product['quantity'] as num?) ?? 0) *
//                 ((product['price'] as num?) ?? 0));

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListTile(
//         title: Text('Bill #${bill.id}',
//             style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text('Customer: $customerPhone'),
//         trailing: Text('₹${total.toStringAsFixed(2)}',
//             style: const TextStyle(fontWeight: FontWeight.bold)),
//         onTap: () => _showBillDetails(bill),
//       ),
//     );
//   }

//   void _showBillDetails(DocumentSnapshot bill) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         minChildSize: 0.5,
//         maxChildSize: 0.9,
//         expand: false,
//         builder: (_, controller) => _buildBillDetailsSheet(bill, controller),
//       ),
//     );
//   }

//   Widget _buildBillDetailsSheet(
//       DocumentSnapshot bill, ScrollController controller) {
//     var billData = bill.data() as Map<String, dynamic>;
//     var products = billData['Products'] as List<dynamic>;
//     var customerPhone = billData['CustomerPhone'] as String? ?? 'N/A';
//     var purchaseDate = (billData['PurchaseDate'] as Timestamp).toDate();

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         // color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: ListView(
//         controller: controller,
//         children: [
//           const Text('Bill Details',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 16),
//           Text('Bill #${bill.id}',
//               style:
//                   const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           Text('Date: ${DateFormat('MMM d, yyyy HH:mm').format(purchaseDate)}'),
//           Text('Customer: $customerPhone'),
//           const SizedBox(height: 16),
//           Table(
//             border: TableBorder.all(),
//             columnWidths: const {
//               0: FlexColumnWidth(3),
//               1: FlexColumnWidth(1),
//               2: FlexColumnWidth(2),
//               3: FlexColumnWidth(2),
//             },
//             children: [
//               TableRow(
//                 decoration: BoxDecoration(),
//                 children: ['Product', 'Qty', 'Price', 'Total']
//                     .map((text) => _buildTableCell(text, isHeader: true))
//                     .toList(),
//               ),
//               ...products.map((product) {
//                 var name = product['name'] as String? ?? 'N/A';
//                 var quantity = product['quantity'] as num? ?? 0;
//                 var price = product['price'] as num? ?? 0;
//                 var totalPrice = quantity * price;
//                 return TableRow(
//                   children: [
//                     _buildTableCell(name),
//                     _buildTableCell(quantity.toString()),
//                     _buildTableCell('₹${price.toStringAsFixed(2)}'),
//                     _buildTableCell('₹${totalPrice.toStringAsFixed(2)}'),
//                   ],
//                 );
//               }).toList(),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Total: ₹${products.fold<double>(0, (sum, product) => sum + ((product['quantity'] as num?) ?? 0) * ((product['price'] as num?) ?? 0)).toStringAsFixed(2)}',
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTableCell(String text, {bool isHeader = false}) {
//     return Padding(
//       padding: const EdgeInsets.all(8),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
//         ),
//         textAlign: isHeader ? TextAlign.center : TextAlign.left,
//       ),
//     );
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
// }
