// // ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20customers/add_customer.dart';
// import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/HomePages/homepage.dart';
// // import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/homepage_body.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class CheckOutPage extends StatelessWidget {
//   User? user = FirebaseAuth.instance.currentUser;

//   final List<Map<String, dynamic>> productDetails;
//   final String totalQuantity;
//   final String totalPrice;
//   final String customerPhone;

//   CheckOutPage({
//     Key? key,
//     required this.productDetails,
//     required this.totalQuantity,
//     required this.totalPrice,
//     required this.customerPhone,
//   }) : super(key: key);

//   Future<Map<String, dynamic>> getShopDetails() async {
//     DocumentSnapshot shopDoc = await FirebaseFirestore.instance
//         .collection('admin')
//         .doc('09099090')
//         .get();
//     return shopDoc.data() as Map<String, dynamic>;
//   }

//   Future<Map<String, dynamic>> getBillNumber() async {
//     DocumentSnapshot billDoc = await FirebaseFirestore.instance
//         .collection('counters')
//         .doc('billNumber')
//         .get();
//     return billDoc.data() as Map<String, dynamic>;
//   }

// Future<void> generatePDF() async {
//   final pdf = pw.Document();
//   final shopDetails = await getShopDetails();
//   final billDetails = await getBillNumber();

//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.roll80,
//       build: (context) => pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.SizedBox(height: 10),
//           pw.Center(
//             child: pw.Text(
//               shopDetails['shopName'] ?? 'Shop Name',
//               style: pw.TextStyle(
//                 fontSize: 24, // Larger and bold for shop name
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//           ),
//           pw.SizedBox(height: 5),
//           pw.Center(
//             child: pw.Text(shopDetails['Address'] ?? 'Shop Address'),
//           ),
//           pw.Center(
//             child: pw.Text('Phone: ${shopDetails['phoneNo'] ?? 'N/A'}'),
//           ),
//           pw.Center(
//             child: pw.Text('PAN No: ${shopDetails['panNo'] ?? 'N/A'}'),
//           ),
//           pw.SizedBox(height: 15),
//           pw.Text(
//             'Bill No: ${billDetails['current'] ?? 'N/A'}',
//             style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
//           ),
//           pw.Text(
//             'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
//             style: pw.TextStyle(fontSize: 12),
//           ),
//           pw.Text(
//             'Time: ${DateFormat('hh:mm a').format(DateTime.now())}', // 12-hour format with AM/PM
//             style: pw.TextStyle(fontSize: 12),
//           ),
//           pw.SizedBox(height: 20),
//           pw.Text(
//             'Products Purchased:',
//             style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
//           ),
//           pw.SizedBox(height: 5),
//           pw.Table(
//             border: pw.TableBorder.all(),
//             columnWidths: {
//               0: pw.FlexColumnWidth(3), // Increased width for 'Name'
//               1: pw.FlexColumnWidth(1.5), // Increased width for 'Qty'
//               2: pw.FlexColumnWidth(2), // Price
//               3: pw.FlexColumnWidth(2), // Total
//             },
//             children: [
//               pw.TableRow(
//                 decoration: pw.BoxDecoration(color: PdfColors.grey300),
//                 children: [
//                   pw.Padding(
//                       padding: pw.EdgeInsets.all(5),
//                       child: pw.Text('Name',
//                           style:
//                               pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                   pw.Padding(
//                       padding: pw.EdgeInsets.all(5),
//                       child: pw.Text('Qty',
//                           style:
//                               pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                   pw.Padding(
//                       padding: pw.EdgeInsets.all(5),
//                       child: pw.Text('Price',
//                           style:
//                               pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                   pw.Padding(
//                       padding: pw.EdgeInsets.all(5),
//                       child: pw.Text('Total',
//                           style:
//                               pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                 ],
//               ),
//               ...productDetails
//                   .map((product) => pw.TableRow(
//                         children: [
//                           pw.Padding(
//                               padding: pw.EdgeInsets.all(5),
//                               child: pw.Text(product['name'])),
//                           pw.Padding(
//                               padding: pw.EdgeInsets.all(5),
//                               child: pw.Text(product['quantity'].toString())),
//                           pw.Padding(
//                               padding: pw.EdgeInsets.all(5),
//                               child: pw.Text(product['price'].toString())),
//                           pw.Padding(
//                               padding: pw.EdgeInsets.all(5),
//                               child:
//                                   pw.Text(product['totalPrice'].toString())),
//                         ],
//                       ))
//                   .toList(),
//             ],
//           ),
//           pw.SizedBox(height: 20),
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text('Total Quantity:',
//                   style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//               pw.Text(totalQuantity),
//             ],
//           ),
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text('Total Price:',
//                   style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//               pw.Text(totalPrice),
//             ],
//           ),
//           pw.SizedBox(height: 20),
//           pw.Center(
//             child: pw.Column(
//               children: [
//                 pw.Text(
//                   'Thank you!',
//                   style: pw.TextStyle(
//                       fontStyle: pw.FontStyle.italic, fontSize: 14),
//                 ),
//                 pw.Text(
//                   'Please visit again!',
//                   style: pw.TextStyle(
//                       fontStyle: pw.FontStyle.italic, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );

//   await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save());
// }

// void _showAddCustomerBottomSheet(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
//     ),
//     builder: (BuildContext context) {
//       return FractionallySizedBox(
//         heightFactor: 0.8,
//         child: Padding(
//           padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom),
//           child: Container(
//             padding: EdgeInsets.all(16),
// child: AddCustomers(productDetails:productDetails),
//           ),
//         ),
//       );
//     },
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Check Out'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Receipt',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: productDetails.length,
//                 itemBuilder: (context, index) {
//                   final product = productDetails[index];
//                   return Card(
//                     elevation: 2,
//                     margin: EdgeInsets.only(bottom: 8),
//                     child: ListTile(
//                       leading: ClipOval(
//                         child: Image.network(
//                           product['ImageUrl'] ??
//                               'assets/default_image.png', // Use a default image if URL is null
//                           width:
//                               60, // Increase width for a larger circular image
//                           height:
//                               80, // Increase height for a larger circular image
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Image.asset(
//                               'assets/default_image.png',
//                               width: 60, // Increase width for the default image
//                               height:
//                                   80, // Increase height for the default image
//                               fit: BoxFit.cover,
//                             );
//                           },
//                         ),
//                       ),
//                       title: Text(
//                         product['name'],
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Barcode: ${product['barcode']}'),
//                           Text('Price: ${product['price']}'),
//                           Text('Quantity: ${product['quantity']}'),
//                         ],
//                       ),
//                       trailing: Text(
//                         'Total: ${product['totalPrice']}',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('Total Quantity:', style: TextStyle(fontSize: 18)),
//                         Text(totalQuantity,
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                     SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('Total Price:', style: TextStyle(fontSize: 18)),
//                         Text(totalPrice,
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () => _showAddCustomerBottomSheet(context),
//                   icon: Icon(Icons.person_add),
//                   label: Text('Add Customer'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: generatePDF,
//                   icon: Icon(Icons.receipt),
//                   label: Text('Generate PDF'),
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () async {
//                     User? user = FirebaseAuth.instance.currentUser;
//                     if (user != null) {
//                       DocumentSnapshot userDoc = await FirebaseFirestore
//                           .instance
//                           .collection('users')
//                           .doc(user.uid)
//                           .get();

//                       String userRole = userDoc['role'];
//                       String username = userDoc['username'];
//                       String email = userDoc['email'];
//                       String panNo = userDoc['panNo'];
//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                           builder: (context) => HomePage(
//                             email: email,
//                             panNo: panNo,
//                             userRole: userRole,
//                             username: username,
//                           ),
//                         ),
//                       );
//                     } else {
//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                           builder: (context) => HomePage(
//                             email: "unknow",
//                             panNo: 'unkown',
//                             userRole: 'unknown',
//                             username: 'unknown',
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                   icon: Icon(Icons.home),
//                   label: Text('Home'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20customers/add_customer.dart';
// import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/HomePages/homepage.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class CheckOutPage extends StatelessWidget {
//   User? user = FirebaseAuth.instance.currentUser;

//   final List<Map<String, dynamic>> productDetails;
//   final String totalQuantity;
//   final String totalPrice;
//   final String customerPhone;

//   CheckOutPage({
//     Key? key,
//     required this.productDetails,
//     required this.totalQuantity,
//     required this.totalPrice,
//     required this.customerPhone,
//   }) : super(key: key);

//   Future<Map<String, dynamic>> getShopDetails() async {
//   if (user == null) {
//     throw Exception('User not authenticated');
//   }

//   try {
//     // Fetch the user document
//     DocumentSnapshot userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user!.uid)
//         .get();

//     if (!userDoc.exists) {
//       throw Exception('User document does not exist');
//     }

//     Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    
//     if (!userData.containsKey('panNo') || userData['panNo'] == null) {
//       throw Exception('PAN number not found for user');
//     }

//     String panNo = userData['panNo'];

//     // Use the panNo to fetch the admin document
//     DocumentSnapshot shopDoc = await FirebaseFirestore.instance
//         .collection('admin')
//         .doc(panNo)
//         .get();

//     if (!shopDoc.exists) {
//       throw Exception('Shop details not found for PAN: $panNo');
//     }

//     return shopDoc.data() as Map<String, dynamic>;
//   } catch (e) {
//     print('Error in getShopDetails: $e');
//     // Return a default map or rethrow the exception based on your needs
//     return {
//       'shopName': 'Horses',
//       'Address': 'Civil Mall',
//       'phoneNo': '9851122230',
//       'panNo': '087927493'
//     };
//   }
// }
//   Future<Map<String, dynamic>> getBillNumber() async {
//     DocumentSnapshot billDoc = await FirebaseFirestore.instance
//         .collection('counters')
//         .doc('billNumber')
//         .get();
//     return billDoc.data() as Map<String, dynamic>;
//   }

//   Future<void> generatePDF() async {
//     final pdf = pw.Document();
//     final shopDetails = await getShopDetails();
//     final billDetails = await getBillNumber();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.roll80,
//         build: (context) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.SizedBox(height: 10),
//             pw.Center(
//               child: pw.Text(
//                 shopDetails['shopName'] ?? 'Shop Name',
//                 style: pw.TextStyle(
//                   fontSize: 24,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//             ),
//             pw.SizedBox(height: 5),
//             pw.Center(
//               child: pw.Text(shopDetails['Address'] ?? 'Shop Address'),
//             ),
//             pw.Center(
//               child: pw.Text('Phone: ${shopDetails['phoneNo'] ?? 'N/A'}'),
//             ),
//             pw.Center(
//               child: pw.Text('PAN No: ${shopDetails['panNo'] ?? 'N/A'}'),
//             ),
//             pw.SizedBox(height: 15),
//             pw.Text(
//               'Bill No: ${billDetails['current'] ?? 'N/A'}',
//               style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
//             ),
//             pw.Text(
//               'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
//               style: pw.TextStyle(fontSize: 12),
//             ),
//             pw.Text(
//               'Time: ${DateFormat('hh:mm a').format(DateTime.now())}',
//               style: pw.TextStyle(fontSize: 12),
//             ),
//             pw.SizedBox(height: 20),
//             pw.Text(
//               'Products Purchased:',
//               style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
//             ),
//             pw.SizedBox(height: 5),
//             pw.Table(
//               border: pw.TableBorder.all(),
//               columnWidths: {
//                 0: pw.FlexColumnWidth(3),
//                 1: pw.FlexColumnWidth(1.5),
//                 2: pw.FlexColumnWidth(2),
//                 3: pw.FlexColumnWidth(2),
//               },
//               children: [
//                 pw.TableRow(
//                   decoration: pw.BoxDecoration(color: PdfColors.grey300),
//                   children: [
//                     pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text('Name',
//                             style:
//                                 pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                     pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text('Qty',
//                             style:
//                                 pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                     pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text('Price',
//                             style:
//                                 pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                     pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text('Total',
//                             style:
//                                 pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                   ],
//                 ),
//                 ...productDetails
//                     .map((product) => pw.TableRow(
//                           children: [
//                             pw.Padding(
//                                 padding: pw.EdgeInsets.all(5),
//                                 child: pw.Text(product['name'])),
//                             pw.Padding(
//                                 padding: pw.EdgeInsets.all(5),
//                                 child: pw.Text(product['quantity'].toString())),
//                             pw.Padding(
//                                 padding: pw.EdgeInsets.all(5),
//                                 child: pw.Text(product['price'].toString())),
//                             pw.Padding(
//                                 padding: pw.EdgeInsets.all(5),
//                                 child:
//                                     pw.Text(product['totalPrice'].toString())),
//                           ],
//                         ))
//                     .toList(),
//               ],
//             ),
//             pw.SizedBox(height: 20),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text('Total Quantity:',
//                     style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                 pw.Text(totalQuantity),
//               ],
//             ),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text('Total Price:',
//                     style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                 pw.Text(totalPrice),
//               ],
//             ),
//             pw.SizedBox(height: 20),
//             pw.Center(
//               child: pw.Column(
//                 children: [
//                   pw.Text(
//                     'Thank you!',
//                     style: pw.TextStyle(
//                         fontStyle: pw.FontStyle.italic, fontSize: 14),
//                   ),
//                   pw.Text(
//                     'Please visit again!',
//                     style: pw.TextStyle(
//                         fontStyle: pw.FontStyle.italic, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );

//     await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdf.save());
//   }

//   void _showAddCustomerBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
//       ),
//       builder: (BuildContext context) {
//         return FractionallySizedBox(
//           heightFactor: 0.8,
//           child: Padding(
//             padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom),
//             child: Container(
//               padding: EdgeInsets.all(16),
//               child: AddCustomers(productDetails: productDetails),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Check Out'),
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: getShopDetails(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData) {
//             return Center(child: Text('No shop details found'));
//           }

//           Map<String, dynamic> shopDetails = snapshot.data!;

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Receipt',
//                     style:
//                         TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 10),
//                 Text('Shop Name: ${shopDetails['shopName'] ?? 'N/A'}'),
//                 Text('Address: ${shopDetails['Address'] ?? 'N/A'}'),
//                 Text('Phone: ${shopDetails['phoneNo'] ?? 'N/A'}'),
//                 Text('PAN No: ${shopDetails['panNo'] ?? 'N/A'}'),
//                 SizedBox(height: 10),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: productDetails.length,
//                     itemBuilder: (context, index) {
//                       final product = productDetails[index];
//                       return Card(
//                         elevation: 2,
//                         margin: EdgeInsets.only(bottom: 8),
//                         child: ListTile(
//                           leading: ClipOval(
//                             child: Image.network(
//                               product['ImageUrl'] ?? 'assets/default_image.png',
//                               width: 60,
//                               height: 80,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Image.asset(
//                                   'assets/default_image.png',
//                                   width: 60,
//                                   height: 80,
//                                   fit: BoxFit.cover,
//                                 );
//                               },
//                             ),
//                           ),
//                           title: Text(
//                             product['name'],
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Barcode: ${product['barcode']}'),
//                               Text('Price: ${product['price']}'),
//                               Text('Quantity: ${product['quantity']}'),
//                             ],
//                           ),
//                           trailing: Text(
//                             'Total: ${product['totalPrice']}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('Total Quantity:',
//                                 style: TextStyle(fontSize: 18)),
//                             Text(totalQuantity,
//                                 style: TextStyle(
//                                     fontSize: 18, fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                         SizedBox(height: 8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('Total Price:',
//                                 style: TextStyle(fontSize: 18)),
//                             Text(totalPrice,
//                                 style: TextStyle(
//                                     fontSize: 18, fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () => _showAddCustomerBottomSheet(context),
//                       icon: Icon(Icons.person_add),
//                       label: Text('Add Customer'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: generatePDF,
//                       icon: Icon(Icons.receipt),
//                       label: Text('Generate PDF'),
//                       style: ElevatedButton.styleFrom(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () async {
//                         User? user = FirebaseAuth.instance.currentUser;
//                         if (user != null) {
//                           DocumentSnapshot userDoc = await FirebaseFirestore
//                               .instance
//                               .collection('users')
//                               .doc(user.uid)
//                               .get();

//                           String userRole = userDoc['role'];
//                           String username = userDoc['username'];
//                           String email = userDoc['email'];
//                           String panNo = userDoc['panNo'];
//                           Navigator.of(context).pushReplacement(
//                             MaterialPageRoute(
//                               builder: (context) => HomePage(
//                                 email: email,
//                                 panNo: panNo,
//                                 userRole: userRole,
//                                 username: username,
//                               ),
//                             ),
//                           );
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('User not authenticated')),
//                           );
//                         }
//                       },
//                       icon: Icon(Icons.home),
//                       label: Text('Home'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange,
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20customers/add_customer.dart';
// import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/HomePages/homepage.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:intl/intl.dart';

// class CheckOutPage extends StatelessWidget {
//   User? user = FirebaseAuth.instance.currentUser;

//   final List<Map<String, dynamic>> productDetails;
//   final String totalQuantity;
//   final String totalPrice;
//   final String customerPhone;

//   CheckOutPage({
//     Key? key,
//     required this.productDetails,
//     required this.totalQuantity,
//     required this.totalPrice,
//     required this.customerPhone,
//   }) : super(key: key);

//   Future<Map<String, dynamic>> getShopDetails() async {
//     if (user == null) {
//       throw Exception('User not authenticated');
//     }

//     try {
//       // First, fetch the user document to get the PAN number
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user!.uid)
//           .get();

//       if (!userDoc.exists) {
//         throw Exception('User document does not exist');
//       }

//       Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//       String panNo = userData['panNo'];

//       // Now use the PAN number to fetch the admin document
//       DocumentSnapshot shopDoc = await FirebaseFirestore.instance
//           .collection('admin')
//           .doc(panNo)
//           .get();

//       if (!shopDoc.exists) {
//         throw Exception('Shop details not found for PAN: $panNo');
//       }

//       return shopDoc.data() as Map<String, dynamic>;
//     } catch (e) {
//       print('Error in getShopDetails: $e');
//       return {
//         'shopName': 'Default Shop',
//         'Address': 'Default Address',
//         'phoneNo': 'N/A',
//         'panNo': 'N/A'
//       };
//     }
//   }

  // Future<Map<String, dynamic>> getBillNumber() async {
  //   DocumentSnapshot billDoc = await FirebaseFirestore.instance
  //       .collection('counters')
  //       .doc('billNumber')
  //       .get();
  //   return billDoc.data() as Map<String, dynamic>;
  // }

//   Future<void> generatePDF() async {
//     final pdf = pw.Document();
//     final shopDetails = await getShopDetails();
//     final billDetails = await getBillNumber();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.roll80,
//         build: (context) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.SizedBox(height: 10),
//             pw.Center(
//               child: pw.Text(
//                 shopDetails['shopName'] ?? 'Shop Name',
//                 style: pw.TextStyle(
//                   fontSize: 24,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//             ),
//             pw.SizedBox(height: 5),
//             pw.Center(
//               child: pw.Text(shopDetails['Address'] ?? 'Shop Address'),
//             ),
//             pw.Center(
//               child: pw.Text('Phone: ${shopDetails['phoneNo'] ?? 'N/A'}'),
//             ),
//             pw.Center(
//               child: pw.Text('PAN No: ${shopDetails['panNo'] ?? 'N/A'}'),
//             ),
//             pw.SizedBox(height: 15),
//             pw.Text(
//               'Bill No: ${billDetails['current'] ?? 'N/A'}',
//               style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
//             ),
//             pw.Text(
//               'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
//               style: pw.TextStyle(fontSize: 12),
//             ),
//             pw.Text(
//               'Time: ${DateFormat('hh:mm a').format(DateTime.now())}',
//               style: pw.TextStyle(fontSize: 12),
//             ),
//             pw.SizedBox(height: 20),
//             pw.Text(
//               'Products Purchased:',
//               style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
//             ),
//             pw.SizedBox(height: 5),
//             pw.Table(
//               border: pw.TableBorder.all(),
//               columnWidths: {
//                 0: pw.FlexColumnWidth(3),
//                 1: pw.FlexColumnWidth(1.5),
//                 2: pw.FlexColumnWidth(2),
//                 3: pw.FlexColumnWidth(2),
//               },
//               children: [
//                 pw.TableRow(
//                   decoration: pw.BoxDecoration(color: PdfColors.grey300),
//                   children: [
//                     pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text('Name',
//                             style:
//                                 pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                     pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text('Qty',
//                             style:
//                                 pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                     pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text('Price',
//                             style:
//                                 pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                     pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text('Total',
//                             style:
//                                 pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                   ],
//                 ),
//                 ...productDetails
//                     .map((product) => pw.TableRow(
//                           children: [
//                             pw.Padding(
//                                 padding: pw.EdgeInsets.all(5),
//                                 child: pw.Text(product['name'])),
//                             pw.Padding(
//                                 padding: pw.EdgeInsets.all(5),
//                                 child: pw.Text(product['quantity'].toString())),
//                             pw.Padding(
//                                 padding: pw.EdgeInsets.all(5),
//                                 child: pw.Text(product['price'].toString())),
//                             pw.Padding(
//                                 padding: pw.EdgeInsets.all(5),
//                                 child:
//                                     pw.Text(product['totalPrice'].toString())),
//                           ],
//                         ))
//                     .toList(),
//               ],
//             ),
//             pw.SizedBox(height: 20),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text('Total Quantity:',
//                     style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                 pw.Text(totalQuantity),
//               ],
//             ),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text('Total Price:',
//                     style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                 pw.Text(totalPrice),
//               ],
//             ),
//             pw.SizedBox(height: 20),
//             pw.Center(
//               child: pw.Column(
//                 children: [
//                   pw.Text(
//                     'Thank you!',
//                     style: pw.TextStyle(
//                         fontStyle: pw.FontStyle.italic, fontSize: 14),
//                   ),
//                   pw.Text(
//                     'Please visit again!',
//                     style: pw.TextStyle(
//                         fontStyle: pw.FontStyle.italic, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );

//     await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdf.save());
//   }

//   void _showAddCustomerBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
//       ),
//       builder: (BuildContext context) {
//         return FractionallySizedBox(
//           heightFactor: 0.8,
//           child: Padding(
//             padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom),
//             child: Container(
//               padding: EdgeInsets.all(16),
//               child: AddCustomers(productDetails: productDetails),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Check Out'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Receipt',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: productDetails.length,
//                 itemBuilder: (context, index) {
//                   final product = productDetails[index];
//                   return Card(
//                     elevation: 2,
//                     margin: EdgeInsets.only(bottom: 8),
//                     child: ListTile(
//                       leading: ClipOval(
//                         child: Image.network(
//                           product['ImageUrl'] ?? 'assets/default_image.png',
//                           width: 60,
//                           height: 80,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Image.asset(
//                               'assets/default_image.png',
//                               width: 60,
//                               height: 80,
//                               fit: BoxFit.cover,
//                             );
//                           },
//                         ),
//                       ),
//                       title: Text(
//                         product['name'],
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Barcode: ${product['barcode']}'),
//                           Text('Price: ${product['price']}'),
//                           Text('Quantity: ${product['quantity']}'),
//                         ],
//                       ),
//                       trailing: Text(
//                         'Total: ${product['totalPrice']}',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('Total Quantity:',
//                             style: TextStyle(fontSize: 18)),
//                         Text(totalQuantity,
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                     SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('Total Price:', style: TextStyle(fontSize: 18)),
//                         Text(totalPrice,
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () => _showAddCustomerBottomSheet(context),
//                   icon: Icon(Icons.person_add),
//                   label: Text('Add Customer'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: generatePDF,
//                   icon: Icon(Icons.receipt),
//                   label: Text('Generate PDF'),
//                   style: ElevatedButton.styleFrom(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () async {
//                     if (user != null) {
//                       // Fetch user details from Firestore
//                       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(user!.uid)
//                           .get();
                      
//                       Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                           builder: (context) => HomePage(
//                             email: userData['email'] ?? '',
//                             panNo: userData['panNo'] ?? '',
//                             userRole: userData['role'] ?? '',
//                             username: userData['username'] ?? '',
//                           ),
//                         ),
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('User not authenticated')),
//                       );
//                     }
//                   },
//                   icon: Icon(Icons.home),
//                   label: Text('Home'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20customers/add_customer.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/HomePages/homepage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';


class CheckOutPage extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;

  final List<Map<String, dynamic>> productDetails;
  final String totalQuantity;
  final String totalPrice;
  final String customerPhone;

  CheckOutPage({
    Key? key,
    required this.productDetails,
    required this.totalQuantity,
    required this.totalPrice,
    required this.customerPhone,
  }) : super(key: key);

  Future<Map<String, dynamic>> getShopDetails() async {
  if (user == null) {
    throw Exception('User not authenticated');
  }

  try {
    // Directly fetch the admin document using the user's UID as the PAN number
    DocumentSnapshot shopDoc = await FirebaseFirestore.instance
        .collection('admin')
        .doc(user!.uid)
        .get();

    if (!shopDoc.exists) {
      throw Exception('Shop details not found for user: ${user!.uid}');
    }

    return shopDoc.data() as Map<String, dynamic>;
  } catch (e) {
    print('Error in getShopDetails: $e');
    return {
      'shopName': 'Horses',
      'Address': 'Civil Mall',
      'phoneNo': '9851122230',
      'panNo': '087927493'
    };
  }
}

  Future<Map<String, dynamic>> getBillNumber() async {
    DocumentSnapshot billDoc = await FirebaseFirestore.instance
        .collection('counters')
        .doc('billNumber')
        .get();
    return billDoc.data() as Map<String, dynamic>;
  }


    Future<void> generatePDF() async {
    final pdf = pw.Document();
    final shopDetails = await getShopDetails();
    final billDetails = await getBillNumber();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                shopDetails['shopName'] ?? 'Shop Name',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(shopDetails['Address'] ?? 'Shop Address'),
            ),
            pw.Center(
              child: pw.Text('Phone: ${shopDetails['phoneNo'] ?? 'N/A'}'),
            ),
            pw.Center(
              child: pw.Text('PAN No: ${shopDetails['panNo'] ?? 'N/A'}'),
            ),
            pw.SizedBox(height: 15),
            pw.Text(
              'Bill No: ${billDetails['current'] ?? 'N/A'}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.Text(
              'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'Time: ${DateFormat('hh:mm a').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Products Purchased:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(1.5),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Name',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Qty',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Price',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Total',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...productDetails
                    .map((product) => pw.TableRow(
                          children: [
                            pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(product['name'])),
                            pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(product['quantity'].toString())),
                            pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(product['price'].toString())),
                            pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child:
                                    pw.Text(product['totalPrice'].toString())),
                          ],
                        ))
                    .toList(),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Quantity:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(totalQuantity),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Price:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(totalPrice),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'Thank you!',
                    style: pw.TextStyle(
                        fontStyle: pw.FontStyle.italic, fontSize: 14),
                  ),
                  pw.Text(
                    'Please visit again!',
                    style: pw.TextStyle(
                        fontStyle: pw.FontStyle.italic, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  void _showAddCustomerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.all(16),
              child: AddCustomers(productDetails: productDetails),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: ClipOval(
                        child: Image.network(
                          product['ImageUrl'] ?? 'assets/default_image.png',
                          width: 60,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/default_image.png',
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      title: Text(
                        product['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Barcode: ${product['barcode']}'),
                          Text('Price: ${product['price']}'),
                          Text('Quantity: ${product['quantity']}'),
                        ],
                      ),
                      trailing: Text(
                        'Total: ${product['totalPrice']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Quantity:', style: TextStyle(fontSize: 18)),
                        Text(totalQuantity,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Price:', style: TextStyle(fontSize: 18)),
                        Text(totalPrice,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAddCustomerBottomSheet(context),
                  icon: Icon(Icons.person_add),
                  label: Text('Add Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: generatePDF,
                  icon: Icon(Icons.receipt),
                  label: Text('Generate PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (user != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => HomePage(
                            email: user!.email ?? '',
                            panNo: user!.uid,
                            userRole: 'admin', // You might want to store this in user metadata
                            username: user!.displayName ?? '',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User not authenticated')),
                      );
                    }
                  },
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}