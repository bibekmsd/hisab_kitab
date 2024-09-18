import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReturnItem extends StatefulWidget {
  const ReturnItem({Key? key}) : super(key: key);

  @override
  State<ReturnItem> createState() => _ReturnItemState();
}

class _ReturnItemState extends State<ReturnItem> {
  final TextEditingController _billNumberController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _products = [];
  String? _errorMessage;
  DateTime? _purchaseDate;

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
        _purchaseDate = null;
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

        // Initialize returnQuantity to 0 for each product
        uniqueProductsMap.values.forEach((product) {
          product['returnQuantity'] = 0;
          product['totalPrice'] = (product['price'] as num? ?? 0) *
              (product['quantity'] as num? ?? 0);
        });

        setState(() {
          _products = uniqueProductsMap.values.toList();

          // Handle purchase date
          final purchaseDate = data['PurchaseDate'];
          if (purchaseDate != null) {
            if (purchaseDate is Timestamp) {
              _purchaseDate = (purchaseDate as Timestamp).toDate();
            } else if (purchaseDate is DateTime) {
              _purchaseDate = purchaseDate;
            } else {
              debugPrint(
                  'Unexpected data type for PurchaseDate: ${purchaseDate.runtimeType}');
              _purchaseDate = null;
            }
          } else {
            _purchaseDate = null;
          }

          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Bill number does not exist.';
          _products = [];
          _purchaseDate = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
        _products = [];
        _purchaseDate = null;
      });
    }
  }

  Future<void> _updateProductQuantity(
      String barcode, int returnQuantity) async {
    try {
      DocumentReference productRef = _db.collection('ProductsNew').doc(barcode);
      DocumentSnapshot productSnapshot = await productRef.get();

      if (productSnapshot.exists) {
        final productData = productSnapshot.data() as Map<String, dynamic>;
        int currentQuantity = productData['Quantity'] ?? 0;
        int newQuantity = currentQuantity + returnQuantity;
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

  Future<void> _returnProduct(Map<String, dynamic> product) async {
    String billNumber = _billNumberController.text.trim();
    int returnQuantity = product['returnQuantity'] ?? 0;

    if (returnQuantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a quantity to return.')),
      );
      return;
    }

    DocumentReference billRef = _db.collection('bills').doc(billNumber);

    try {
      DocumentSnapshot billSnapshot = await billRef.get();
      if (billSnapshot.exists) {
        final data = billSnapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> products =
            List<Map<String, dynamic>>.from(data['Products'] ?? []);

        int productIndex =
            products.indexWhere((p) => p['barcode'] == product['barcode']);

        if (productIndex != -1) {
          int newQuantity = products[productIndex]['quantity'] - returnQuantity;
          products[productIndex]['quantity'] = newQuantity;
          products[productIndex]['totalPrice'] =
              (products[productIndex]['price'] as num? ?? 0) * newQuantity;

          await billRef.update({
            'Products': products,
          });

          await _updateProductQuantity(product['barcode'], returnQuantity);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Product returned and quantity updated successfully!')),
          );

          _searchBill();
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

  bool _canReturn(DateTime? purchaseDate) {
    if (purchaseDate == null) return false;
    final difference = DateTime.now().difference(purchaseDate);
    return difference.inDays <= 7;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Item'),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _billNumberController,
                    decoration: InputDecoration(
                      labelText: 'Enter Bill Number',
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: Colors.blue),
                        onPressed: _searchBill,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_purchaseDate != null) ...[
                Card(
                  color: Colors.blue.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purchase Date: ${DateFormat('yyyy-MM-dd').format(_purchaseDate!)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (!_canReturn(_purchaseDate))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Products cannot be returned after 7 days of purchase.',
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_products.isNotEmpty) ...[
                Text(
                  'Products',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      int purchasedQuantity = product['quantity'] ?? 0;
                      int returnQuantity = product['returnQuantity'] ?? 0;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? 'No Name',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800),
                              ),
                              const SizedBox(height: 8),
                              Text('Barcode: ${product['barcode'] ?? 'N/A'}'),
                              Text(
                                  'Price: \$${(product['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
                              Text(
                                  'Total Price: \$${(product['totalPrice'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
                              Text('Purchased Quantity: $purchasedQuantity'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Return Quantity:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove,
                                              color: Colors.blue),
                                          onPressed: returnQuantity > 0
                                              ? () {
                                                  setState(() {
                                                    product['returnQuantity'] =
                                                        returnQuantity - 1;
                                                  });
                                                }
                                              : null,
                                        ),
                                        Text('$returnQuantity',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: const Icon(Icons.add,
                                              color: Colors.blue),
                                          onPressed:
                                              returnQuantity < purchasedQuantity
                                                  ? () {
                                                      setState(() {
                                                        product['returnQuantity'] =
                                                            returnQuantity + 1;
                                                      });
                                                    }
                                                  : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _canReturn(_purchaseDate) &&
                                          returnQuantity > 0
                                      ? () => _returnProduct(product)
                                      : null,
                                  child: const Text('Return'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 36),
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
