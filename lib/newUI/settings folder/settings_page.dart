import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/settings%20folder/manage_staff.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false; // Track the light/dark mode
  bool notificationsEnabled = true; // Track notifications setting

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  isDarkMode = value;
                });
                // Add functionality to change app theme
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Forgot Password?'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Add forgot password functionality
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Enable Notifications'),
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  notificationsEnabled = value;
                });
                // Add notification toggle functionality
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Staff Accounts'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageStaffPage(), // Corrected
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Shop Information'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to shop information page
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About App'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to about app page
            },
          ),
        ],
      ),
    );
  }
}
