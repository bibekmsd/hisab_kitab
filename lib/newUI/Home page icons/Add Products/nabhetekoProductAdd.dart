import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class NabhetekoProductPage extends StatefulWidget {
  @override
  _NabhetekoProductPageState createState() => _NabhetekoProductPageState();
}

class _NabhetekoProductPageState extends State<NabhetekoProductPage> {
  final List<String> _scannedValues = [];
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _wholesalePriceController =
      TextEditingController();

  bool _productExists = true;
  String _selectedProductType = 'Beauty care and Hygiene';
  bool isScanning = false;

  final List<String> _productTypes = [
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
    _barcodeController.addListener(() {
      _fetchProductDetails(_barcodeController.text);
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _wholesalePriceController.dispose();
    super.dispose();
  }

  void handleScanResult(BarcodeCapture capture) {
    setState(() {
      for (final barcode in capture.barcodes) {
        final String? code = barcode.rawValue;
        if (code != null && !_scannedValues.contains(code)) {
          _scannedValues.add(code);
        }
      }
    });
  }

  void _fetchProductDetails(String barcode) async {
    if (barcode.isEmpty) {
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('ProductsNew')
          .doc(barcode)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _productExists = true;
          _nameController.text = data['Name'];
          _priceController.text = data['Price'];
          _quantityController.text = data['Quantity'];
          _wholesalePriceController.text = data['WholesalePrice'];
          _selectedProductType = data['ProductType'];
        });
      } else {
        setState(() {
          _productExists = false;
          _nameController.clear();
          _priceController.clear();
          _quantityController.clear();
          _wholesalePriceController.clear();
        });
      }
    } catch (e) {
      debugPrint('Error fetching product details: $e');
    }
  }

  void _saveProduct() {
    try {
      final barcode = _barcodeController.text;

      // Parsing fields as numbers
      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final int quantity = int.tryParse(_quantityController.text) ?? 0;
      final double wholesalePrice =
          double.tryParse(_wholesalePriceController.text) ?? 0.0;

      final data = {
        'Barcode': barcode,
        'Name': _nameController.text,
        'Price': price, // Saving as a double
        'Quantity': quantity, // Saving as an int
        'WholesalePrice': wholesalePrice, // Saving as a double
        'ProductType': _selectedProductType,
      };

      // Saving to Firestore
      FirebaseFirestore.instance
          .collection('ProductsNew')
          .doc(barcode)
          .set(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added successfully')),
      );
    } catch (e) {
      debugPrint('Error saving product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // Barcode input field
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _barcodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter or Scan Barcode",
                    prefixIcon: Icon(Icons.qr_code_scanner),
                  ),
                  onSubmitted: (value) {
                    _fetchProductDetails(value);
                    _barcodeController.clear();
                  },
                ),
              ),
              // Toggle scanning button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isScanning = !isScanning;
                  });
                },
                child: Text(isScanning ? 'Stop Scanning' : 'Start Scanning'),
              ),
              if (isScanning)
                SizedBox(
                  width: 300,
                  height: 100,
                  child: MobileScanner(
                      fit: BoxFit.cover,
                      controller: MobileScannerController(),
                      onDetect: handleScanResult),
                ),
              // Display message if product is not found
              if (!_productExists)
                Text(
                  'Product not found!',
                  style: TextStyle(color: Colors.red),
                ),
              // Product name input field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              // Price input field
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price/Piece (MRP)'),
                keyboardType: TextInputType.number,
              ),
              // Quantity input field
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              // Dropdown for selecting product type
              DropdownButtonFormField<String>(
                value: _selectedProductType,
                decoration: InputDecoration(labelText: 'Product Type'),
                items: _productTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProductType = newValue!;
                  });
                },
              ),
              // Expansion tile for additional details
              ExpansionTile(
                title: Text('Additional Details'),
                children: [
                  // Wholesale price input field
                  TextField(
                    controller: _wholesalePriceController,
                    decoration: InputDecoration(labelText: 'Wholesale Price'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Button to save product
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
