import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  Future<Map<String, dynamic>> _fetchAdminData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final doc = await FirebaseFirestore.instance
        .collection('admin')
        .doc("09099090")
        .get();

    if (!doc.exists) {
      throw Exception('Admin data not found');
    }

    return doc.data()!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchAdminData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Drawer(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return Drawer(
            child: Center(child: Text('No data found')),
          );
        }

        final data = snapshot.data!;
        final shopName = data['shopName'] ?? 'N/A';
        final panNo = data['panNo'] ?? 'N/A';
        final userName = data['userName'] ?? 'N/A';
        final phoneNumber = data['phoneNumber'] ?? 'N/A';
        final loginTime = data['loginTime'] ?? 'N/A';

        return Drawer(
          child: Column(
            children: <Widget>[
              // Header section with shop details
              Container(
                color: Colors.blue,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      shopName,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Address: Example Address', // Replace with actual address if available
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'PAN No: $panNo',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Login Time: $loginTime',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Role: Admin', // Replace with actual role if available
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Phone: $phoneNumber',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              // Spacer to push actions to the bottom
              Expanded(
                child: Container(),
              ),
              // Lower section with actions
              ListTile(
                title: const Text('Add User'),
                leading: const Icon(Icons.person_add),
                onTap: () {
                  Navigator.pushNamed(
                      context, '/addUser'); // Change to your route
                },
              ),
              ListTile(
                title: const Text('Logout'),
                leading: const Icon(Icons.logout),
                onTap: () async {
                  // Handle logout
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(
                      context, '/signIn'); // Change to your route
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
