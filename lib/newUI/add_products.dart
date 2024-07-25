// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/nabhetekoProductAdd.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'grossary_list_staff.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({super.key});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final List<String> _scannedValues = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 123, 139, 123),
        title: const Text("Add Products"),
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
                    // onDetect: handleScanResult,
                  ),
                ),
              ),
            ),
        ],
      ),

      //  NabhetekoProductPage(),
    );
  }
}
