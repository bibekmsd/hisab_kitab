import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetItemsFromDatabaseTable extends StatefulWidget {
  final List<String> scannedValues;
  final Function(int) onDelete;

  const GetItemsFromDatabaseTable({
    super.key,
    required this.scannedValues,
    required this.onDelete,
  });

  @override
  State<GetItemsFromDatabaseTable> createState() =>
      _GetItemsFromDatabaseTableState();
}

class _GetItemsFromDatabaseTableState extends State<GetItemsFromDatabaseTable> {
  final Map<int, TextEditingController> _productQuantityControllers = {};
  final Map<int, double> _productTotalPrices = {};

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
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 10,
              columns: const [
                DataColumn(label: Text("SN")),
                DataColumn(
                  label: SizedBox(
                    width: 80,
                    child: Text(
                      'Barcode',
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 100,
                    child: Text(
                      'Item Name',
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
                DataColumn(label: Text("Price")),
                DataColumn(label: Text("Quantity")),
                DataColumn(label: Text("Total")),
                DataColumn(label: Text("Remove")),
              ],
              rows: widget.scannedValues.asMap().entries.map(
                (entry) {
                  final matchedDocs = documents
                      .where(
                        (doc) => doc['Barcode'] == entry.value,
                      )
                      .toList();

                  if (matchedDocs.isEmpty) {
                    debugPrint("No document found for barcode: ${entry.value}");
                    return DataRow(
                      cells: [
                        DataCell(Text((entry.key + 1).toString())),
                        DataCell(
                          SizedBox(
                            width: 80,
                            child: Text(
                              entry.value,
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                        const DataCell(
                          SizedBox(
                            width: 100,
                            child: Text('Unknown'),
                          ),
                        ),
                        const DataCell(
                          SizedBox(
                            child: Text('0.0'),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            child: TextField(
                              controller:
                                  _getProductQuantityController(entry.key),
                              onChanged: (value) {
                                setState(() {
                                  final quantity = int.tryParse(value) ?? 0;
                                  final totalPrice = 0.0 * quantity;
                                  _productTotalPrices[entry.key] = totalPrice;
                                });
                              },
                            ),
                          ),
                        ),
                        DataCell(
                          Text(_productTotalPrices[entry.key]?.toString() ??
                              '0.0'),
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
                  }

                  final doc = matchedDocs.first;
                  final itemName = doc['Name'] ?? 'Unknown';
                  final itemPriceString = doc['Price'].toString();
                  final itemPrice = double.tryParse(itemPriceString) ?? 0.0;

                  return DataRow(
                    cells: [
                      DataCell(Text((entry.key + 1).toString())),
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: Text(
                            entry.value,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(itemName),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(itemPrice.toString()),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          child: TextField(
                            controller:
                                _getProductQuantityController(entry.key),
                            onChanged: (value) {
                              setState(() {
                                final quantity = int.tryParse(value) ?? 0;
                                final totalPrice = itemPrice * quantity;
                                _productTotalPrices[entry.key] = totalPrice;
                              });
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        Text(_productTotalPrices[entry.key]?.toString() ??
                            '0.0'),
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
              ).toList(),
            ),
          ),
        );
      },
    );
  }
}

