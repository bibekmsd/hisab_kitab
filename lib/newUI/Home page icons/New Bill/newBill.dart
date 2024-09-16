import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/Add%20Products/nabhetekoProductAdd.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/New%20Bill/edit.dart'; // Import the edit page

class Newbill extends StatefulWidget {
  const Newbill({super.key});

  @override
  State<Newbill> createState() => _NewbillState();
}

class _NewbillState extends State<Newbill> {
  final List<Map<String, dynamic>> _scannedProducts = [];
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
          if (!_scannedProducts
              .any((product) => product['Barcode'] == productData['Barcode'])) {
            _scannedProducts.add(productData);
          }
        });
      } else {
        print('Product not found');
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          constraints: const BoxConstraints(maxHeight: 700, minHeight: 600),
          builder: (context) => NabhetekoProductPage(),
        );
      }
    } catch (e) {
      print('Error searching barcode: $e');
    }
  }

  void _handleDelete(int index) {
    setState(() {
      _scannedProducts.removeAt(index);
    });
  }

  void handleScanResult(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        _searchBarcode(code);
      }
    }
  }

  void _editProduct(int index) {
    final product = _scannedProducts[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(
          initialProductName: product['ProductName'] ?? '',
          initialMRP: (product['MRP'] ?? 0.0).toDouble(),
          initialPrice: (product['Price'] ?? 0.0).toDouble(),
          initialWholesalePrice: (product['WholesalePrice'] ?? 0.0).toDouble(),
          initialQuantity: (product['Quantity'] ?? 0.0).toDouble(),
          initialDiscount: (product['Discount'] ?? 0.0).toDouble(),
        ),
      ),
    ).then((editedProduct) {
      if (editedProduct != null) {
        setState(() {
          _scannedProducts[index] = editedProduct;
        });
      }
    });
  }

  void _increaseQuantity(int index) {
    setState(() {
      _scannedProducts[index]['Quantity'] += 1;
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (_scannedProducts[index]['Quantity'] > 0) {
        _scannedProducts[index]['Quantity'] -= 1;
      }
    });
  }

  int getTotalQuantity() {
    return _scannedProducts.fold(0, (sum, product) {
      final int quantity = product['Quantity'] is int
          ? product['Quantity'] as int
          : (product['Quantity'] as double).toInt();
      return sum + quantity;
    });
  }

  double getTotalPrice() {
    return _scannedProducts.fold(0.0, (sum, product) {
      final double price = product['Price'] is int
          ? (product['Price'] as int).toDouble()
          : product['Price'];
      final double discount = product['Discount'] is int
          ? (product['Discount'] as int).toDouble()
          : product['Discount'] ?? 0.0;
      final int quantity = product['Quantity'] is int
          ? product['Quantity']
          : (product['Quantity'] as double).toInt();

      // Calculate discounted price
      final double discountedPrice = price * (1 - discount / 100);
      return sum + (discountedPrice * quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 123, 139, 123),
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
                    ),
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
                    barcodeController.clear();
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _scannedProducts.length,
                  itemBuilder: (context, index) {
                    final product = _scannedProducts[index];
                    final double price = product['Price'] ?? 0.0;
                    final double discount = product['Discount'] ?? 0.0;
                    final double discountedPrice =
                        price * (1 - discount / 100); // Discounted price

                    return ListTile(
                      leading: product['ProductImage'] != null
                          ? Image.network(product['ProductImage'], width: 50)
                          : const Icon(Icons.shopping_bag),
                      title: Text(product['ProductName'] ?? 'Unknown Product'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Original Price: Rs. ${price.toStringAsFixed(2)}'),
                          Text('Discount: ${discount.toStringAsFixed(2)}%'),
                          Text(
                              'Discounted Price: Rs. ${discountedPrice.toStringAsFixed(2)}'),
                          // Place quantity incrementor below the product details
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _decreaseQuantity(index),
                              ),
                              Text(
                                product['Quantity']?.toString() ?? '0',
                                style: const TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _increaseQuantity(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editProduct(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _handleDelete(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Total Quantity: ${getTotalQuantity()}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Total Price after Discount: Rs. ${getTotalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Handle checkout logic here
                      },
                      child: const Text('Checkout'),
                    ),
                  ],
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
