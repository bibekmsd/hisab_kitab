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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .get(),
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

          // Get customer data
          var customerData = snapshot.data!.data() as Map<String, dynamic>;

          // Parse fields
          String name = customerData['Name'] ?? '';
          String address = customerData['Address'] ?? '';
          String birthDate = customerData['BirthDate'] ?? '';
          String phoneNo = customerData['PhoneNo'] ?? '';
          String notes = customerData['Notes'] ?? '';
          Timestamp createdAtTimestamp =
              customerData['createdAt'] ?? Timestamp.now();
          DateTime createdAt = createdAtTimestamp.toDate();
          String memberSince = DateFormat('yyyy-MM-dd').format(createdAt);

          // Get purchase history
          Map<String, dynamic> history = customerData['History'] ?? {};

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: $name", style: TextStyle(fontSize: 20)),
                  Text("Address: $address", style: TextStyle(fontSize: 20)),
                  Text("Birth Date: $birthDate",
                      style: TextStyle(fontSize: 20)),
                  Text("Phone No: $phoneNo", style: TextStyle(fontSize: 20)),
                  Text("Notes: $notes", style: TextStyle(fontSize: 20)),
                  Text("Member Since: $memberSince",
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  Text("Purchase History",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ...history.entries.map((entry) {
                    String date = entry.key;
                    List purchases = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date: $date",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        ...purchases.map((purchase) {
                          List products = purchase['Products'];
                          DateTime purchaseDate =
                              (purchase['PurchaseDate'] as Timestamp).toDate();
                          String formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                              .format(purchaseDate);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Purchase Date: $formattedDate",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic)),
                              ...products.map((product) {
                                String productName = product['name'];
                                int price = product['price'] is double
                                    ? (product['price'] as double).toInt()
                                    : product['price'];
                                int quantity = product['quantity'] is double
                                    ? (product['quantity'] as double).toInt()
                                    : product['quantity'];
                                int totalPrice = product['totalPrice'] is double
                                    ? (product['totalPrice'] as double).toInt()
                                    : product['totalPrice'];

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                      "$productName - $quantity x $price = $totalPrice"),
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ],
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
}
