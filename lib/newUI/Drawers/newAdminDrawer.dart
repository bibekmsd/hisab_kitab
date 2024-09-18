import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hisab_kitab/newUI/Drawers/progress_indicator.dart';
import 'package:hisab_kitab/newUI/settings%20folder/manage_staff.dart';
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
          return Drawer(child: Center(child: BanakoLoadingPage()));
        } else if (snapshot.hasError) {
          return Drawer(child: Center(child: Text('Error: ${snapshot.error}')));
        }

        final data = snapshot.data ?? {};

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
                children: [
                  _buildHeader(data),
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
                            icon: HeroIcons.userGroup,
                            title: 'Manage Staff',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ManageStaffPage()),
                            ),
                          ),
                          _buildMenuItem(
                            icon: HeroIcons.userPlus,
                            title: 'Add User',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpPage()),
                            ),
                          ),
                          _buildMenuItem(
                            icon: HeroIcons.arrowRightOnRectangle,
                            title: 'Logout',
                            onTap: () => _handleLogout(context),
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

  Widget _buildHeader(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundImage: AssetImage('assets/admin_photo.png'),
          ),
          const SizedBox(height: 15),
          Text(
            data['shopName']?.toString() ?? 'Shop Name N/A',
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(
            data['username']?.toString() ?? 'Username N/A',
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 15),
          _buildInfoRow(
            data['phoneNo']?.toString() ?? 'Phone N/A',
            data['Address']?.toString() ?? 'Address N/A',
            data['panNo']?.toString() ?? 'PAN N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String phone, String address, String pan) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCompactInfoChip(HeroIcons.phone, phone),
            const SizedBox(width: 10),
            _buildCompactInfoChip(HeroIcons.buildingOffice, address),
          ],
        ),
        const SizedBox(height: 10),
        _buildCompactInfoChip(HeroIcons.identification, 'PAN: $pan'),
      ],
    );
  }

  Widget _buildCompactInfoChip(HeroIcons icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeroIcon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(HeroIcons icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeroIcon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      {required HeroIcons icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: HeroIcon(
        icon,
        style: HeroIconStyle.outline,
        color: const Color(0xFF9599E2),
      ),
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

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    AdminDataCache.instance.clearAdminData();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
      (Route<dynamic> route) => false,
    );
  }
}
