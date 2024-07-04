import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddItemsToDatabaseTable extends StatefulWidget {
  final List<String> scannedValues;
  final Function(int) onDelete;

  const AddItemsToDatabaseTable({
    super.key,
    required this.scannedValues,
    required this.onDelete,
  });

  @override
  State<AddItemsToDatabaseTable> createState() =>
      _AddItemsToDatabaseTableState();
}

class _AddItemsToDatabaseTableState extends State<AddItemsToDatabaseTable> {
  final Map<int, TextEditingController> _productNameControllers = {};
  final Map<int, TextEditingController> _productPriceControllers = {};

  @override
  void dispose() {
    for (var controller in _productNameControllers.values) {
      controller.dispose();
    }
    for (var controller in _productPriceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getProductNameController(int index) {
    if (!_productNameControllers.containsKey(index)) {
      _productNameControllers[index] = TextEditingController();
    }
    return _productNameControllers[index]!;
  }

  TextEditingController _getProductPriceController(int index) {
    if (!_productPriceControllers.containsKey(index)) {
      _productPriceControllers[index] = TextEditingController();
    }
    return _productPriceControllers[index]!;
  }

  addItems(
      String productBarcode, String productName, String productPrice) async {
    await FirebaseFirestore.instance
        .collection("Products")
        .doc(productBarcode)
        .set({
      "Barcode": productBarcode,
      "Name": productName,
      "Price": productPrice,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 10,
          columns: const [
            DataColumn(
              label: Text("SN"),
            ),
            DataColumn(
              label: SizedBox(
                width: 80,
                child: Text(
                  'Barcode',
                  softWrap: true,
                  maxLines: 2, // Set the maximum number of lines
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 100,
                child: Text('Item Name'),
              ),
            ),
            DataColumn(label: Text("Price")),
            DataColumn(label: Text("Add Item")),
            DataColumn(label: Text("Delete")),
          ],
          rows: widget.scannedValues
              .asMap()
              .entries
              .map(
                (entry) => DataRow(
                  cells: [
                    DataCell(
                      Text((entry.key + 1).toString()),
                    ),
                    DataCell(
                      SizedBox(
                        width: 80,
                        child: Text(
                          entry.value,
                          softWrap: true,
                          maxLines: 2, // Set the maximum number of lines
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _getProductNameController(entry.key),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _getProductPriceController(entry.key),
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          addItems(
                              entry.value,
                              _getProductNameController(entry.key).text,
                              _getProductPriceController(entry.key).text);
                          // widget.onDelete(entry.key);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Product Added To Database")),
                          );
                        },
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
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
