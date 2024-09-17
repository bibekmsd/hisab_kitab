
  
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
        backgroundColor: Colors.blue,
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

          Map<String, dynamic> history = customerData['History'] ?? {};

          // Convert history entries to a list and sort
          var sortedHistory = history.entries.toList()
            ..sort((a, b) {
              var aDate = a.value['PurchaseDate'] as Timestamp;
              var bDate = b.value['PurchaseDate'] as Timestamp;
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
                  ...sortedHistory.map((entry) {
                    String billNumber = entry.key;
                    var purchase = entry.value;
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
                                  decoration: BoxDecoration(color: Colors.grey[200]),
                                  children: [
                                    _buildTableHeader('Product Name'),
                                    _buildTableHeader('Quantity'),
                                    _buildTableHeader('Price'),
                                    _buildTableHeader('Total Price'),
                                  ],
                                ),
                                ...products.map((product) {
                                  String productName = product['name'] ?? '';
                                  int price = (product['price'] as num?)?.toInt() ?? 0;
                                  int quantity = (product['quantity'] as num?)?.toInt() ?? 0;
                                  int totalPrice = (product['totalPrice'] as num?)?.toInt() ?? 0;

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

Widget _buildInfoCard({required String title, required List<Widget> content}) {
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
