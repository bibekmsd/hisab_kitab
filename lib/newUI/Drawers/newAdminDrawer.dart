import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Drawers/progress_indicator.dart';
import 'package:hisab_kitab/pages/sign_in_page.dart';
import 'package:hisab_kitab/pages/sign_up_page.dart';

// Singleton class to cache admin data
class AdminDataCache {
  static final AdminDataCache _instance = AdminDataCache._internal();
  Map<String, dynamic>? _adminData;

  AdminDataCache._internal();

  static AdminDataCache get instance => _instance;

  Map<String, dynamic>? get adminData => _adminData;

  void setAdminData(Map<String, dynamic> data) {
    _adminData = data;
  }

  void clearAdminData() {
    _adminData = null;
  }
}

class AdminDrawer extends StatelessWidget {
  // Fetch Admin Data (either from cache or Firestore)
  Future<Map<String, dynamic>?> _fetchAdminData() async {
    // Check if data is already cached
    if (AdminDataCache.instance.adminData != null) {
      return AdminDataCache.instance.adminData;
    }

    // Fetch from Firestore if not cached
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null; // User not logged in
    }

    final doc = await FirebaseFirestore.instance
        .collection('admin')
        .doc("09099090") // Change to dynamic if needed
        .get();

    if (!doc.exists) {
      throw Exception('Admin data not found');
    }

    // Cache the fetched data
    AdminDataCache.instance.setAdminData(doc.data()!);

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchAdminData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Drawer(
            child: Center(child: BanakoLoadingPage()),
          );
        } else if (snapshot.hasError) {
          return Drawer(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        // Dummy values if not logged in
        final data = snapshot.data ??
            {'shopName': 'N/A', 'panNo': 'N/A', 'address': 'N/A'};

        final shopName = data['shopName'] ?? 'N/A';
        final panNo = data['panNo'] ?? 'N/A';
        final address = data['Address'] ?? 'N/A';
        final phoneNo = data['phoneNo'] ?? 'N/A';
        final username = data['username'] ?? 'N/A';

        return Drawer(
          width: 250,
          child: Column(
            children: <Widget>[
              // Header section with drawer icon
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
                        'Admin Dashboard',
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
              // Spacer to push content down

              // Header section with shop details
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
                      backgroundImage: AssetImage(
                          'assets/admin_photo.png'), // Admin profile photo
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      shopName,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Address: $address',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Phone No: $phoneNo',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'PAN No: $panNo',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Role: Admin',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'User Name: $username',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Divider(),
              // Actions section
              ListTile(
                leading: Icon(Icons.person_add, color: Colors.blue),
                title: Text('Add User'),
                onTap: () {
                  // Navigate to NabhetekoProductPage when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout'),
                onTap: () async {
                  // Handle logout
                  await FirebaseAuth.instance.signOut();

                  // Clear cached admin data on logout
                  AdminDataCache.instance.clearAdminData();

                  // Navigate to SignInPage after logout
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                    (Route<dynamic> route) =>
                        false, // Removes all previous routes
                  );
                },
              ),
              Divider(),
              // Footer section
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
                    SizedBox(height: 4.0), // Adds space between the lines
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
