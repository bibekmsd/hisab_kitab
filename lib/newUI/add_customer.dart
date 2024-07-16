// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCustomers extends StatefulWidget {
  final List<Map<String, dynamic>> productDetails;

  const AddCustomers({
    super.key,
    required this.productDetails, // Add required parameter
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

  Future<void> _saveCustomer() async {
    if (_formKey.currentState?.validate() ?? false) {
      final phoneNo = _phoneController.text.trim();
      final name = _nameController.text.trim();
      final address = _addressController.text.trim();
      final notes = _notesController.text.trim();
      final birthDate = _birthDateController.text.trim();

      // Get the current date as a string
      final purchaseDate = DateTime.now().toLocal().toString().split(' ')[0];

      // Prepare the history entry with product details
      Map<String, dynamic> historyEntry = {
        'Products': widget.productDetails,
        'PurchaseDate': DateTime.now(),
      };

      final customerData = {
        'PhoneNo': phoneNo,
        'Name': name,
        'Address': address,
        'Notes': notes,
        'BirthDate': birthDate,
        'createdAt': FieldValue.serverTimestamp(),
        'History': {
          purchaseDate: [historyEntry]
        },
      };

      try {
        final docRef = _firestore.collection('customers').doc(phoneNo);

        // Check if the customer already exists
        final doc = await docRef.get();
        if (doc.exists) {
          // Preserve the existing createdAt value
          final existingData = doc.data();
          final createdAt = existingData?['createdAt'];

          // Update existing customer document with preserved createdAt
          await docRef.update({
            'PhoneNo': phoneNo,
            'Name': name,
            'Address': address,
            'Notes': notes,
            'BirthDate': birthDate,
            'History.$purchaseDate': FieldValue.arrayUnion(
                [historyEntry]), // Append history under date key
          });

          // Set the preserved createdAt value back if it exists
          if (createdAt != null) {
            await docRef.update({'createdAt': createdAt});
          }
        } else {
          // Create new customer document
          await docRef.set(customerData);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Customer saved successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving customer: $e')),
        );
      }
    }
  }

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
        setState(() {}); // Update the UI to reflect changes
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  ),
                  ElevatedButton(
                    onPressed: _saveCustomer,
                    child: Text('Save'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
