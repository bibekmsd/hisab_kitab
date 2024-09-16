import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package

class ReturnItem extends StatefulWidget {
  const ReturnItem({super.key});

  @override
  State<ReturnItem> createState() => _ReturnItemState();
}

class _ReturnItemState extends State<ReturnItem> {
  final TextEditingController _billNumberController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _products = [];
  String? _errorMessage;
  String _purchaseDate = 'N/A';

  @override
  void dispose() {
    _billNumberController.dispose();
    super.dispose();
  }

  Future<void> _searchBill() async {
    String billNumber = _billNumberController.text.trim();

    if (billNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a bill number.';
        _products = [];
        _purchaseDate = 'N/A';
      });
      return;
    }

    try {
      DocumentSnapshot billSnapshot =
          await _db.collection('bills').doc(billNumber).get();

      if (billSnapshot.exists) {
        final data = billSnapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> fetchedProducts =
            List<Map<String, dynamic>>.from(data['Products'] ?? []);

        // Remove duplicates based on barcode
        Map<String, Map<String, dynamic>> uniqueProductsMap = {};
        for (var product in fetchedProducts) {
          String barcode = product['barcode'] ?? '';
          if (uniqueProductsMap.containsKey(barcode)) {
            // Update quantity for duplicates
            int existingQuantity = uniqueProductsMap[barcode]?['quantity'] ?? 0;
            int newQuantity = product['quantity'] ?? 0;
            uniqueProductsMap[barcode]!['quantity'] =
                existingQuantity + newQuantity;
          } else {
            uniqueProductsMap[barcode] = product;
          }
        }

        setState(() {
          _products = uniqueProductsMap.values.toList();

          // Handle purchase date
          final purchaseDate = data['PurchaseDate'];
          if (purchaseDate != null) {
            if (purchaseDate is Timestamp) {
              _purchaseDate = DateFormat('yyyy-MM-dd')
                  .format((purchaseDate as Timestamp).toDate());
            } else if (purchaseDate is DateTime) {
              _purchaseDate =
                  DateFormat('yyyy-MM-dd').format((purchaseDate as DateTime));
            } else {
              debugPrint(
                  'Unexpected data type for PurchaseDate: ${purchaseDate.runtimeType}');
              _purchaseDate = 'Invalid Date Format';
            }
          } else {
            _purchaseDate = 'N/A';
          }

          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Bill number does not exist.';
          _products = [];
          _purchaseDate = 'N/A';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
        _products = [];
        _purchaseDate = 'N/A';
      });
    }
  }

  Future<void> _updateProductQuantity(
      String barcode, int returnQuantity) async {
    try {
      // Reference to the product document
      DocumentReference productRef = _db.collection('ProductsNew').doc(barcode);

      // Fetch the current product data
      DocumentSnapshot productSnapshot = await productRef.get();

      if (productSnapshot.exists) {
        // Get the current quantity
        final productData = productSnapshot.data() as Map<String, dynamic>;
        int currentQuantity = productData['Quantity'] ?? 0;

        // Calculate the new quantity
        int newQuantity = currentQuantity + returnQuantity;

        // Update the product quantity in the database
        await productRef.update({'Quantity': newQuantity});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product quantity updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product not found in ProductsNew.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product quantity: $e')),
      );
    }
  }

  Future<void> _returnProduct(
      Map<String, dynamic> product, int newQuantity) async {
    String billNumber = _billNumberController.text.trim();
    int returnQuantity = product['quantity'] ?? 0;

    // Reference to the bill document
    DocumentReference billRef = _db.collection('bills').doc(billNumber);

    try {
      // Fetch the current bill data
      DocumentSnapshot billSnapshot = await billRef.get();
      if (billSnapshot.exists) {
        final data = billSnapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> products =
            List<Map<String, dynamic>>.from(data['Products'] ?? []);

        // Find the index of the product to update
        int productIndex =
            products.indexWhere((p) => p['barcode'] == product['barcode']);

        if (productIndex != -1) {
          // Product exists, update its quantity and returnQuantity
          products[productIndex]['quantity'] = newQuantity;

          // Only update returnQuantity if the product was returned
          if (returnQuantity > 0) {
            products[productIndex]['returnQuantity'] = returnQuantity;
          } else {
            products[productIndex].remove('returnQuantity');
          }

          // Update the totalPrice in the product map
          products[productIndex]['totalPrice'] =
              (products[productIndex]['price'] as num?)?.toDouble() ??
                  0 * newQuantity;

          // Update the bill document
          await billRef.update({
            'Products': products,
          });

          // Update the product quantity in ProductsNew
          await _updateProductQuantity(product['barcode'], returnQuantity);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Product returned and quantity updated successfully!')),
          );

          _searchBill(); // Refresh the list after returning a product
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product not found in the bill.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bill number does not exist.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product quantity: $e')),
      );
    }
  }

  void _onProductTap(Map<String, dynamic> product) {
    int availableQuantity = product['quantity'] ?? 0;
    int selectedQuantity = 0; // Initialize return quantity to 0

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(product['name'] ?? 'Product Details'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Barcode: ${product['barcode'] ?? 'N/A'}'),
                  Text('Price: ${product['price'] ?? 0}'),
                  Text('Available Quantity: $availableQuantity'),
                  Text('Total Price: ${product['totalPrice'] ?? 0}'),
                  const SizedBox(height: 16),
                  const Text('Select return quantity:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: selectedQuantity > 0
                            ? () {
                                setState(() {
                                  selectedQuantity--;
                                });
                              }
                            : null,
                      ),
                      Text('$selectedQuantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: selectedQuantity < availableQuantity
                            ? () {
                                setState(() {
                                  selectedQuantity++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Return'),
                  onPressed: selectedQuantity > 0
                      ? () {
                          Navigator.of(context).pop();
                          _returnProduct(product, selectedQuantity);
                        }
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the total items count, ensuring that we handle potential 'num' types.
    int totalItemsCount = _products.fold<int>(
      0,
      (sum, product) {
        // Ensure 'quantity' is treated as an int
        int quantity = (product['quantity'] as num?)?.toInt() ?? 0;
        return sum + quantity;
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Item'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _billNumberController,
              decoration: const InputDecoration(
                labelText: 'Enter Bill Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _searchBill,
                child: const Text('Search'),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (_products.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Purchase Date:'),
              Text(_purchaseDate),
              const SizedBox(height: 16),
              const Text('Products:'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    int availableQuantity =
                        (product['quantity'] as num?)?.toInt() ?? 0;
                    int returnQuantity =
                        (product['returnQuantity'] as num?)?.toInt() ?? 0;

                    return Card(
                      child: ListTile(
                        title: Text(product['name'] ?? 'No Name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Barcode: ${product['barcode'] ?? 'N/A'}'),
                            Text('Price: ${product['price'] ?? 0}'),
                            Text('Total Price: ${product['totalPrice'] ?? 0}'),
                            Text('Available Quantity: $availableQuantity'),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Return Quantity:'),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: returnQuantity > 0
                                          ? () {
                                              setState(() {
                                                returnQuantity--;
                                                product['returnQuantity'] =
                                                    returnQuantity;
                                              });
                                            }
                                          : null,
                                    ),
                                    Text('$returnQuantity'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed:
                                          returnQuantity < availableQuantity
                                              ? () {
                                                  setState(() {
                                                    returnQuantity++;
                                                    product['returnQuantity'] =
                                                        returnQuantity;
                                                  });
                                                }
                                              : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            if (returnQuantity > 0) {
                              _returnProduct(product, returnQuantity);
                            }
                          },
                          child: const Text('Return'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
