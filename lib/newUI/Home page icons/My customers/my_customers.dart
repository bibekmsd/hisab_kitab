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
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Data in database"));
          }

          // Map the documents to Customers objects
          List<Customers> customers = snapshot.data!.docs.map((doc) {
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

          // Display customers in a ListView
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              String formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                  .format(customers[index].memberSince);
              return Card(
                child: ListTile(
                  title: Text(customers[index].name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PhoneNo: ${customers[index].number}'),
                    ],
                  ),
                  leading: const Icon(
                    Icons.person,
                    size: 40,
                  ),
                  trailing: Column(
                    children: [
                      Text('Address: ${customers[index].address}'),
                      Text('Member Since: $formattedDate'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return CustomerDetails(
                            customerId: snapshot.data!.docs[index].id);
                      },
                    ));
                  },
                ),
              );
            },
          );
        },
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
