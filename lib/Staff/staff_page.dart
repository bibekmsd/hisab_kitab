import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/Navigation_bar.dart';
import 'package:hisab_kitab/newUI/Drawers/drawer.dart';

class StaffUserScreen extends StatelessWidget {
  final String userName;
  final String shopName;
  final String phoneNumber;
  final String loginTime;

  const StaffUserScreen({
    Key? key,
    required this.userName,
    required this.shopName,
    required this.phoneNumber,
    required this.loginTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Page"),
      ),
      drawer: ReusableDrawer(
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
      bottomNavigationBar: NavigationBarBanako(),
    );
  }
}
