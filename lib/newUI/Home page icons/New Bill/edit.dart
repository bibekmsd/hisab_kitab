import 'package:flutter/material.dart';

class EditProductPage extends StatefulWidget {
  final String initialProductName;
  final double initialMRP;
  final double initialPrice;
  final double initialWholesalePrice;
  final double initialQuantity;
  final double initialDiscount;

  const EditProductPage({
    Key? key,
    required this.initialProductName,
    required this.initialMRP,
    required this.initialPrice,
    required this.initialWholesalePrice,
    required this.initialQuantity,
    required this.initialDiscount,
  }) : super(key: key);

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
  bool _updateInventory = false;
  String _discountType = 'Rupees';

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
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _mrpController.dispose();
    _priceController.dispose();
    _wholesalePriceController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Name'),
            TextField(controller: _productNameController),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New MRP/ Pc.'),
                      TextField(
                          controller: _mrpController,
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New Price/ Pc.'),
                      TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('New Wholesale Price/ Pc.'),
            TextField(
                controller: _wholesalePriceController,
                keyboardType: TextInputType.number),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _updateInventory,
                  onChanged: (value) =>
                      setState(() => _updateInventory = value!),
                ),
                Text('Update in inventory'),
              ],
            ),
            SizedBox(height: 16),
            Text('Quantity'),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(suffixText: 'Pc.'),
            ),
            SizedBox(height: 16),
            Text('Discount'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        suffixText: _discountType == 'Rupees' ? 'Rs.' : '%'),
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: _discountType,
                  onSelected: (String value) {
                    setState(() {
                      _discountType = value;
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
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Text(_discountType),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ExpansionTile(
              title: Text('Additional Details'),
              children: [
                // Add additional fields here
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Create a map with the updated product data
                      final updatedProduct = {
                        'ProductName': _productNameController.text,
                        'MRP': double.tryParse(_mrpController.text) ?? 0.0,
                        'Price': double.tryParse(_priceController.text) ?? 0.0,
                        'WholesalePrice':
                            double.tryParse(_wholesalePriceController.text) ??
                                0.0,
                        'Quantity':
                            double.tryParse(_quantityController.text) ?? 0.0,
                        'Discount':
                            double.tryParse(_discountController.text) ?? 0.0,
                        'DiscountType': _discountType,
                        'UpdateInventory': _updateInventory,
                        // Add other fields as necessary
                      };
                      Navigator.of(context).pop(updatedProduct);
                    },
                    child: Text('Done'),
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
