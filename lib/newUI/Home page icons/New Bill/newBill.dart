import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
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
  MobileScannerController? cameraController;

  @override
  void dispose() {
    barcodeController.dispose();
    cameraController?.dispose();
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

        if (!_isProductAlreadyScanned(productData['Barcode'])) {
          final currentStock = productData['Quantity'] ?? 0;
          setState(() {
            _scannedValues.add({
              'name': productData['Name'],
              'barcode': productData['Barcode'],
              'price': productData['Price'],
              'quantity': 1,
              'totalPrice': productData['Price'],
              'ImageUrl': productData['ImageUrl'],
              'availableStock': currentStock,
            });
          });
        }
      } else {
        // If no product found, dispose of the camera controller and show modal
        cameraController?.dispose();
        cameraController = null;
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

      if (!_isProductAlreadyScanned(productData['Barcode'])) {
        final currentStock = productData['Quantity'] ?? 0;
        setState(() {
          _scannedValues.add({
            'name': productData['Name'],
            'barcode': productData['Barcode'],
            'price': productData['Price'],
            'quantity': 1,
            'totalPrice': productData['Price'],
            'ImageUrl': productData['ImageUrl'],
            'availableStock': currentStock,
          });
        });
      }
    }
  } catch (e) {
    print('Error searching barcode or name: $e');
    // Consider showing an error message to the user here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error searching for product: ${e.toString()}'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// Function to check if product is already scanned based on barcode
  bool _isProductAlreadyScanned(String barcode) {
    return _scannedValues.any((product) => product['barcode'] == barcode);
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

  void _incrementQuantity(int index) async {
    final currentQuantity = _scannedValues[index]['quantity'];
    final availableStock = _scannedValues[index]['availableStock'];

    if (currentQuantity < availableStock) {
      setState(() {
        _scannedValues[index]['quantity']++;
        _scannedValues[index]['totalPrice'] =
            _scannedValues[index]['price'] * _scannedValues[index]['quantity'];
      });
    } else {
      // Show an alert or snackbar to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add more. Available stock: $availableStock'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
        title: const Text("Naya Bill"),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.qrCode),
            onPressed: () {
              setState(() {
                isScanning = !isScanning;
                if (isScanning) {
                  cameraController = MobileScannerController();
                } else {
                  cameraController?.dispose();
                  cameraController = null;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isScanning)
            Container(
              height: MediaQuery.of(context).size.height * 0.12,
              width: MediaQuery.of(context).size.width,
              child: MobileScanner(
                controller: cameraController!,
                onDetect: handleScanResult,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: barcodeController,
              decoration: InputDecoration(
                hintText: "Search Barcode or Name",
                prefixIcon: const HeroIcon(HeroIcons.magnifyingGlass),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
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
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: SizedBox(
                    // height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width *
                        0.9, // Adjusts card width
                    child: Card(
                      elevation: 4,
                      margin:
                          EdgeInsets.zero, // Remove default margin from Card
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: product['ImageUrl'] != null &&
                                  product['ImageUrl'].isNotEmpty
                              ? NetworkImage(product['ImageUrl'])
                              : const AssetImage('assets/default_image.png')
                                  as ImageProvider,
                          child: product['ImageUrl'] == null ||
                                  product['ImageUrl'].isEmpty
                              ? const HeroIcon(HeroIcons.photo)
                              : null,
                        ),
                        title: Text(product['name'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Barcode: ${product['barcode']}'),
                            Text('Price: ${product['price']}'),
                            Text('Quantity: ${product['quantity']}'),
                            Text('Total: ${product['totalPrice']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const HeroIcon(HeroIcons.minusCircle),
                              onPressed: () => _decrementQuantity(index),
                            ),
                            Text('${product['quantity']}'),
                            IconButton(
                              icon: const HeroIcon(HeroIcons.plusCircle),
                              onPressed: () => _incrementQuantity(index),
                            ),
                            IconButton(
                              icon: const HeroIcon(HeroIcons.trash),
                              onPressed: () => _handleDelete(index),
                            ),
                          ],
                        ),
                        onTap: () async {
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
                          if (updatedProduct != null) {
                            _updateProductDetails(index, updatedProduct);
                          }
                        },
                      ),
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
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
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
                              _isLoading = false;
                            });
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Proceed to Checkout'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
