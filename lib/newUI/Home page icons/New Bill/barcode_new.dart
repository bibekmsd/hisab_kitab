// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

// class BarcodeNew extends StatefulWidget {
//   final Function(String) onScanResult;

//   const BarcodeNew({
//     super.key,
//     required this.onScanResult,
//   });

//   @override
//   State<BarcodeNew> createState() => _BarcodeNewState();
// }

// class _BarcodeNewState extends State<BarcodeNew> {
//   // late MobileScannerController _controller;
//   final MobileScannerController _controller =
//       MobileScannerController(torchEnabled: true);
 

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.topRight,
//       child: Container(
//         width: 350,
//         height: 200,
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: MobileScanner(
//             controller: _controller,
//             onDetect: (barcodeCapture) {
//               final List<Barcode> barcodes = barcodeCapture.barcodes;
//               for (final Barcode barcode in barcodes) {
//                 final String? rawValue = barcode.rawValue;
//                 if (rawValue != null) {
//                   widget.onScanResult(rawValue);
//                   break;
//                 }
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
