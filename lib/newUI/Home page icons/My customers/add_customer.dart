import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddCustomers extends StatefulWidget {
  final List<Map<String, dynamic>> productDetails;

  const AddCustomers({
    Key? key,
    required this.productDetails,
  }) : super(key: key);

  @override
  _AddCustomersState createState() => _AddCustomersState();
}

class _AddCustomersState extends State<AddCustomers> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timestamp? _memberSince;
  bool _isLoading = false;
  bool _isSaving = false;

  final Color primaryColor = Color.fromRGBO(18, 30, 46, 1);

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    if (_phoneController.text.length == 10) {
      _searchCustomer();
    }
  }

  Future<String> _getNextBillNumber() async {
    final billNumberDoc = _firestore.collection('counters').doc('billNumber');

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(billNumberDoc);

      int newBillNumber;
      if (!snapshot.exists) {
        newBillNumber = 1;
        transaction.set(billNumberDoc, {'current': newBillNumber});
      } else {
        newBillNumber = (snapshot.data()?['current'] ?? 0) + 1;
        transaction.update(billNumberDoc, {'current': newBillNumber});
      }

      return newBillNumber.toString();
    });
  }

  Future<void> _addBill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final phoneNo = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final notes = _notesController.text.trim();
    final birthDate = _birthDateController.text.trim();

    try {
      String billNumber = await _getNextBillNumber();

      Map<String, dynamic> historyEntry = {
        'Products': widget.productDetails,
        'PurchaseDate': Timestamp.fromDate(DateTime.now()),
        'CustomerPhone': phoneNo.isNotEmpty ? phoneNo : null,
      };

      if (phoneNo.isNotEmpty) {
        final customerRef = _firestore.collection('customers').doc(phoneNo);
        final doc = await customerRef.get();

        Map<String, dynamic> customerData = {
          'PhoneNo': phoneNo,
          'Name': name,
          'Address': address,
          'Notes': notes,
          'BirthDate': birthDate,
          'updatedAt': FieldValue.serverTimestamp(),
          'History.$billNumber': historyEntry,
        };

        if (!doc.exists) {
          customerData['createdAt'] = FieldValue.serverTimestamp();
        }

        await customerRef.set(customerData, SetOptions(merge: true));
      }

      await _firestore.collection('bills').doc(billNumber).set(historyEntry);

      await _firestore.collection('billing_data').doc('bill_numbers').set({
        'bill_numbers': FieldValue.arrayUnion([billNumber]),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer and Bill saved successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving customer: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _searchCustomer() async {
    final phoneNo = _phoneController.text.trim();
    if (phoneNo.length != 10) return;

    setState(() => _isLoading = true);

    try {
      final doc = await _firestore.collection('customers').doc(phoneNo).get();
      if (doc.exists) {
        final data = doc.data();
        _nameController.text = data?['Name'] ?? '';
        _addressController.text = data?['Address'] ?? '';
        _notesController.text = data?['Notes'] ?? '';
        _birthDateController.text = data?['BirthDate'] ?? '';
        _memberSince = data?['createdAt'];
      } else {
        _clearFields();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching customer: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearFields() {
    _nameController.clear();
    _addressController.clear();
    _notesController.clear();
    _birthDateController.clear();
    _memberSince = null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(primary: primaryColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Info'),
        backgroundColor: primaryColor,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 10) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _notesController,
                        label: 'Notes',
                        icon: Icons.note,
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _birthDateController,
                        label: 'Birth Date',
                        icon: Icons.cake,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.home,
                        maxLines: 2,
                      ),
                      if (_memberSince != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Member since: ${DateFormat('yyyy-MM-dd').format(_memberSince!.toDate())}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor),
                          ),
                        ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _addBill,
                        child: _isSaving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Add Bill', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              primaryColor, // use backgroundColor instead of primary
                          foregroundColor: Colors
                              .white, // use foregroundColor instead of onPrimary
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLines,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(color: primaryColor),
    );
  }
}
