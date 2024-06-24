import 'package:flutter/material.dart';
import 'package:hisab_kitab/pages/Table.dart';
import 'package:hisab_kitab/pages/scannerr.dart';
import 'package:hisab_kitab/reuseable_widgets/buttons.dart';
import 'package:hisab_kitab/utils/gradiants.dart'; // Import the CustomScanner widget
import 'package:mobile_scanner/mobile_scanner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _scannedValues = [];
  bool _isScanning = false;
  bool _torchEnable = false;
  final  MobileScannerController _scannerController = MobileScannerController();

  void _handleScanResult(String result) {
    setState(() {
      if (!_scannedValues.contains(result)) {
        _scannedValues.add(result);
      }
    });
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
  }

  void _toggleTorch() {
    setState(() {
      _torchEnable = !_torchEnable;
      _scannerController.toggleTorch(); // Call without passing any arguments
    });
  }

  @override
  void dispose() {
    _scannerController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hisaab-Kitaab"),
        toolbarHeight: 50,
        centerTitle: true,
        actions: [
          Center(
            child: SizedBox(
              height: 24,
              width: 56,
              child: ElevatedButton(
                onPressed: _toggleTorch,
                child: Icon(
                  _torchEnable ? Icons.flash_off : Icons.flash_on_outlined,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const MeroGradiant(),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 220),
                  BanakoButton(
                    textSize: 20,
                    backgroundColor: Colors.black,
                    height: 50,
                    text: "Scan",
                    textColor: Colors.black,
                    width: 100,
                    onPressed: _startScanning,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                      height: 350,
                      child: BanakoTable(scannedValues: _scannedValues)),
                ],
              ),
            ),
          ),
          if (_isScanning)
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  const SizedBox(height: 0),
                  CustomScanner(
                    onScanResult: _handleScanResult,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
