import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/Add%20Products/nabhetekoProductAdd.dart';
import 'package:heroicons/heroicons.dart';

class MyStock extends StatefulWidget {
  const MyStock({super.key});

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
    'Groceries', 
    'Household Essentials',
    'Personal Care',
    'Stationery and Office Supplies', 
    'Snacks and Beverages',
    'Fruits, Vegetables, Eggs, and Dairy'
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Product Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: productTypes.length,
                      itemBuilder: (context, index) {
                        return RadioListTile<String>(
                          title: Text(productTypes[index]),
                          value: productTypes[index],
                          groupValue: selectedProductType,
                          onChanged: (value) {
                            setState(() {
                              selectedProductType = value!;
                            });
                            Navigator.pop(context);
                            this.setState(() {}); // Refresh the main screen
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "My Stock",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        // backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const HeroIcon(HeroIcons.chevronLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.adjustmentsHorizontal),
            onPressed: _showFilterBottomSheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "All Stock"),
              Tab(text: "Low Stock"),
            ],
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            indicatorColor: const Color.fromARGB(255, 0, 0, 0),
            labelColor: const Color.fromARGB(255, 0, 0, 0),
            unselectedLabelColor: const Color.fromARGB(255, 88, 79, 79),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NabhetekoProductPage(),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 99, 162, 225),
        child: const HeroIcon(HeroIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const HeroIcon(HeroIcons.magnifyingGlass,
              color: Color.fromARGB(255, 99, 162, 225)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildStockList({required bool isLowStock}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getProductStream(isLowStock: isLowStock),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                HeroIcon(
                  HeroIcons.cube,
                  size: 80,
                  color:
                      const Color.fromARGB(255, 99, 162, 225).withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Products Available',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 99, 162, 225)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Item in Stock!',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ]));
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
            imageUrl: data['ImageUrl']?.toString() ?? '',
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const HeroIcon(HeroIcons.photo,
                          color: Colors.grey, size: 40),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const HeroIcon(HeroIcons.currencyRupee,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(product.price,
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Row(
                    children: [
                      const HeroIcon(HeroIcons.cube,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Qty: ${product.quantity}'),
                    ],
                  ),
                  Row(
                    children: [
                      const HeroIcon(HeroIcons.hashtag,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(product.barcode,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const HeroIcon(HeroIcons.pencilSquare,
                  color: Color.fromARGB(255, 99, 162, 225)),
              onPressed: () {
                // Implement edit functionality
              },
            ),
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
  final String imageUrl;

  Product({
    required this.barcode,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });
}

class NoProductsWidget extends StatelessWidget {
  const NoProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HeroIcon(
            HeroIcons.cube,
            size: 80,
            color: const Color.fromARGB(255, 99, 162, 225).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Products Available',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 99, 162, 225)),
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
