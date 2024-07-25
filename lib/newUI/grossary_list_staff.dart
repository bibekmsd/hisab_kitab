import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hisab_kitab/newUI/check_out_page.dart';
import 'package:hisab_kitab/newUI/nabhetekoProductAdd.dart';
// Make sure to import NabhetekoProductPage

class GrossaryListStaff extends StatefulWidget {
  final List<String> scannedValues;
  final Function(int) onDelete;

  const GrossaryListStaff({
    Key? key,
    required this.scannedValues,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<GrossaryListStaff> createState() => _GrossaryListStaffState();
}

class _GrossaryListStaffState extends State<GrossaryListStaff> {
  final Map<int, int> _productQuantities = {};
  final Map<int, double> _productTotalPrices = {};
  final Map<int, Map<String, dynamic>> _productDetails = {};
  String _totalQuantity = "0";
  String _totalPrice = "0.00";
  final TextEditingController _phoneController = TextEditingController();

  void _updateTotals() {
    setState(() {
      int totalQuantity = _productQuantities.values
          .fold(0, (prev, quantity) => prev + quantity);
      double totalPrice =
          _productTotalPrices.values.fold(0.0, (prev, total) => prev + total);
      _totalQuantity = totalQuantity.toString();
      _totalPrice = totalPrice.toStringAsFixed(2);
    });
  }

  void _incrementQuantity(int index, double itemPrice) {
    setState(() {
      _productQuantities[index] = (_productQuantities[index] ?? 0) + 1;
      _productTotalPrices[index] = itemPrice * _productQuantities[index]!;
      _updateTotals();
    });
  }

  void _decrementQuantity(int index, double itemPrice) {
    setState(() {
      if ((_productQuantities[index] ?? 0) > 0) {
        _productQuantities[index] = (_productQuantities[index] ?? 0) - 1;
        _productTotalPrices[index] = itemPrice * _productQuantities[index]!;
        _updateTotals();
      }
    });
  }

  void _handleCheckOut() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckOutPage(
          customerPhone: _phoneController.text.trim(),
          productDetails: _productDetails.values.toList(),
          totalQuantity: _totalQuantity,
          totalPrice: _totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data!.docs;
        print('Total documents fetched: ${documents.length}');

        documents.forEach((doc) {
          print('Document fetched with barcode: ${doc['Barcode']}');
        });

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.scannedValues.length,
                itemBuilder: (context, index) {
                  final barcode = widget.scannedValues[index];
                  final matchedDocs = documents
                      .where((doc) => doc['Barcode'] == barcode)
                      .toList();
                  print(
                      'Scanned value: $barcode, Matched documents: ${matchedDocs.length}');

                  if (matchedDocs.isEmpty) {
                    print('No matched document found for barcode: $barcode');
                    // Navigate to NabhetekoProductPage if product is not found

                    return ListTile(
                      leading: Icon(Icons.shopping_bag),
                      title: Text("Item ${index + 1}"),
                      subtitle: Text("Unknown"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Remove from Cart?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      widget.onDelete(index);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Yes"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("No"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  }

                  final doc = matchedDocs.first;
                  final itemName = doc['Name'] ?? 'Unknown';
                  final itemPriceString = doc['Price'].toString();
                  final itemPrice = double.tryParse(itemPriceString) ?? 0.0;

                  _productDetails[index] = {
                    'name': itemName,
                    'price': itemPriceString,
                    'barcode': widget.scannedValues[index],
                    'quantity': (_productQuantities[index] ?? 0).toString(),
                    'totalPrice':
                        (_productTotalPrices[index] ?? 0.0).toStringAsFixed(2),
                  };

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: Icon(Icons.shopping_bag),
                      title: Text(itemName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Barcode: ${widget.scannedValues[index]}"),
                          Text("Price: \$${itemPrice.toStringAsFixed(2)}"),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () =>
                                    _decrementQuantity(index, itemPrice),
                              ),
                              Text((_productQuantities[index] ?? 0).toString()),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () =>
                                    _incrementQuantity(index, itemPrice),
                              ),
                              Text(
                                  "Total: \$${(_productTotalPrices[index] ?? 0.0).toStringAsFixed(2)}"),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Remove from Cart?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      widget.onDelete(index);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Yes"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("No"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
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
                  Text("Total Quantity: $_totalQuantity"),
                  Text("Total Price: \$$_totalPrice"),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _handleCheckOut,
                        child: Text('Check Out'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
