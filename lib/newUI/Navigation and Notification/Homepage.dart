import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:hisab_kitab/newUI/Drawers/newAdminDrawer.dart';
import 'package:hisab_kitab/newUI/Drawers/newStaffDrawer.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/homepage_body.dart';

class HomePage extends StatefulWidget {
  final String userRole;
  final String username; // Add username parameter

  const HomePage({Key? key, required this.userRole, required this.username})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> adminData = {};
  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("Sign in bhayo Homepage ma as : ${widget.userRole}");
    _getUserData();
  }

  // Fetch the user's data based on their role
  Future<void> _getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("No user logged in");
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (widget.userRole == 'admin') {
        // Fetch admin-specific data
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('admin')
            .doc("09099090")
            .get();

        if (adminDoc.exists) {
          setState(() {
            adminData = adminDoc.data() as Map<String, dynamic>;
          });
        }
      } else if (widget.userRole == 'staff') {
        // Fetch staff-specific data
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hamro Bazaar"),
      ),
      body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              // Show loading indicator while fetching data
              : const HomepageBody() // Replace with your page content
          ),
      drawer: isLoading
          ? null
          : widget.userRole == 'admin'
              ? AdminDrawer()
              : widget.userRole == 'staff'
                  ? StaffDrawer(
                      userName: widget.username, // Pass username here
                      address: userData['address'] ?? 'Not Found',
                      phoneNumber: userData['phoneNumber'] ?? 'Not Found',
                      loginTime: userData['lastLogin'] ?? 'Not Found',
                    )
                  : null,
    );
  }
}
