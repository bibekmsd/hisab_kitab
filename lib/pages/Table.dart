import 'package:flutter/material.dart';

class BanakoTable extends StatefulWidget {
  final List<String> scannedValues;

  const BanakoTable({super.key, required this.scannedValues});

  @override
  State<BanakoTable> createState() => _BanakoTableState();
}

class _BanakoTableState extends State<BanakoTable> {
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
              width: 200,
              child: Text('Barcode'),
            )),
            DataColumn(label: Text("Delete"))
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
                    DataCell(SizedBox(
                      width: 200,
                      child: Text(
                        entry.value,
                        softWrap: true,
                        maxLines: 2, // Set the maximum number of lines
                        overflow: TextOverflow.visible,
                      ),
                    )),
                    DataCell(IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.delete),
                    ))
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
