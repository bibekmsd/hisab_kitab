import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hisab_kitab/newUI/Drawers/progress_indicator.dart';
import 'package:hisab_kitab/newUI/settings%20folder/manage_staff.dart';
import 'package:hisab_kitab/pages/sign_in_page.dart';
import 'package:hisab_kitab/pages/sign_up_page.dart';
import 'package:hisab_kitab/reuseable_widgets/loading_incidator.dart';

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
  final String email;
  final String panNo; // Use this as the document ID

  const AdminDrawer({super.key, required this.email, required this.panNo});

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

    try {
      // Use panNo as the document ID
      final doc = await FirebaseFirestore.instance
          .collection('admin')
          .doc(panNo) // Use panNo as the document ID
          .get();

      if (!doc.exists) {
        throw Exception('Admin data not found');
      }

      // Cache the fetched data
      AdminDataCache.instance.setAdminData(doc.data()!);

      return doc.data();
    } catch (e) {
      print("Error fetching admin data: $e");
      throw Exception("Failed to fetch admin data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchAdminData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Drawer(child: Center(child: LoadingIndicator()));
        } else if (snapshot.hasError) {
          // Log the error to see the actual cause
          print('Error fetching admin data: ${snapshot.error}');
          return Drawer(
            child: Center(
              child: Text(
                'Failed to load admin data.\nError: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = snapshot.data ?? {};

        return Drawer(
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(data),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildMenuItem(
                        icon: HeroIcons.userGroup,
                        title: 'Manage Staff',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ManageStaffPage()),
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
                _buildFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Map<String, dynamic> data) {
    return SafeArea(
      child: Container(
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
                  backgroundImage: AssetImage('assets/admin_photo.png'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['shopName']?.toString() ?? 'Shop Name N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['username']?.toString() ?? 'Username N/A',
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
            _buildInfoChip(
                HeroIcons.phone, data['phoneNo']?.toString() ?? 'Phone N/A'),
            const SizedBox(height: 8),
            _buildInfoChip(HeroIcons.buildingOffice,
                data['Address']?.toString() ?? 'Address N/A'),
            const SizedBox(height: 8),
            _buildInfoChip(HeroIcons.identification,
                'PAN: ${data['panNo']?.toString() ?? 'N/A'}'),
          ],
        ),
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
    required HeroIcons icon,
    required String title,
    required VoidCallback onTap,
  }) {
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
          Text('App Version 1.0.0', style: TextStyle(color: Colors.black54)),
          SizedBox(height: 5),
          Text('© The Last Minute Guys',
              style: TextStyle(color: Colors.black54)),
          Text('2024', style: TextStyle(color: Colors.black54)),
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
