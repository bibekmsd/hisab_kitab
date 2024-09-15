import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCustomers extends StatefulWidget {
  final List<Map<String, dynamic>> productDetails;

  const AddCustomers({
    super.key,
    required this.productDetails,
  });

  @override
  _AddCustomersState createState() {
    return _AddCustomersState();
  }
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

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Function to generate the next bill number and increment the counter
  Future<String> _getNextBillNumber() async {
    final billNumberDoc = _firestore.collection('counters').doc('billNumber');

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(billNumberDoc);

      // Check if the document exists, if not, initialize it
      int newBillNumber;
      if (!snapshot.exists) {
        // If the document does not exist, start with bill number 1
        newBillNumber = 1;
        transaction.set(billNumberDoc, {'current': newBillNumber});
      } else {
        // If the document exists, get the current value and increment it
        newBillNumber = (snapshot.data()?['current'] ?? 0) + 1;
        transaction.update(billNumberDoc, {'current': newBillNumber});
      }

      return newBillNumber.toString();
    });
  }

  // Function to save the customer and the bill number
  Future<void> _addBill() async {
    final phoneNo = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final notes = _notesController.text.trim();
    final birthDate = _birthDateController.text.trim();

    final purchaseDate = DateTime.now().toLocal().toString().split(' ')[0];

    try {
      // Generate the next bill number
      String billNumber = await _getNextBillNumber();

      Map<String, dynamic> historyEntry = {
        'Products': widget.productDetails,
        'PurchaseDate': Timestamp.fromDate(DateTime.now()),
        'BillNumber': billNumber,
        'CustomerPhone': phoneNo.isNotEmpty ? phoneNo : null,
      };

      if (phoneNo.isNotEmpty) {
        // Store customer in the 'customers' collection
        final customerRef = _firestore.collection('customers').doc(phoneNo);

        // Check if the customer exists
        final doc = await customerRef.get();
        if (doc.exists) {
          // Update existing customer's details and add bill under 'bills'
          await customerRef.update({
            'PhoneNo': phoneNo,
            'Name': name,
            'Address': address,
            'Notes': notes,
            'BirthDate': birthDate,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Add bill to the 'bills' subcollection
          await customerRef
              .collection('bills')
              .doc(billNumber)
              .set(historyEntry);
        } else {
          // Create new customer document
          final newCustomerData = {
            'PhoneNo': phoneNo,
            'Name': name,
            'Address': address,
            'Notes': notes,
            'BirthDate': birthDate,
            'createdAt': FieldValue.serverTimestamp(),
            'members': FieldValue.arrayUnion([phoneNo]),
          };
          await customerRef.set(newCustomerData);

          // Add bill to the 'bills' subcollection
          await customerRef
              .collection('bills')
              .doc(billNumber)
              .set(historyEntry);
        }
      } else {
        // Non-member case: Store bill in the 'bills' collection
        await _firestore.collection('bills').doc(billNumber).set(historyEntry);
      }

      // Add the bill number to a central document containing all bill numbers
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
    }
  }

  // Function to search for a customer by phone number
  Future<void> _searchCustomer() async {
    final phoneNo = _phoneController.text.trim();
    if (phoneNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    try {
      final doc = await _firestore.collection('customers').doc(phoneNo).get();
      if (doc.exists) {
        final data = doc.data();
        _nameController.text = data?['Name'] ?? '';
        _addressController.text = data?['Address'] ?? '';
        _notesController.text = data?['Notes'] ?? '';
        _birthDateController.text = data?['BirthDate'] ?? '';
        _memberSince = data?['createdAt'];
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Customer not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching customer: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextButton(
                onPressed: _searchCustomer,
                child: Text('Search by Phone No'),
              ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                ),
              ),
              TextFormField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: 'Enter BirthDate',
                ),
                keyboardType: TextInputType.datetime,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                ),
              ),
              if (_memberSince != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Member since: ${_memberSince?.toDate().toLocal().toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addBill,
                child: Text('Add Bill'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
