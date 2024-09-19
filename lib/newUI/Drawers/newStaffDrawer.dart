import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:hisab_kitab/pages/sign_in_page.dart';

class StaffDrawer extends StatelessWidget {
  const StaffDrawer({super.key});

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
          return const Drawer(
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
        final lastLogin = data['lastLogin'] is Timestamp
            ? DateFormat('yyyy-MM-dd HH:mm')
                .format((data['lastLogin'] as Timestamp).toDate())
            : data['lastLogin'] is String
                ? DateFormat('yyyy-MM-dd HH:mm')
                    .format(DateTime.parse(data['lastLogin']))
                : 'N/A';

        final phoneNumber = data['phoneNumber'] ?? 'N/A';
        final role = data['role'] ?? 'N/A';
        final shopName = data['shopName'] ?? 'N/A';

        return Drawer(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF7EB6FF), Color(0xFF9599E2)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  _buildHeader(
                    shopName: shopName,
                    username: username,
                    address: address,
                    role: role,
                    phoneNumber: phoneNumber,
                    email: email,
                    lastLogin: lastLogin,
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildMenuItem(
                            icon: Icons.logout,
                            title: 'Logout',
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              StaffDataCache().setStaffData(null);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignInPage()),
                                (Route<dynamic> route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader({
    required String shopName,
    required String username,
    required String address,
    required String role,
    required String phoneNumber,
    required String email,
    required String lastLogin,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/drawer_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/staff_photo.png'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shopName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoChip(Icons.person, username),
          const SizedBox(height: 8),
          _buildInfoChip(Icons.phone, phoneNumber),
          const SizedBox(height: 8),
          _buildInfoChip(Icons.home, address),
          const SizedBox(height: 8),
          _buildInfoChip(Icons.work, role),
          const SizedBox(height: 8),
          _buildInfoChip(Icons.email, email),
          const SizedBox(height: 8),
          _buildInfoChip(Icons.access_time, 'Last Login: $lastLogin'),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF9599E2)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0C1E3C),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: const Column(
        children: [
          Text('App Version 1.0.0', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 5),
          Text('© The Last Minute Guys',
              style: TextStyle(color: Colors.white70)),
          Text('2024', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class StaffDataCache {
  static final StaffDataCache _instance = StaffDataCache._internal();

  Map<String, dynamic>? _staffData;

  factory StaffDataCache() {
    return _instance;
  }

  StaffDataCache._internal();

  Map<String, dynamic>? get staffData => _staffData;

  void setStaffData(Map<String, dynamic>? data) {
    _staffData = data;
  }
}
