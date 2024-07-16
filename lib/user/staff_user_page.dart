// import 'package:flutter/material.dart';
// import 'package:hisab_kitab/newUI/barcode_new.dart';
// import 'package:hisab_kitab/reuseable_widgets/Table.dart';
// import 'package:hisab_kitab/utils/scannerr.dart';
// import 'package:hisab_kitab/reuseable_widgets/buttons.dart';
// import 'package:hisab_kitab/reuseable_widgets/getItemsFromDatabase.dart';
// import 'package:hisab_kitab/utils/gradiants.dart'; // Import the CustomScanner widget
// import 'package:mobile_scanner/mobile_scanner.dart';

// class StaffUserScreen extends StatefulWidget {
//   const StaffUserScreen({super.key});

//   @override
//   State<StaffUserScreen> createState() => _StaffUserScreenState();
// }

// class _StaffUserScreenState extends State<StaffUserScreen> {
//   final List<String> _scannedValues = [];
//   bool _isScanning = false;
//   final MobileScannerController _scannerController = MobileScannerController();

//   void _handleScanResult(String result) {
//     setState(() {
//       if (!_scannedValues.contains(result)) {
//         _scannedValues.add(result);
//       }
//     });
//   }

//   void _startScanning() {
//     setState(() {
//       _isScanning = true;
//       _scannerController.start(); // Ensure the scanner is started
//     });
//   }

//   void _handleDelete(int index) {
//     setState(() {
//       _scannedValues.removeAt(index);
//     });
//   }

//   @override
//   void dispose() {
//     _scannerController.dispose(); // Dispose the controller when not needed
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: const Text("Staff-Screen"),
//         toolbarHeight: 50,
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           // const MeroGradiant(),
//           SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: Center(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 220),
//                   BanakoButton(
//                     textSize: 20,
//                     backgroundColor: Colors.black,
//                     height: 50,
//                     text: "Scan Items",
//                     textColor: Colors.black,
//                     width: 200,
//                     onPressed: _startScanning,
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     height: 350,
//                     child: GetItemsFromDatabaseTable(
//                       scannedValues: _scannedValues,
//                       onDelete: _handleDelete,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (_isScanning)
//             Align(
//               alignment: Alignment.topCenter,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 0),
//                   CustomScanner(
//                     onScanResult: _handleScanResult,
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
