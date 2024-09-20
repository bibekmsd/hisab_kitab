import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/Add%20Products/nabhetekoProductAdd.dart';
import 'package:heroicons/heroicons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';

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

  Future<void> _importFromExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null) {
        _showErrorMessage('No file selected');
        return;
      }

      print('File picked: ${result.files.first.name}');
      print('File path: ${result.files.first.path}');

      File file = File(result.files.first.path!);
      if (!await file.exists()) {
        _showErrorMessage('File does not exist at the specified path');
        return;
      }

      var bytes = await file.readAsBytes();
      print('File size: ${bytes.length} bytes');

      if (bytes.isEmpty) {
        _showErrorMessage('File is empty');
        return;
      }

      var excelFile = excel.Excel.decodeBytes(bytes);

      if (excelFile.tables.isEmpty) {
        _showErrorMessage('Excel file is empty or could not be parsed');
        return;
      }

      var table = excelFile.tables.values.first;
      var rows = table.rows;

      if (rows.isEmpty) {
        _showErrorMessage('Excel file does not contain any rows');
        return;
      }

      // Validate headers
      var expectedHeaders = [
        'Name',
        'Quantity',
        'Price',
        'ImageUrl',
        'ProductType',
        'Barcode'
      ];
      var headers =
          rows[0].map((cell) => cell?.value.toString().trim()).toList();
      if (!_listsEqual(headers, expectedHeaders)) {
        _showErrorMessage(
            'Excel file headers do not match the expected format. Found: ${headers.join(", ")}');
        return;
      }

      int successCount = 0;
      int failureCount = 0;
      List<String> errorMessages = [];

      for (var row in rows.skip(1)) {
        try {
          if (row.length < 6) {
            throw Exception('Row does not have enough columns');
          }

          var barcode = row[5]?.value.toString().trim();
          if (barcode == null || barcode.isEmpty) {
            throw Exception('Barcode is missing');
          }

          await FirebaseFirestore.instance
              .collection("ProductsNew")
              .doc(barcode)
              .set({
            'Name': row[0]?.value.toString().trim() ?? '',
            'Quantity':
                int.tryParse(row[1]?.value.toString().trim() ?? '0') ?? 0,
            'Price':
                double.tryParse(row[2]?.value.toString().trim() ?? '0.0') ??
                    0.0,
            'ImageUrl': row[3]?.value.toString().trim() ?? '',
            'ProductType': row[4]?.value.toString().trim() ?? 'Other',
          });

          successCount++;
        } catch (e) {
          failureCount++;
          errorMessages.add('Error on row ${rows.indexOf(row) + 1}: $e');
        }
      }

      _showResultMessage(successCount, failureCount, errorMessages);
    } catch (e) {
      _showErrorMessage('Error importing products: $e');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showResultMessage(
      int successCount, int failureCount, List<String> errorMessages) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Import Result'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Successfully imported: $successCount'),
                Text('Failed to import: $failureCount'),
                if (errorMessages.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Text('Errors:'),
                  ...errorMessages.map((error) => Text('• $error')),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _listsEqual(List? a, List? b) {
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _exportToExcel() async {
    try {
      // Fetch all product data from Firestore
      QuerySnapshot productSnapshot =
          await FirebaseFirestore.instance.collection("ProductsNew").get();

      if (productSnapshot.docs.isEmpty) {
        _showErrorMessage('No products to export');
        return;
      }

      // Create a new Excel workbook
      var workbook = excel.Excel.createExcel();

      // Add a sheet
      String sheetName = 'Products';
      workbook[sheetName].insertRowIterables(
          ['Name', 'Quantity', 'Price', 'ImageUrl', 'ProductType', 'Barcode'],
          0); // Adding header

      // Iterate through the product data and append to the Excel sheet
      for (var doc in productSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        workbook[sheetName].appendRow([
          data['Name'] ?? '',
          data['Quantity']?.toString() ?? '',
          data['Price']?.toString() ?? '',
          data['ImageUrl'] ?? '',
          data['ProductType'] ?? '',
          doc.id, // Barcode is the document ID
        ]);
      }

      // Encode the Excel file
      var fileBytes = workbook.encode();

      if (fileBytes == null) {
        _showErrorMessage('Failed to encode Excel file');
        return;
      }

      // Ask user for file name
      String? fileName = await _promptForFileName();
      if (fileName == null || fileName.isEmpty) {
        _showErrorMessage('No file name provided');
        return;
      }

      // Ensure the file has .xlsx extension
      if (!fileName.toLowerCase().endsWith('.xlsx')) {
        fileName += '.xlsx';
      }

      // Ask user for save location
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        _showErrorMessage('No directory selected');
        return;
      }

      // Construct the full path
      String fullPath = '$selectedDirectory/$fileName';

      // Check if file already exists
      if (await File(fullPath).exists()) {
        bool? overwrite = await _promptOverwrite();
        if (overwrite == null || !overwrite) {
          _showErrorMessage('Export cancelled');
          return;
        }
      }

      // Save the file
      File outputFile = File(fullPath);
      await outputFile.writeAsBytes(fileBytes);

      _showSuccessMessage('Products exported successfully to $fullPath');
    } catch (e) {
      _showErrorMessage('Error exporting products: $e');
    }
  }

  Future<String?> _promptForFileName() async {
    String? fileName;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter File Name'),
          content: TextField(
            onChanged: (value) {
              fileName = value;
            },
            decoration: InputDecoration(hintText: "products_export.xlsx"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
    return fileName;
  }

  Future<bool?> _promptOverwrite() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('File already exists'),
          content: Text('Do you want to overwrite the existing file?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _askLocationAndSave(String fileName, String fileContent) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      // Construct the full path and save the file
      String fullPath = '$selectedDirectory/$fileName';
      File file = File(fullPath);

      await file.writeAsString(fileContent);
      print('File saved to $fullPath');
    } else {
      print('User canceled the directory selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Stock",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
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
          IconButton(
            icon: const HeroIcon(HeroIcons.arrowUpTray),
            onPressed: _importFromExcel,
          ),
          IconButton(
            icon:
                const HeroIcon(HeroIcons.arrowDownTray), // Export to Excel icon
            onPressed: _exportToExcel, // Call the export function
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
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
            heroTag: 'addProduct',
          ),
          const SizedBox(height: 16), // Space between buttons
          FloatingActionButton(
            onPressed: _exportToExcel, // Call the export function
            backgroundColor: const Color.fromARGB(255, 99, 162, 225),
            child: const HeroIcon(HeroIcons.arrowDownTray,
                color: Colors.white), // Export icon
            heroTag: 'exportToExcel',
          ),
        ],
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
