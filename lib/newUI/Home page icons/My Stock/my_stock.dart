import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyStock extends StatefulWidget {
  const MyStock({Key? key}) : super(key: key);

  @override
  State<MyStock> createState() => _MyStockState();
}

class _MyStockState extends State<MyStock> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  String selectedProductType = 'All';

  final List<String> productTypes = [
    'All',
    'Personal Care & Hygiene',
    'Home Cleaning & Essentials',
    'Fresh Meat, Fish & Eggs',
    'Staples, Oils & Spices',
    'Fruits & Vegetables',
    'Health & Wellness',
    'Snacks & Confectionery',
    'Beverages & Drinks',
    'Dairy & Bakery',
    'Frozen Foods',
    'Baby Care',
    'Packaged Foods',
    'Organic & Gourmet'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.trim();
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
        title: const Text(
          "My Stock",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 99, 162, 225),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "All Stock"),
            Tab(text: "Low Stock"),
          ],
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildProductTypeDropdown(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStockList(isLowStock: false),
                _buildStockList(isLowStock: true),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new product functionality
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 99, 162, 225),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color.fromARGB(255, 173, 205, 241),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search,
              color: Color.fromARGB(255, 99, 162, 225)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProductTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: const Color.fromARGB(255, 173, 205, 241),
      child: DropdownButtonFormField<String>(
        value: selectedProductType,
        onChanged: _onProductTypeChanged,
        items: productTypes.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Product Type',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStockList({required bool isLowStock}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getProductStream(isLowStock: isLowStock),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const NoProductsWidget();
        }

        var products = snapshot.data!.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Product(
            barcode: doc.id,
            name: data['Name']?.toString() ?? '',
            quantity: data['Quantity']?.toString() ?? '0',
            price: data['Price']?.toString() ?? '0.0',
            imageUrl: data['ImageUrl']?.toString() ??
                '', // Fetch image URL from Firestore
          );
        }).toList();

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product, index);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: const Color.fromARGB(255, 173, 205, 241),
          backgroundImage: product.imageUrl.isNotEmpty
              ? NetworkImage(
                  product.imageUrl) // Show product image if available
              : null,
          child: product.imageUrl.isEmpty
              ? const Icon(
                  Icons
                      .image_not_supported, // Standard "no image" icon if no image is uploaded
                  size: 30,
                  color: Color.fromARGB(255, 99, 162, 225),
                )
              : null,
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Price: ₹${product.price}'),
            Text('Quantity: ${product.quantity}'),
            Text('Barcode: ${product.barcode}',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getProductStream({required bool isLowStock}) {
    CollectionReference productsCollection =
        FirebaseFirestore.instance.collection("ProductsNew");
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
      query = query.where('Quantity', isLessThanOrEqualTo: 10);
    }

    return query.snapshots();
  }
}

class Product {
  final String barcode;
  final String name;
  final String quantity;
  final String price;
  final String imageUrl; // New field for the image URL

  Product({
    required this.barcode,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl, // Add this field to the constructor
  });
}

class NoProductsWidget extends StatelessWidget {
  const NoProductsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 80,
              color: const Color.fromARGB(255, 12, 47, 84).withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No Products Available',
            style:
                TextStyle(fontSize: 20, color: Color.fromARGB(255, 5, 32, 61)),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started!',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
