// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hisab_kitab/reuseable_widgets/getItemsFromDatabase.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Newbill extends StatefulWidget {
  const Newbill({super.key});

  @override
  State<Newbill> createState() => _NewbillState();
}

class _NewbillState extends State<Newbill> {
  TextEditingController barcodeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Naya Bill"),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.grey),
            height: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    //   GetItemsFromDatabaseTable(
                    //       scannedValues: scannedValues, onDelete: handleDelete);
                    // },
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
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
            constraints: const BoxConstraints(minHeight: 50, minWidth: 1200),
            child: TextField(
              controller: barcodeController,
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                  hintText: ("Search Barcode"),
                  prefixIcon: const Icon(Icons.qr_code_scanner)),
            ),
          ),
        ],
      ),
    );
  }
}
