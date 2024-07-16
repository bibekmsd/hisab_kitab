// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/add_customer.dart';

class CheckOutPage extends StatelessWidget {
  final List<Map<String, dynamic>> productDetails;
  final int totalQuantity;
  final double totalPrice;
  final String customerPhone;

  const CheckOutPage({
    super.key,
    required this.productDetails,
    required this.totalQuantity,
    required this.totalPrice,
    required this.customerPhone,
  });

  @override
  Widget build(BuildContext context) {
    void showCheckOutForm() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: 700, minHeight: 600),
        builder: (context) => AddCustomers(productDetails: productDetails),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Check Out'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receipt',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: productDetails.length,
                itemBuilder: (context, index) {
                  final product = productDetails[index];
                  return Card(
                    child: ListTile(
                      title: Text(product['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Barcode: ${product['barcode']}'),
                          Text(
                              'Price: \$${product['price'].toStringAsFixed(2)}'),
                          Text('Quantity: ${product['quantity']}'),
                          Text(
                              'Total: \$${product['totalPrice'].toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Text('Total Quantity: $totalQuantity'),
            Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: showCheckOutForm,
                        child: Text('Add Customers'),
                      ),
                      // ElevatedButton(
                      //   onPressed: addDataToDatabase,
                      //   child: Text('Add Data'),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
