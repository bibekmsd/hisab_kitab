import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> lowStockProducts =
      []; // List to store low stock products

  @override
  void initState() {
    super.initState();
    checkLowStockProducts();
  }

  // Function to check low stock products
  Future<void> checkLowStockProducts() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('ProductsNew') // Collection name from your screenshot
        .get();

    List<Map<String, dynamic>> tempLowStockProducts = [];

    for (var doc in querySnapshot.docs) {
      // Each document is identified by the barcode, with the product details inside
      var productData = doc.data() as Map<String, dynamic>; // Cast data to Map
      if (productData['Quantity'] != null && productData['Quantity'] < 10) {
        tempLowStockProducts
            .add(productData); // Add the product to the low-stock list
      }
    }

    if (tempLowStockProducts.isNotEmpty) {
      setState(() {
        lowStockProducts = tempLowStockProducts;
      });

    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Notification'),
      ),
      body: lowStockProducts.isEmpty
          ? const Center(child: Text('No low stock products at the moment.'))
          : ListView.builder(
              itemCount: lowStockProducts.length,
              itemBuilder: (context, index) {
                var product = lowStockProducts[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  child: ListTile(
                    title: Text(product['Name'] ?? 'Unknown Product'),
                    subtitle: Text('Only ${product['Quantity']} items left.'),
                    trailing: Text('Barcode: ${product['Barcode']}'),
                  ),
                );
              },
            ),
    );
  }
}
