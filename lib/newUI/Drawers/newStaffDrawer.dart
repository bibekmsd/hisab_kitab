import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StaffDrawer extends StatelessWidget {
  final String userName;
  final String address;
  final String phoneNumber;
  final String loginTime;

  const StaffDrawer({
    Key? key,
    required this.userName,
    required this.address,
    required this.phoneNumber,
    required this.loginTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(phoneNumber),
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
          ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              // Handle logout
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/signIn');
            },
          ),
        ],
      ),
    );
  }
}
