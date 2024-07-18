import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class NabhetekoProductPage extends StatefulWidget {
  @override
  _NabhetekoProductPageState createState() => _NabhetekoProductPageState();
}

class _NabhetekoProductPageState extends State<NabhetekoProductPage> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _retailPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _wholesalePriceController =
      TextEditingController();

  bool _productExists = true;
  String _selectedProductType = 'Beauty care and Hygiene';

  final List<String> _productTypes = [
    'Beauty care and Hygiene',
    'Cleaning and household',
    'Eggs, meat and fish',
    'Food grains, oil and masala',
    'Fruits and vegetables',
    'Health and wellness',
    'Snacks'
  ];

  void _saveProduct() {
    try {
      final barcode = _barcodeController.text;
      final data = {
        'Barcode': barcode,
        'Name': _nameController.text,
        'Price': int.parse(_priceController.text),
        'Quantity': int.parse(_quantityController.text),
        'WholesalePrice': int.parse(_wholesalePriceController.text),
        'ProductType': _selectedProductType,
      };

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
    _retailPriceController.dispose();
    _quantityController.dispose();
    _wholesalePriceController.dispose();
    super.dispose();
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
        debugPrint("Barcode Exists");
        final data = doc.data()!;
        setState(() {
          _productExists = true;
          _barcodeController.text = data['Barcode'];
          _nameController.text = data['Name'];
          _priceController.text = data['Price'].toString();
          _quantityController.text = data['Quantity'].toString();
          _wholesalePriceController.text = data['WholesalePrice'].toString();
          _selectedProductType = data['ProductType'];
        });
      } else {
        setState(() {
          _productExists = false;
          _nameController.clear();
          _priceController.clear();
          _retailPriceController.clear();
          _quantityController.clear();
          _wholesalePriceController.clear();
        });
        _barcodeController
            .clear(); // Clear barcode field when product doesn't exist
      }
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      // Handle error here (e.g., show error message to user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Add'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _barcodeController,
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: const InputDecoration(
                    hintText: "Search Barcode",
                    prefixIcon: Icon(Icons.qr_code_scanner),
                  ),
                  onSubmitted: (value) {
                    _fetchProductDetails(value);
                    _barcodeController
                        .clear(); // Clear the text field after submission
                  },
                ),
              ),
              if (!_productExists)
                Text(
                  'Product not found!',
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price/Piece (MRP)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
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
              ExpansionTile(
                title: Text('Additional Details'),
                children: [
                  TextField(
                    controller: _wholesalePriceController,
                    decoration: InputDecoration(labelText: 'Wholesale Price'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
