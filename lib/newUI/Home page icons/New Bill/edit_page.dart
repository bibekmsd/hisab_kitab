import 'package:flutter/material.dart';

class EditProductPage extends StatefulWidget {
  final String initialProductName;
  final int initialMRP;
  final int initialPrice;
  final int initialWholesalePrice;
  final int initialQuantity;
  final double initialDiscount;
  final String initialImageUrl; // Added to handle ImageUrl

  EditProductPage({
    required this.initialProductName,
    required this.initialMRP,
    required this.initialPrice,
    required this.initialWholesalePrice,
    required this.initialQuantity,
    required this.initialDiscount,
    required this.initialImageUrl, // Added to handle ImageUrl
  });

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController _productNameController;
  late TextEditingController _mrpController;
  late TextEditingController _priceController;
  late TextEditingController _wholesalePriceController;
  late TextEditingController _quantityController;
  late TextEditingController _discountController;
  late TextEditingController _imageUrlController; // Added for ImageUrl
  bool _updateInventory = false;
  String _discountType = 'Rupees'; // Default discount type is "Rupees"
  double _finalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _productNameController =
        TextEditingController(text: widget.initialProductName);
    _mrpController = TextEditingController(text: widget.initialMRP.toString());
    _priceController =
        TextEditingController(text: widget.initialPrice.toString());
    _wholesalePriceController =
        TextEditingController(text: widget.initialWholesalePrice.toString());
    _quantityController =
        TextEditingController(text: widget.initialQuantity.toString());
    _discountController =
        TextEditingController(text: widget.initialDiscount.toString());
    _imageUrlController = TextEditingController(
        text: widget.initialImageUrl); // Initialize ImageUrl

    // Calculate initial final price based on the discount type
    _calculateFinalPrice();
  }

  void _calculateFinalPrice() {
    double originalPrice = double.tryParse(_priceController.text) ?? 0.0;
    double discount = double.tryParse(_discountController.text) ?? 0.0;

    // Apply discount based on the selected type
    if (_discountType == 'Percentage') {
      _finalPrice = originalPrice - (originalPrice * discount / 100);
    } else if (_discountType == 'Rupees') {
      _finalPrice = originalPrice - discount;
    }

    // Ensure the final price is not negative
    if (_finalPrice < 0) {
      _finalPrice = 0;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _mrpController.dispose();
    _priceController.dispose();
    _wholesalePriceController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    _imageUrlController.dispose(); // Dispose ImageUrl controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product Name'),
            TextField(
              controller: _productNameController,
              enabled: false, // Read-only
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MRP/ Pc.'),
                      TextField(
                        controller: _mrpController,
                        enabled: false, // Read-only
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Wholesale Price/ Pc.'),
                      TextField(
                        controller: _wholesalePriceController,
                        enabled: false, // Read-only
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Quantity'),
            TextField(
              controller: _quantityController,
              enabled: false, // Read-only
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(suffixText: 'Pc.'),
            ),
            const SizedBox(height: 16),
            const Text('Discount'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        suffixText: _discountType == 'Rupees' ? 'Rs.' : '%'),
                    onChanged: (value) =>
                        _calculateFinalPrice(), // Recalculate price on change
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: _discountType,
                  onSelected: (String value) {
                    setState(() {
                      _discountType = value;
                      _calculateFinalPrice(); // Recalculate price when discount type changes
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Percentage',
                      child: Text('Percentage'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Rupees',
                      child: Text('Rupees'),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Text(_discountType),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Final Price/Pc: Rs. ${_finalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Image URL'),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                hintText: 'Enter Image URL',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Create a map with the updated product data
                      final updatedProduct = {
                        'ProductName': _productNameController.text,
                        'MRP': double.tryParse(_mrpController.text) ?? 0.0,
                        'Price': _finalPrice, // Use final price after discount
                        'WholesalePrice':
                            double.tryParse(_wholesalePriceController.text) ??
                                0.0,
                        'Quantity': int.tryParse(_quantityController.text) ?? 0,
                        'Discount':
                            double.tryParse(_discountController.text) ?? 0.0,
                        'DiscountType': _discountType,
                        'UpdateInventory': _updateInventory,
                        'ImageUrl': _imageUrlController.text.isNotEmpty
                            ? _imageUrlController.text
                            : 'assets/default_image.png', // Use the updated ImageUrl
                      };
                      Navigator.of(context).pop(updatedProduct);
                    },
                    child: const Text('Done'),
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
