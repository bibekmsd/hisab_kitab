import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StaffDetailPage extends StatefulWidget {
  final Map<String, dynamic> staff;
  final Future<void> Function(String username) onDelete;

  const StaffDetailPage({required this.staff, required this.onDelete, Key? key})
      : super(key: key);

  @override
  _StaffDetailPageState createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends State<StaffDetailPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.staff['address'] ?? '';
    _phoneNumberController.text = widget.staff['phoneNumber'] ?? '';
    _emailController.text = widget.staff['email'] ?? '';
    _shopNameController.text = widget.staff['shopName'] ?? '';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _animation.value)),
                  child: Opacity(
                    opacity: _animation.value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildEditableFields(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      elevation: 12,
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        titlePadding: EdgeInsets.only(bottom: 16),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green.shade100, Colors.green.shade400],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 78,
                    backgroundImage: AssetImage('assets/staff_photo.png'),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  widget.staff['username'] ?? 'Staff Member',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final createdAt = widget.staff['createdAt'] is Timestamp
        ? DateFormat('yyyy-MM-dd HH:mm')
            .format((widget.staff['createdAt'] as Timestamp).toDate())
        : 'N/A';
    final lastLogin = widget.staff['lastLogin'] ?? 'N/A';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.calendar_today, 'Created At', createdAt),
            const Divider(),
            _buildInfoRow(Icons.access_time, 'Last Login', lastLogin),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text(value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableFields() {
    return Column(
      children: [
        _buildEditableField(Icons.location_on, 'Address', _addressController),
        _buildEditableField(
            Icons.phone, 'Phone Number', _phoneNumberController),
        _buildEditableField(Icons.email, 'Email', _emailController),
        _buildEditableField(Icons.store, 'Shop Name', _shopNameController),
      ],
    );
  }

  Widget _buildEditableField(
      IconData icon, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _updateUserDetails,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _showDeleteConfirmationDialog,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Remove User',
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateUserDetails() async {
    final uid = widget.staff['uid'];
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: User ID is null')),
      );
      return;
    }

    final userDoc =
        _db.collection('users').doc(uid); // Use UID instead of username

    try {
      await userDoc.update({
        'address': _addressController.text,
        'phoneNumber': _phoneNumberController.text,
        'email': _emailController.text,
        'shopName': _shopNameController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User details updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user details: $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteUser();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteUser() async {
    final uid = widget.staff['uid'] ?? '';
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid user ID')),
      );
      return;
    }

    try {
      await widget.onDelete(uid); // Pass the UID to the deletion function
      Navigator.pop(context); // Close the page after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }
}
