import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/New%20Bill/edit_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'check_out_page.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/Add%20Products/nabhetekoProductAdd.dart';

class Newbill extends StatefulWidget {
  const Newbill({super.key});

  @override
  State<Newbill> createState() => _NewbillState();
}

class _NewbillState extends State<Newbill> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _scannedValues = [];

  final TextEditingController barcodeController = TextEditingController();
  bool isScanning = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    barcodeController.dispose();
    cameraController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _searchBarcodeOrName(String searchTerm) async {
    try {
      // Search for the product by barcode first
      final querySnapshot = await _firestore
          .collection('ProductsNew')
          .where('Barcode', isEqualTo: searchTerm)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // If no barcode match, search by product name
        final nameQuerySnapshot = await _firestore
            .collection('ProductsNew')
            .where('Name', isEqualTo: searchTerm)
            .get();

        if (nameQuerySnapshot.docs.isNotEmpty) {
          final productData = nameQuerySnapshot.docs.first.data();
          setState(() {
            _scannedValues.add({
              'name': productData['Name'],
              'barcode': productData['Barcode'],
              'price': productData['Price'],
              'quantity': 1,
              'totalPrice': productData['Price'],
              'ImageUrl': productData['ImageUrl']
            });
          });
        } else {
          // If no product found, show modal to add the new product
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            constraints: const BoxConstraints(maxHeight: 700, minHeight: 600),
            builder: (context) => NabhetekoProductPage(),
          );
        }
      } else {
        // If a barcode match is found
        final productData = querySnapshot.docs.first.data();
        setState(() {
          _scannedValues.add({
            'name': productData['Name'],
            'barcode': productData['Barcode'],
            'price': productData['Price'],
            'quantity': 1,
            'totalPrice': productData['Price'],
            'ImageUrl': productData['ImageUrl']
          });
        });
      }
    } catch (e) {
      print('Error searching barcode or name: $e');
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
        if (code != null) {
          _searchBarcodeOrName(code); // Call once
        }
      }
    });
  }

  void _incrementQuantity(int index) {
    setState(() {
      _scannedValues[index]['quantity']++;
      _scannedValues[index]['totalPrice'] =
          _scannedValues[index]['price'] * _scannedValues[index]['quantity'];
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_scannedValues[index]['quantity'] > 1) {
        _scannedValues[index]['quantity']--;
        _scannedValues[index]['totalPrice'] =
            _scannedValues[index]['price'] * _scannedValues[index]['quantity'];
      }
    });
  }

  Future<void> _updateStockAfterCheckout() async {
    for (var product in _scannedValues) {
      final String barcode = product['barcode'];
      final int purchasedQuantity = product['quantity'];

      try {
        DocumentSnapshot productSnapshot =
            await _firestore.collection('ProductsNew').doc(barcode).get();

        if (productSnapshot.exists) {
          final currentStock = productSnapshot['Quantity'];
          final newStock = currentStock - purchasedQuantity;

          await _firestore.collection('ProductsNew').doc(barcode).update({
            'Quantity':
                newStock < 0 ? 0 : newStock, // Ensure stock doesn't go below 0
          });
        }
      } catch (e) {
        print('Error updating stock for $barcode: $e');
      }
    }
  }

  // This function will handle the update of product details
  void _updateProductDetails(int index, Map<String, dynamic> updatedProduct) {
    setState(() {
      _scannedValues[index] = {
        'name': updatedProduct['ProductName'],
        'barcode': _scannedValues[index]
            ['barcode'], // Barcode remains unchanged
        'price': updatedProduct['Price'], // Updated price
        'quantity': _scannedValues[index]['quantity'], // Keep the same quantity
        'totalPrice':
            updatedProduct['Price'] * _scannedValues[index]['quantity'],
        'ImageUrl': updatedProduct['ImageUrl']
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalQuantity = _scannedValues.fold<int>(
        0, (sum, item) => sum + (item['quantity'] as int));
    final totalPrice =
        _scannedValues.fold<double>(0, (sum, item) => sum + item['totalPrice']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 123, 139, 123),
        title: const Text("Naya Bill"),
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(color: Colors.grey),
            child: isScanning
                ? MobileScanner(
                    controller: cameraController,
                    onDetect: handleScanResult,
                  )
                : Row(
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
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: barcodeController,
              decoration: const InputDecoration(
                hintText: "Search Barcode or Name",
                prefixIcon: Icon(Icons.qr_code_scanner),
              ),
              onSubmitted: (value) {
                _searchBarcodeOrName(value);
                barcodeController.clear();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _scannedValues.length,
              itemBuilder: (context, index) {
                final product = _scannedValues[index];
                return Card(
                  child: ListTile(
                    title: Row(
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: product['ImageUrl'] != null &&
                                      product['ImageUrl'].isNotEmpty
                                  ? NetworkImage(product['ImageUrl'])
                                  : const AssetImage('assets/default_image.png')
                                      as ImageProvider,
                              child: product['ImageUrl'] == null ||
                                      product['ImageUrl'].isEmpty
                                  ? const Icon(
                                      Icons.image,
                                      size: 30,
                                    )
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final updatedProduct = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProductPage(
                                      initialProductName: product['name'],
                                      initialMRP: product['price'],
                                      initialPrice: product['price'],
                                      initialWholesalePrice: product['price'],
                                      initialQuantity: product['quantity'],
                                      initialDiscount: 0.0,
                                      initialImageUrl: product['ImageUrl'],
                                    ),
                                  ),
                                );

                                // Check if product was updated
                                if (updatedProduct != null) {
                                  _updateProductDetails(index, updatedProduct);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${product['name']}'),
                              Text('Barcode: ${product['barcode']}'),
                              Text('Price: ${product['price']}'),
                              Text('Quantity: ${product['quantity']}'),
                              Text('Total: ${product['totalPrice']}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _decrementQuantity(index),
                        ),
                        Text('${product['quantity']}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _incrementQuantity(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _handleDelete(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total Quantity: $totalQuantity',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total Price: $totalPrice',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null // Disable the button if it's loading
                      : () async {
                          setState(() {
                            _isLoading = true; // Disable the button
                          });

                          try {
                            await _updateStockAfterCheckout();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckOutPage(
                                  productDetails: _scannedValues,
                                  totalQuantity: totalQuantity.toString(),
                                  totalPrice: totalPrice.toStringAsFixed(2),
                                  customerPhone: '',
                                ),
                              ),
                            );
                          } finally {
                            setState(() {
                              _isLoading =
                                  false; // Re-enable the button once done
                            });
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: BorderSide.strokeAlignCenter,
                          color: Colors.white) // Show a spinner when loading
                      : const Text('Proceed to Checkout'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
