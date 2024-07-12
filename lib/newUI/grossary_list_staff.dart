import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/check_out_page.dart';

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
  final Map<int, TextEditingController> _productQuantityControllers = {};
  final Map<int, double> _productTotalPrices = {};
  int _totalQuantity = 0;
  double _totalPrice = 0.0;

  @override
  void dispose() {
    for (var controller in _productQuantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getProductQuantityController(int index) {
    if (!_productQuantityControllers.containsKey(index)) {
      _productQuantityControllers[index] = TextEditingController();
    }
    return _productQuantityControllers[index]!;
  }

  void _updateTotals() {
    setState(() {
      _totalQuantity = _productQuantityControllers.values
          .map((controller) => int.tryParse(controller.text) ?? 0)
          .fold(0, (prev, quantity) => prev + quantity);

      _totalPrice =
          _productTotalPrices.values.fold(0.0, (prev, total) => prev + total);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final documents = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                DataTable(
                  columns: const [
                    DataColumn(label: Text('SN')),
                    DataColumn(label: Text('Barcode')),
                    DataColumn(label: Text('Item Name')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Remove')),
                  ],
                  rows: [
                    ...widget.scannedValues.asMap().entries.map(
                      (entry) {
                        final matchedDocs = documents
                            .where((doc) => doc['Barcode'] == entry.value)
                            .toList();

                        if (matchedDocs.isEmpty) {
                          debugPrint(
                              "No document found for barcode: ${entry.value}");
                          return DataRow(
                            cells: [
                              DataCell(Text((entry.key + 1).toString())),
                              DataCell(Text(entry.value)),
                              const DataCell(Text('Unknown')),
                              const DataCell(Text('0.0')),
                              DataCell(
                                TextField(
                                  controller:
                                      _getProductQuantityController(entry.key),
                                  onChanged: (value) {
                                    setState(() {
                                      final quantity = int.tryParse(value) ?? 0;
                                      final totalPrice = 0.0 * quantity;
                                      _productTotalPrices[entry.key] =
                                          totalPrice;
                                      _updateTotals();
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Quantity',
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _productTotalPrices[entry.key]?.toString() ??
                                      '0.0',
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text("Remove from Cart?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                widget.onDelete(entry.key);
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
                                  icon: const Icon(Icons.delete),
                                ),
                              ),
                            ],
                          );
                        }

                        final doc = matchedDocs.first;
                        final itemName = doc['Name'] ?? 'Unknown';
                        final itemPriceString = doc['Price'].toString();
                        final itemPrice =
                            double.tryParse(itemPriceString) ?? 0.0;

                        return DataRow(
                          cells: [
                            DataCell(Text((entry.key + 1).toString())),
                            DataCell(Text(entry.value)),
                            DataCell(Text(itemName)),
                            DataCell(Text(itemPrice.toString())),
                            DataCell(
                              TextField(
                                controller:
                                    _getProductQuantityController(entry.key),
                                onChanged: (value) {
                                  setState(() {
                                    final quantity = int.tryParse(value) ?? 0;
                                    final totalPrice = itemPrice * quantity;
                                    _productTotalPrices[entry.key] = totalPrice;
                                    _updateTotals();
                                  });
                                },
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Quantity',
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _productTotalPrices[entry.key]?.toString() ??
                                    '0.0',
                              ),
                            ),
                            DataCell(
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Remove from Cart?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              widget.onDelete(entry.key);
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
                                icon: const Icon(Icons.delete),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    // Total row
                    DataRow(cells: [
                      const DataCell(Text('')),
                      const DataCell(Text('Total')),
                      const DataCell(Text('')),

                      const DataCell(Text('')),
                      DataCell(Text(_totalQuantity.toString())),
                      DataCell(Text(_totalPrice.toString())),
                      DataCell(Container()), // Placeholder for the remove cell
                    ]),
                  ],
                ),
                // Checkout button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const CheckOutPage();
                      },
                    ));
                  },
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
