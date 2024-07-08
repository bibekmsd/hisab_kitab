import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyStock extends StatefulWidget {
  const MyStock({super.key});

  @override
  State<MyStock> createState() => _MyStockState();
}

class _MyStockState extends State<MyStock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Stock"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Products").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LinearProgressIndicator());
          }
          if (snapshot.connectionState == ConnectionState.active) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No Data in database"));
            } else {
              // Map the documents to Product objects
              var products = snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return Product(
                  barcode: doc.id,
                  name: data['Name'] ?? '',
                  quantity: data['quantity'] ?? 0,
                  price: data['Price'] ?? 0.0,
                );
              }).toList();

              // Return the ListView.builder to display the products
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    shadowColor: const Color.fromARGB(255, 48, 26, 26),
                    elevation: 8,
                    surfaceTintColor: const Color.fromARGB(255, 19, 124, 71),
                    child: ListTile(
                      tileColor: Color.fromARGB(255, 220, 229, 237),
                      leading: Text((index + 1).toString()),
                      title: Text(product.name),
                      subtitle: Text(
                          'Price: ${product.price}, Quantity: ${product.quantity}'),
                      trailing: Text('Barcode: ${product.barcode}'),
                    ),
                  );
                },
              );
            }
          }
          // Return a placeholder or fallback widget in case the connection state is not handled above
          return const Center(child: Text("Loading..."));
        },
      ),
    );
  }
}

// Define the Product model
class Product {
  final String barcode;
  final String name;
  final int quantity;
  final String price;

  Product({
    required this.barcode,
    required this.name,
    required this.quantity,
    required this.price,
  });
}
