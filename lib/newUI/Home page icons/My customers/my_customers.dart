import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart'; // Import excel package
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20customers/customer_details.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Import for saving file
import 'package:permission_handler/permission_handler.dart'; // Import for permissions

class MyCustomers extends StatefulWidget {
  const MyCustomers({super.key});

  @override
  State<MyCustomers> createState() => _MyCustomersState();
}

class _MyCustomersState extends State<MyCustomers> {
  // Function to export customer details to an Excel file
  Future<void> exportToExcel(List<Customers> customers) async {
    var excel = Excel.createExcel(); // Create a new Excel file
    Sheet sheetObject = excel['Customers']; // Create a sheet named 'Customers'

    // Add column headings
    sheetObject.appendRow(['Name', 'Phone Number', 'Address', 'Member Since']);

    // Log customers list to ensure data is being retrieved
    print('Number of customers: ${customers.length}');

    // Add customer data
    for (var customer in customers) {
      String formattedDate =
          DateFormat('yyyy-MM-dd HH:mm').format(customer.memberSince);

      // Append each customer's details as a new row
      sheetObject.appendRow([
        customer.name, // Customer name
        customer.number, // Customer phone number
        customer.address, // Customer address
        formattedDate // Member since (formatted as a string)
      ]);

      // Log each row to ensure data is being added
      print(
          'Added customer to Excel: ${customer.name}, ${customer.number}, ${customer.address}, $formattedDate');
    }

    // Save the Excel file in the Downloads folder
    try {
      if (await _requestStoragePermission()) {
        Directory? directory =
            Directory('/storage/emulated/0/Download'); // Downloads directory
        if (directory != null) {
          String filePath = "${directory.path}/customers.xlsx";

          // Ensure data is encoded correctly and saved
          var fileBytes = excel.encode();
          if (fileBytes != null) {
            File(filePath)
              ..createSync(
                  recursive: true) // Create the file if it doesn't exist
              ..writeAsBytesSync(fileBytes); // Write the Excel data to the file

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Customer data exported to $filePath")),
            );
          } else {
            print('Error: Excel encoding returned null.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error encoding Excel file")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Directory not found")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission denied to write file")),
        );
      }
    } catch (e) {
      print('Error exporting file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error exporting file: $e")),
      );
    }
  }

  // Function to handle permission requests based on Android version
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        return true;
      } else {
        return await Permission.storage.request().isGranted;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Customers"),
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
        actions: [
          // Add export button in the app bar
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Trigger export when pressed
              FirebaseFirestore.instance
                  .collection("customers")
                  .get()
                  .then((querySnapshot) {
                List<Customers> customers = querySnapshot.docs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  Timestamp createdAtTimestamp =
                      data['createdAt'] ?? Timestamp.now();
                  DateTime createdAt = createdAtTimestamp.toDate();
                  return Customers(
                    number: data['PhoneNo'] ?? '',
                    name: data['Name'] ?? '',
                    address: data['Address'] ?? '',
                    memberSince: createdAt,
                  );
                }).toList();

                // Ensure data is fetched correctly
                print('Fetched ${customers.length} customers from Firebase');
                exportToExcel(customers); // Call the export function
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("customers").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyDataWidget();
          }

          List<Customers> customers = _mapCustomersData(snapshot);

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) => _buildCustomerCard(customers[index], snapshot.data!.docs[index].id, context),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Error: $error', style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildEmptyDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text("No customers found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Add your first customer to get started", style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  List<Customers> _mapCustomersData(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Timestamp createdAtTimestamp = data['createdAt'] ?? Timestamp.now();
      DateTime createdAt = createdAtTimestamp.toDate();
      return Customers(
        number: data['PhoneNo'] ?? '',
        name: data['Name'] ?? '',
        address: data['Address'] ?? '',
        memberSince: createdAt,
      );
    }).toList();
  }

  Widget _buildCustomerCard(Customers customer, String customerId, BuildContext context) {
    String formattedDate = DateFormat('MMM d, yyyy').format(customer.memberSince);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CustomerDetails(customerId: customerId)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.number,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.address,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.blue.shade300),
                        const SizedBox(width: 4),
                        Text(
                          'Member since: $formattedDate',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade300),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class Customers {
  final String address;
  final String name;
  final DateTime memberSince;
  final String number;

  Customers({
    required this.address,
    required this.name,
    required this.memberSince,
    required this.number,
  });
}