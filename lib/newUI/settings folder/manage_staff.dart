import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/settings%20folder/staff_details_page.dart';

class ManageStaffPage extends StatefulWidget {
  const ManageStaffPage({super.key});

  @override
  State<ManageStaffPage> createState() => _ManageStaffPageState();
}

class _ManageStaffPageState extends State<ManageStaffPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchStaffData() async {
    try {
      final querySnapshot = await _db.collection('users').get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint("Error fetching staff data: $e");
      return [];
    }
  }

  Future<void> _deleteUser(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
      debugPrint("User deleted successfully");
      setState(() {}); // Refresh the list
    } catch (e) {
      debugPrint("Error deleting user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Staff'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchStaffData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final staffList = snapshot.data ?? [];

          return ListView.builder(
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return StaffCard(staff: staff, onDelete: _deleteUser);
            },
          );
        },
      ),
    );
  }
}

class StaffCard extends StatelessWidget {
  final Map<String, dynamic> staff;
  final Future<void> Function(String uid) onDelete;

  const StaffCard({required this.staff, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(staff['username'] ?? 'N/A'),
        subtitle: Text(staff['role'] ?? 'N/A'),
        leading:
            Icon(Icons.person, color: const Color.fromARGB(255, 103, 153, 240)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StaffDetailPage(staff: staff),
            ),
          );
        },
      ),
    );
  }
}
