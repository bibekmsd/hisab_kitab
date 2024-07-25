// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/add_customer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CheckOutPage extends StatelessWidget {
  final List<Map<String, dynamic>> productDetails;
  final String totalQuantity;
  final String totalPrice;
  final String customerPhone;

  const CheckOutPage({
    super.key,
    required this.productDetails,
    required this.totalQuantity,
    required this.totalPrice,
    required this.customerPhone,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> generatePDF() async {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Receipt',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.ListView.builder(
                itemCount: productDetails.length,
                itemBuilder: (context, index) {
                  final product = productDetails[index];
                  return pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Name: ${product['name']}'),
                        pw.Text('Barcode: ${product['barcode']}'),
                        pw.Text('Price: \$${product['price']}'),
                        pw.Text('Quantity: ${product['quantity']}'),
                        pw.Text('Total: \$${product['totalPrice']}'),
                      ],
                    ),
                  );
                },
              ),
              pw.SizedBox(height: 10),
              pw.Text('Total Quantity: $totalQuantity'),
              pw.Text('Total Price: \$${totalPrice}'),
            ],
          ),
        ),
      );

      // Display the PDF using the `printing` package
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    }

    void showCheckOutForm() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: 700, minHeight: 600),
        builder: (context) => AddCustomers(productDetails: productDetails),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Check Out'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receipt',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: productDetails.length,
                itemBuilder: (context, index) {
                  final product = productDetails[index];
                  return Card(
                    child: ListTile(
                      title: Text(product['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Barcode: ${product['barcode']}'),
                          Text('Price: \$${product['price']}'),
                          Text('Quantity: ${product['quantity']}'),
                          Text('Total: \$${product['totalPrice']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Text('Total Quantity: $totalQuantity'),
            Text('Total Price: \$${totalPrice}'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: showCheckOutForm,
                        child: Text('Add Customers'),
                      ),
                      ElevatedButton(
                        onPressed: generatePDF,
                        child: Text('Generate PDF'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
