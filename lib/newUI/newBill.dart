// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/nabhetekoProductAdd.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'grossary_list_staff.dart';

class Newbill extends StatefulWidget {
  const Newbill({super.key});

  @override
  State<Newbill> createState() => _NewbillState();
}

class _NewbillState extends State<Newbill> {
  final List<String> _scannedValues = [];
  final TextEditingController barcodeController = TextEditingController();
  bool isScanning = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }

  Future<void> _searchBarcode(String barcode) async {
    try {
      final querySnapshot = await _firestore
          .collection('ProductsNew')
          .where('Barcode', isEqualTo: barcode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final productData = querySnapshot.docs.first.data();
        setState(() {
          if (!_scannedValues.contains(productData['Barcode'])) {
            _scannedValues.add(productData['Barcode']);
          }
        });
      } else {
        // Handle case where no product is found
        print('Product not found');
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return NabhetekoProductPage();
        }));
      }
    } catch (e) {
      print('Error searching barcode: $e');
    }
  }

  void _handleDelete(int index) {
    setState(() {
      _scannedValues.removeAt(index);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 123, 139, 123),
        title: const Text("Naya Bill"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 100,
                decoration: const BoxDecoration(color: Colors.grey),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isScanning = !isScanning;
                        });
                      },
                      icon: const Icon(Icons.barcode_reader),
                      iconSize: 42,
                    ),
                    const Text(
                      "Scan Barcode",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: barcodeController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  decoration: const InputDecoration(
                    hintText: "Search Barcode",
                    prefixIcon: Icon(Icons.qr_code_scanner),
                  ),
                  onSubmitted: (value) {
                    _searchBarcode(value);
                    barcodeController
                        .clear(); // Clear the text field after submission
                  },
                ),
              ),
              Expanded(
                child: GrossaryListStaff(
                  onDelete: _handleDelete,
                  scannedValues: _scannedValues,
                ),
              ),
            ],
          ),
          if (isScanning)
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 300,
                  height: 100,
                  child: MobileScanner(
                    fit: BoxFit.cover,
                    controller: MobileScannerController(),
                    onDetect: handleScanResult,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
