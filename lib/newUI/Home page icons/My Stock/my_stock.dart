import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyStock extends StatefulWidget {
  const MyStock({super.key});

  @override
  State<MyStock> createState() => _MyStockState();
}

class _MyStockState extends State<MyStock> with SingleTickerProviderStateMixin {
  late TabController _tabController; // Controller for tab switching
  final TextEditingController _nameController =
      TextEditingController(); // Controller for text field
  String searchQuery = ''; // Variable to hold the search query
  String selectedProductType =
      'All'; // Variable to hold the selected product type, defaults to 'All'

  final List<String> productTypes = [
    // List of product types for the dropdown
    'All',
    'Beauty care and Hygiene',
    'Cleaning and household',
    'Eggs, meat and fish',
    'Food grains, oil and masala',
    'Fruits and vegetables',
    'Health and wellness',
    'Snacks'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this); // Initializing the TabController with 2 tabs
    _nameController.addListener(
        _onSearchChanged); // Adding listener for changes in the text field
  }

  @override
  void dispose() {
    _tabController.dispose(); // Disposing the TabController
    _nameController.removeListener(_onSearchChanged); // Removing listener
    _nameController.dispose(); // Disposing the TextEditingController
    super.dispose();
  }

  void _onSearchChanged() {
    // Called when text in search bar changes
    setState(() {
      searchQuery = _nameController.text
          .trim(); // Trimming the search text and updating the state
    });
  }

  void _onSearchSubmitted(String value) {
    // Called when search is submitted
    setState(() {
      searchQuery =
          value.trim(); // Trimming the submitted text and updating the state
    });
  }

  void _onProductTypeChanged(String? newValue) {
    // Called when the product type is changed
    setState(() {
      selectedProductType =
          newValue ?? 'All'; // Updating the selected product type
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Stock"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "All Stock"),
            Tab(text: "Low Stock"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStockList(isLowStock: false),
          _buildStockList(isLowStock: true),
        ],
      ),
    );
  }

  Widget _buildStockList({required bool isLowStock}) {
    // Builds the stock list UI
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _nameController,
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
              // Map each product type into a dropdown item
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            isExpanded: true,
            hint: const Text('Select Product Type'),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getProductStream(isLowStock: isLowStock),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LinearProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return NoProductsWidget();
              }

              var products = snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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
                    surfaceTintColor: const Color.fromARGB(255, 19, 124, 71),
                    child: ListTile(
                      tileColor: const Color.fromARGB(255, 220, 229, 237),
                      leading: Text((index + 1).toString()),
                      title: Text(product.name),
                      subtitle: Text(
                        'Price: ${product.price}, Quantity: ${product.quantity}',
                      ),
                      trailing: Text('Barcode: ${product.barcode}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getProductStream({required bool isLowStock}) {
    CollectionReference productsCollection =
        FirebaseFirestore.instance.collection("ProductsNew");

    // Building the query based on selected options
    Query query = productsCollection;

    if (selectedProductType != 'All') {
      query = query.where('ProductType', isEqualTo: selectedProductType);
    }

    if (searchQuery.isNotEmpty) {
      query = query
          .where('Name', isGreaterThanOrEqualTo: searchQuery)
          .where('Name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    if (isLowStock) {
      query = query.where('Quantity',
          isLessThanOrEqualTo: 10); // Low stock threshold
    }

    return query.snapshots();
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

class NoProductsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning, size: 50, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'No Products Available',
            style: TextStyle(fontSize: 20, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
