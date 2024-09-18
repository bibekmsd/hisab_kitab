import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShopInfoPage extends StatefulWidget {
  const ShopInfoPage({super.key});

  @override
  _ShopInfoPageState createState() => _ShopInfoPageState();
}

class _ShopInfoPageState extends State<ShopInfoPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Map<String, dynamic>? shopData;

  @override
  void initState() {
    super.initState();
    _fetchShopInfo();
  }

  Future<void> _fetchShopInfo() async {
    try {
      DocumentSnapshot adminSnapshot =
          await _db.collection('admin').doc('09099090').get();
      setState(() {
        shopData = adminSnapshot.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      debugPrint("Error fetching shop info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Information'),
      ),
      body: shopData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderWithIcon(), // Add a large icon in the header
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      icon: Icons.store,
                      title: shopData!['shopName'] ?? 'N/A',
                      subtitle: 'Shop Name',
                    ),
                    _buildInfoCard(
                      icon: Icons.location_on,
                      title: shopData!['Address'] ?? 'N/A',
                      subtitle: 'Address',
                    ),
                    _buildInfoCard(
                      icon: Icons.phone,
                      title: shopData!['phoneNo'] ?? 'N/A',
                      subtitle: 'Phone Number',
                    ),
                    _buildInfoCard(
                      icon: Icons.confirmation_number,
                      title: shopData!['panNo'] ?? 'N/A',
                      subtitle: 'PAN No.',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Create a header with a large shop icon
  Widget _buildHeaderWithIcon() {
    return const Column(
      children: [
        Icon(
          Icons.store_mall_directory,
          size: 100,
        ),
        SizedBox(height: 10),
        Text(
          "Shop Details",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              child: Icon(icon),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    // color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
