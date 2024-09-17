import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedCategory = 'All'; // Default selected category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Products from our catalogue'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // handle back press
          },
        ),
      ),
      body: Row(
        children: [
          // Category List on the left
          Expanded(
            flex: 1,
            child: CategoryList(
              onCategorySelected: (category) {
                setState(() {
                  selectedCategory = category;
                });
              },
            ),
          ),
          // Product List on the right
          Expanded(
            flex: 3,
            child: ProductList(
              firestore: _firestore,
              category: selectedCategory,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              // Handle Next button press
            },
            child: Text("Next (0)"), // Dynamically update count
          ),
        ),
      ),
    );
  }
}

class CategoryList extends StatelessWidget {
  final Function(String) onCategorySelected;

  CategoryList({required this.onCategorySelected});

  final List<String> categories = [
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
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return CategoryItem(
          name: categories[index],
          onTap: () => onCategorySelected(categories[index]),
        );
      },
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const CategoryItem({
    Key? key,
    required this.name,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          children: [
            Icon(Icons.category,
                size:
                    40), // Generic icon, replace with specific icons if available
            SizedBox(height: 4),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String category;

  ProductList({required this.firestore, required this.category});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: category == 'All'
          ? firestore.collection('ProductsNew').snapshots()
          : firestore
              .collection('ProductsNew')
              .where('ProductType', isEqualTo: category)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final productName = product['Name'] as String? ?? 'Unknown Product';
            final productPrice = (product['Price'] as num?)?.toDouble() ?? 0.0;
            final imageUrl = product['ImageUrl'] as String?;

            return ProductItem(
              name: productName,
              price: productPrice,
              imageUrl: imageUrl,
            );
          },
        );
      },
    );
  }
}

class ProductItem extends StatelessWidget {
  final String name;
  final double price;
  final String? imageUrl;

  const ProductItem({
    Key? key,
    required this.name,
    required this.price,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: imageUrl ?? 'https://example.com/default_image.png',
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) =>
              Image.asset('assets/default_image.png'),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(name),
        subtitle: Text('₹ ${price.toStringAsFixed(2)}'),
        trailing: Checkbox(
          value: false,
          onChanged: (bool? value) {
            // Handle checkbox toggle
          },
        ),
      ),
    );
  }
}
