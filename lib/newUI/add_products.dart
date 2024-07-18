// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({Key? key}) : super(key: key);

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sellPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController costPriceController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isScanning = false;
  String scannedBarcode = '';

  @override
  void dispose() {
    barcodeController.dispose();
    nameController.dispose();
    sellPriceController.dispose();
    quantityController.dispose();
    costPriceController.dispose();
    super.dispose();
  }

  Future<void> _searchBarcode(String barcode) async {
    try {
      final querySnapshot = await _firestore
          .collection('Products')
          .where('Barcode', isEqualTo: barcode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final productData = querySnapshot.docs.first.data();
        setState(() {
          scannedBarcode = productData['Barcode'];
          nameController.text = productData['Name'] ?? '';
          sellPriceController.text = productData['SellPrice']?.toString() ?? '';
          quantityController.text = productData['Quantity']?.toString() ?? '';
          costPriceController.text = productData['CostPrice']?.toString() ?? '';
        });
      } else {
        // Ask user for details if product doesn't exist
        scannedBarcode = barcode;
        _showProductDetailsDialog();
      }
    } catch (e) {
      print('Error searching barcode: $e');
    }
  }

  void _showProductDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Product Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Product Name"),
              ),
              TextField(
                controller: sellPriceController,
                decoration: InputDecoration(labelText: "Sell Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: costPriceController,
                decoration: InputDecoration(labelText: "Cost Price"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _addProduct();
                Navigator.of(context).pop();
              },
              child: Text("Add Product"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addProduct() async {
    try {
      await _firestore.collection('Products').add({
        'Barcode': scannedBarcode,
        'Name': nameController.text,
        'SellPrice': double.tryParse(sellPriceController.text) ?? 0.0,
        'Quantity': int.tryParse(quantityController.text) ?? 0,
        'CostPrice': double.tryParse(costPriceController.text) ?? 0.0,
      });
      print('Product added successfully');
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  void handleScanResult(BarcodeCapture capture) {
    setState(() {
      for (final barcode in capture.barcodes) {
        final String? code = barcode.rawValue;
        if (code != null) {
          _searchBarcode(code);
          scannedBarcode = code; // Store scanned barcode
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Products"),
        backgroundColor: Color.fromARGB(255, 123, 139, 123),
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(color: Colors.grey),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      isScanning = !isScanning;
                    });
                  },
                  icon: Icon(Icons.barcode_reader),
                  iconSize: 42,
                ),
                Text(
                  "Scan Barcode",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
          if (isScanning)
            Expanded(
              child: MobileScanner(
                fit: BoxFit.cover,
                controller: MobileScannerController(),
                onDetect: handleScanResult,
              ),
            ),
        ],
      ),
    );
  }
}
