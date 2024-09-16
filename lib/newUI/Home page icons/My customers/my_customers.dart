import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20customers/customer_details.dart';
import 'package:intl/intl.dart';

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
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
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