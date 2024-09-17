import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hisab_kitab/pages/sign_in_page.dart';
import 'package:intl/intl.dart';

class StaffDrawer extends StatelessWidget {
  Future<Map<String, dynamic>?> _fetchStaffData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not logged in');
      return null;
    }

    final cachedData = StaffDataCache().staffData;
    if (cachedData != null) {
      print('Returning cached data: $cachedData');
      return cachedData;
    }

    print('Fetching data from Firestore');
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      print('User document not found');
      return null;
    }

    final username = userDoc.data()?['username'];
    if (username == null) {
      print('Username not found for the user');
      return null;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print('Staff data not found');
      return null;
    }

    final doc = querySnapshot.docs.first;
    final staffData = doc.data();

    StaffDataCache().setStaffData(staffData);

    return staffData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchStaffData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Drawer(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final data = snapshot.data ??
            {
              'username': 'N/A',
              'address': 'N/A',
              'createdAt': 'N/A',
              'email': 'N/A',
              'lastLogin': 'N/A',
              'phoneNumber': 'N/A',
              'role': 'N/A',
              'shopName': 'N/A',
            };

        final username = data['username'] ?? 'N/A';
        final address = data['address'] ?? 'N/A';
        final createdAt = data['createdAt'] is Timestamp
            ? DateFormat('yyyy-MM-dd HH:mm')
                .format((data['createdAt'] as Timestamp).toDate())
            : 'N/A';

        final email = data['email'] ?? 'N/A';
        final lastLogin = data['lastLogin'] ?? 'N/A';
        final phoneNumber = data['phoneNumber'] ?? 'N/A';
        final role = data['role'] ?? 'N/A';
        final shopName = data['shopName'] ?? 'N/A';

        return Drawer(
          width: 250,
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.blue,
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        'Staff Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/staff_photo.png'),
                    ),
                    SizedBox(height: 10.0), // Reduced space
                    Text(
                      shopName,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6.0),
                    Text(
                      'Username: $username',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'Address: $address',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'Role: $role',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'Phone No: \n$phoneNumber',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'Email: $email',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'Log Time: $lastLogin',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Divider(),
              ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout'),
                  onTap: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      print('User signed out');

                      // Clear the cached data
                      StaffDataCache().setStaffData(null);

                      // Optionally delete the user document
                      await deleteUserDocument();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                        (Route<dynamic> route) => false,
                      );
                      print('Navigated to SignInPage');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error during sign-out: $e')),
                      );
                    }
                  }),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'App Version 1.0.0',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      '© The ChatGPT guys',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '2024',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// staff_data_cache.dart
class StaffDataCache {
  static final StaffDataCache _instance = StaffDataCache._internal();
  factory StaffDataCache() => _instance;
  StaffDataCache._internal();

  Map<String, dynamic>? _staffData;

  Map<String, dynamic>? get staffData => _staffData;

  void setStaffData(Map<String, dynamic>? data) {
    _staffData = data;
  }
}

Future<void> deleteUserDocument() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('No user is logged in');
    return;
  }

  try {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
    print('User document deleted successfully');
  } catch (e) {
    print('Error deleting user document: $e');
  }
}
