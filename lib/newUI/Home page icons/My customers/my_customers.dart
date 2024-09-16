import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20customers/customer_details.dart';
import 'package:intl/intl.dart';
// Import intl package for date formatting

class MyCustomers extends StatefulWidget {
  const MyCustomers({super.key});

  @override
  State<MyCustomers> createState() => _MyCustomersState();
}

class _MyCustomersState extends State<MyCustomers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Customers"),
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
