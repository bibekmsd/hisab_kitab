import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hisab_kitab/reuseable_widgets/app_bar.dart';
import 'package:hisab_kitab/reuseable_widgets/appbar_data.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> lowStockProducts = [];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    checkLowStockProducts();
  }

  // Initialize local notifications
  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            'app_icon'); // App icon in drawable folder

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Function to show low stock notification
  Future<void> showLowStockNotification(String productName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'low_stock_channel', // Channel ID
      'Low Stock Notifications', // Channel Name
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Low Stock Alert', // Title
      'Product "$productName" is running low on stock!', // Body
      platformChannelSpecifics,
    );
  }

  // Function to check low stock products
  Future<void> checkLowStockProducts() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('ProductsNew').get();

    List<Map<String, dynamic>> tempLowStockProducts = [];

    for (var doc in querySnapshot.docs) {
      var productData = doc.data() as Map<String, dynamic>;
      if (productData['Quantity'] != null && productData['Quantity'] < 10) {
        tempLowStockProducts.add(productData);

        // Trigger notification for each low-stock product
        showLowStockNotification(productData['Name'] ?? 'Unknown Product');
      }
    }

    if (tempLowStockProducts.isNotEmpty) {
      setState(() {
        lowStockProducts = tempLowStockProducts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Low Stock Notification'),
      // ),
      appBar: CustomAppBar(
        // backgroundColor: AppBarData.appBarColor,
        title: "Notifications", // Localized title

        titleColor: AppBarData.titleColor,
      ),
      body: lowStockProducts.isEmpty
          ? const Center(child: Text('No low stock products at the moment.'))
          : ListView.builder(
              itemCount: lowStockProducts.length,
              itemBuilder: (context, index) {
                var product = lowStockProducts[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  child: ListTile(
                    title: Text(product['Name'] ?? 'Unknown Product'),
                    subtitle: Text('Only ${product['Quantity']} items left.'),
                    trailing: Text('Barcode: ${product['Barcode']}'),
                  ),
                );
              },
            ),
    );
  }
}
