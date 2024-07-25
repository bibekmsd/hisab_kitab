import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyStock extends StatefulWidget {
  final TextEditingController _name = TextEditingController();
  MyStock({super.key});

  @override
  State<MyStock> createState() => _MyStockState();
}

class _MyStockState extends State<MyStock> {
  String searchQuery = '';
  String selectedProductType = 'All'; // Default to 'All'
  final List<String> productTypes = [
    'All',
    'Beauty care and Hygiene',
    'Cleaning and household',
    'Eggs, meat and fish',
    'Food grains, oil and masala',
    'Fruits and vegetables',
    'Health and wellness',
    'Snacks'
    // Add other product types here
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget._name.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      searchQuery = value.trim();
    });
  }

  void _onProductTypeChanged(String? newValue) {
    setState(() {
      selectedProductType = newValue ?? 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Stock"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: widget._name,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter product name',
              ),
              onSubmitted: _onSearchSubmitted,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedProductType,
              onChanged: _onProductTypeChanged,
              items: productTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              isExpanded: true,
              hint: Text('Select Product Type'),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (selectedProductType == 'All' && searchQuery.isEmpty)
                  ? FirebaseFirestore.instance
                      .collection("ProductsNew")
                      .snapshots()
                  : selectedProductType == 'All'
                      ? FirebaseFirestore.instance
                          .collection("ProductsNew")
                          .where('Name', isEqualTo: searchQuery)
                          .snapshots()
                      : searchQuery.isEmpty
                          ? FirebaseFirestore.instance
                              .collection("ProductsNew")
                              .where('ProductType',
                                  isEqualTo: selectedProductType)
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection("ProductsNew")
                              .where('Name', isEqualTo: searchQuery)
                              .where('ProductType',
                                  isEqualTo: selectedProductType)
                              .snapshots(),
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
                    var products = snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;

                      return Product(
                        barcode: doc.id,
                        name: data['Name']?.toString() ?? '',
                        quantity: data['Quantity']?.toString() ?? '0',
                        price: data['Price']?.toString() ?? '0.0',
                      );
                    }).toList();

                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          shadowColor: const Color.fromARGB(255, 48, 26, 26),
                          elevation: 8,
                          surfaceTintColor:
                              const Color.fromARGB(255, 19, 124, 71),
                          child: ListTile(
                            tileColor: const Color.fromARGB(255, 220, 229, 237),
                            leading: Text((index + 1).toString()),
                            title: Text(product.name),
                            subtitle: Text(
                                'Price: ${(product.price)}, Quantity: ${(product.quantity)}'),
                            trailing: Text('Barcode: ${product.barcode}'),
                          ),
                        );
                      },
                    );
                  }
                }
                return const Center(child: Text("Loading..."));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String barcode;
  final String name;
  final String quantity;
  final String price;

  Product({
    required this.barcode,
    required this.name,
    required this.quantity,
    required this.price,
  });
}
