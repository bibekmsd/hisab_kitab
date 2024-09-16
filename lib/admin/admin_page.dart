import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Drawers/drawer.dart';

class AdminUserScreen extends StatelessWidget {
  final String userName;
  final String shopName;
  final String phoneNumber;
  final String loginTime;

  const AdminUserScreen({
    super.key,
    required this.userName,
    required this.shopName,
    required this.phoneNumber,
    required this.loginTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Page"),
      ),
      drawer: ReusableDrawer(
        // height: 300,
        shopName: shopName,
        userName: userName,
        loginTime: loginTime,
        phoneNumber: phoneNumber,
        drawerItems: [
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
        footerItems: [
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome Admin"),
      ),
    );
  }
}
