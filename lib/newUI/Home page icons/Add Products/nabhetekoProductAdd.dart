import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';

class NabhetekoProductPage extends StatefulWidget {
  const NabhetekoProductPage({Key? key}) : super(key: key);

  @override
  _NabhetekoProductPageState createState() => _NabhetekoProductPageState();
}

class _NabhetekoProductPageState extends State<NabhetekoProductPage> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _wholesalePriceController =
      TextEditingController();

  bool _productExists = false;
  bool _isScanning = false;
  bool _isSearching = false;
  bool _isUploading = false;
  String _selectedProductType = 'Packaged Foods';
  File? _imageFile;
  String? _imageUrl;

  final List<String> _productTypes = [
    'Personal Care & Hygiene',
    'Home Cleaning & Essentials',
    'Fresh Meat, Fish & Eggs',
    'Staples, Oils & Spices',
    'Fruits & Vegetables',
    'Health & Wellness',
    'Snacks & Confectionery',
    'Beverages & Drinks',
    'Dairy & Bakery',
    'Frozen Foods',
    'Baby Care',
    'Packaged Foods',
    'Organic & Gourmet'
  ];

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _wholesalePriceController.dispose();
    super.dispose();
  }

  void _handleScanResult(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      _fetchProductDetails(barcode.rawValue ?? '');
    }
    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _fetchProductDetails(String barcode) async {
    setState(() {
      _isSearching = true;
    });

    if (barcode.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('ProductsNew')
          .doc(barcode)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _productExists = true;
          _barcodeController.text = barcode;
          _nameController.text = data['Name'];
          _priceController.text = data['Price'].toString();
          _quantityController.text = '';
          _wholesalePriceController.text = data['WholesalePrice'].toString();
          _selectedProductType = data['ProductType'];
          _imageUrl = data['ImageUrl'];
          _imageFile = null;
        });
      } else {
        setState(() {
          _productExists = false;
          _barcodeController.text = barcode;
          _nameController.clear();
          _priceController.clear();
          _quantityController.clear();
          _wholesalePriceController.clear();
          _imageUrl = null;
          _imageFile = null;
        });
      }
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching product details')),
      );
    }

    setState(() {
      _isSearching = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageUrl = null;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _imageUrl;

    setState(() {
      _isUploading = true;
    });

    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_barcodeController.text}.jpg';
      final Reference ref =
          FirebaseStorage.instance.ref().child('product_images/$fileName');

      final UploadTask uploadTask = ref.putFile(_imageFile!);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _isUploading = false;
        _imageUrl = downloadUrl;
      });

      return downloadUrl;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      debugPrint('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
      return null;
    }
  }

  Future<void> _saveProduct() async {
    if (_isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for the image to upload')),
      );
      return;
    }

    try {
      final barcode = _barcodeController.text;
      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final int quantity = int.tryParse(_quantityController.text) ?? 0;
      final double wholesalePrice =
          double.tryParse(_wholesalePriceController.text) ?? 0.0;

      // Upload image if a new one is selected
      if (_imageFile != null) {
        _imageUrl = await _uploadImage();
      }

      final data = {
        'Barcode': barcode,
        'Name': _nameController.text,
        'Price': price,
        'WholesalePrice': wholesalePrice,
        'ProductType': _selectedProductType,
        'ImageUrl': _imageUrl,
      };

      final docRef =
          FirebaseFirestore.instance.collection('ProductsNew').doc(barcode);

      if (_productExists) {
        // Update existing product
        await docRef.update({
          ...data,
          'Quantity': FieldValue.increment(quantity),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
      } else {
        // Add new product
        data['Quantity'] = quantity;
        await docRef.set(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New product added successfully')),
        );
      }

      // Clear the input fields and reset state
      _clearInputFields();
    } catch (e) {
      debugPrint('Error saving product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save product')),
      );
    }
  }

  void _clearInputFields() {
    setState(() {
      _barcodeController.clear();
      _nameController.clear();
      _priceController.clear();
      _quantityController.clear();
      _wholesalePriceController.clear();
      _selectedProductType = 'Packaged Foods';
      _productExists = false;
      _imageFile = null;
      _imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Management"),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _barcodeController.text.isEmpty
              ? _buildInitialScreen()
              : _buildProductForm(),
    );
  }

  Widget _buildInitialScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isScanning)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 100, // Adjust the height as needed
                width: double.infinity, // Adjust the width as needed
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.blue, width: 2), // Optional: Adds border
                  borderRadius:
                      BorderRadius.circular(8), // Optional: Rounds the corners
                ),
                child: MobileScanner(
                  controller: MobileScannerController(
                    facing: CameraFacing.back,
                    torchEnabled: false,
                  ),
                  onDetect: _handleScanResult,
                ),
              ),
            ),
          ElevatedButton.icon(
            icon: Icon(_isScanning ? Icons.stop : Icons.qr_code_scanner),
            label: Text(_isScanning ? 'Stop Scanning' : 'Scan Barcode'),
            onPressed: () {
              setState(() {
                _isScanning = !_isScanning;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
          const SizedBox(height: 20),
          const Text('OR'),
          const SizedBox(height: 20),
          SizedBox(
            width: 250,
            child: TextField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Enter Barcode',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) => _fetchProductDetails(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _productExists ? 'Update Product' : 'Add New Product',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _barcodeController,
            decoration:
                const InputDecoration(labelText: 'Barcode', enabled: false),
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Product Name'),
          ),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price/Piece (MRP)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Quantity to Add'),
            keyboardType: TextInputType.number,
          ),
          DropdownButtonFormField<String>(
            value: _selectedProductType,
            decoration: const InputDecoration(labelText: 'Product Type'),
            items: _productTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedProductType = newValue!;
              });
            },
          ),
          ExpansionTile(
            title: const Text('Additional Details'),
            children: [
              TextField(
                controller: _wholesalePriceController,
                decoration: const InputDecoration(labelText: 'Cost Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildImageSection(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveProduct,
            child: Text(_productExists ? 'Update Product' : 'Add Product'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                _barcodeController.clear();
              });
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        if (_isUploading)
          const CircularProgressIndicator()
        else if (_imageFile != null)
          Image.file(_imageFile!, height: 200, width: 200, fit: BoxFit.cover)
        else if (_imageUrl != null)
          Image.network(_imageUrl!, height: 200, width: 200, fit: BoxFit.cover)
        else
          const Icon(Icons.image, size: 200, color: Colors.grey),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
      ],
    );
  }
}
