import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerDetails extends StatelessWidget {
  final String customerId;

  CustomerDetails({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No Data Found"));
          }

          var customerData = snapshot.data!.data() as Map<String, dynamic>;

          String name = customerData['Name'] ?? '';
          String address = customerData['Address'] ?? '';
          String birthDate = customerData['BirthDate'] ?? '';
          String phoneNo = customerData['PhoneNo'] ?? '';
          String notes = customerData['Notes'] ?? '';
          Timestamp createdAtTimestamp =
              customerData['createdAt'] ?? Timestamp.now();
          DateTime createdAt = createdAtTimestamp.toDate();
          String memberSince = DateFormat('yyyy-MM-dd').format(createdAt);

          List<dynamic> history = customerData['History'] ?? [];

          // Sort history entries
          history.sort((a, b) {
            var aDate = a['PurchaseDate'] as Timestamp;
            var bDate = b['PurchaseDate'] as Timestamp;
            return bDate.compareTo(aDate);
          });

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    title: 'Customer Information',
                    content: [
                      _buildInfoRow('Name', name),
                      _buildInfoRow('Address', address),
                      _buildInfoRow('Birth Date', birthDate),
                      _buildInfoRow('Phone No', phoneNo),
                      _buildInfoRow('Member Since', memberSince),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildInfoCard(
                    title: 'Additional Notes',
                    content: [Text(notes)],
                  ),
                  SizedBox(height: 20),
                  Text("Purchase History",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ...history.map((purchase) {
                    String billNumber = purchase['BillNumber'] ?? '';
                    List products = purchase['Products'] ?? [];
                    DateTime purchaseDate =
                        (purchase['PurchaseDate'] as Timestamp).toDate();
                    String formattedDate =
                        DateFormat('yyyy-MM-dd HH:mm').format(purchaseDate);

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Bill Number: $billNumber",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Purchase Date: $formattedDate",
                                style: TextStyle(
                                    fontSize: 16, fontStyle: FontStyle.italic)),
                            SizedBox(height: 10),
                            Table(
                              border: TableBorder.all(),
                              columnWidths: {
                                0: FlexColumnWidth(2.5),
                                1: FlexColumnWidth(1.5),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(1),
                              },
                              children: [
                                TableRow(
                                  decoration:
                                      BoxDecoration(color: Colors.grey[200]),
                                  children: [
                                    _buildTableHeader('Product Name'),
                                    _buildTableHeader('Quantity'),
                                    _buildTableHeader('Price'),
                                    _buildTableHeader('Total Price'),
                                  ],
                                ),
                                ...products.map((product) {
                                  String productName = product['name'] ?? '';
                                  int price =
                                      (product['price'] as num?)?.toInt() ?? 0;
                                  int quantity =
                                      (product['quantity'] as num?)?.toInt() ??
                                          0;
                                  int totalPrice =
                                      (product['totalPrice'] as num?)
                                              ?.toInt() ??
                                          0;

                                  return TableRow(
                                    children: [
                                      _buildTableCell(productName),
                                      _buildTableCell(quantity.toString()),
                                      _buildTableCell(price.toString()),
                                      _buildTableCell(totalPrice.toString()),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required List<Widget> content}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ':',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class CustomerDetails extends StatelessWidget {
//   final String customerId;

//   CustomerDetails({required this.customerId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Customer Details'),
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('customers')
//             .doc(customerId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return Center(child: Text("No Data Found"));
//           }

//           var customerData = snapshot.data!.data() as Map<String, dynamic>;

//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildCustomerInfo(customerData),
//                   SizedBox(height: 20),
//                   _buildAdditionalNotes(customerData['Notes'] ?? ''),
//                   SizedBox(height: 20),
//                   _buildPurchaseHistory(customerData['History'] ?? {}),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildCustomerInfo(Map<String, dynamic> data) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Customer Information',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             _buildInfoRow('Name', data['Name'] ?? ''),
//             _buildInfoRow('Address', data['Address'] ?? ''),
//             _buildInfoRow('Birth Date', data['BirthDate'] ?? ''),
//             _buildInfoRow('Phone No', data['PhoneNo'] ?? ''),
//             _buildInfoRow('Member Since', _formatTimestamp(data['updatedAt'])),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAdditionalNotes(String notes) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Additional Notes',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Text(notes.isEmpty ? 'No additional notes' : notes),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPurchaseHistory(Map<String, dynamic> history) {
//     if (history.isEmpty) {
//       return Text('No purchase history available.');
//     }

//     var sortedHistory = history.entries.toList()
//       ..sort((a, b) => int.parse(b.key).compareTo(int.parse(a.key))); // Sort by numeric key (descending)

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Purchase History',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//         SizedBox(height: 10),
//         ...sortedHistory.map((entry) => _buildPurchaseCard(entry.key, entry.value)),
//       ],
//     );
//   }

//   Widget _buildPurchaseCard(String billNumber, Map<String, dynamic> purchase) {
//     var products = purchase['Products'] as List<dynamic>? ?? [];
//     var customerPhone = purchase['CustomerPhone'] as String? ?? '';
//     var purchaseDate = purchase['PurchaseDate'] as Timestamp?;

//     return Card(
//       margin: EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Purchase #$billNumber",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text("Customer Phone: $customerPhone",
//                 style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
//             if (purchaseDate != null)
//               Text("Purchase Date: ${_formatTimestamp(purchaseDate)}",
//                   style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
//             SizedBox(height: 10),
//             Table(
//               border: TableBorder.all(),
//               columnWidths: {
//                 0: FlexColumnWidth(2),
//                 1: FlexColumnWidth(1),
//                 2: FlexColumnWidth(1),
//                 3: FlexColumnWidth(1),
//                 4: FlexColumnWidth(1),
//               },
//               children: [
//                 TableRow(
//                   decoration: BoxDecoration(color: Colors.grey[200]),
//                   children: [
//                     _buildTableHeader('Product'),
//                     _buildTableHeader('Price'),
//                     _buildTableHeader('Quantity'),
//                     _buildTableHeader('Total'),
//                     _buildTableHeader('Barcode'),
//                   ],
//                 ),
//                 ...products.map((product) => _buildProductRow(product)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   TableRow _buildProductRow(Map<String, dynamic> product) {
//     return TableRow(
//       children: [
//         _buildTableCell(product['name'] ?? ''),
//         _buildTableCell(product['price'].toString()),
//         _buildTableCell(product['quantity'].toString()),
//         _buildTableCell(product['totalPrice'].toString()),
//         _buildTableCell(product['barcode'] ?? ''),
//       ],
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label + ':',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   Widget _buildTableHeader(String text) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(
//         text,
//         style: TextStyle(fontWeight: FontWeight.bold),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   Widget _buildTableCell(String text) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(
//         text,
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) return 'N/A';
//     return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
//   }
// }
