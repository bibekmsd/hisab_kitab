// import 'package:flutter/material.dart';
// import 'package:hisab_kitab/newUI/Drawers/drawer.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/Homepage.dart';
// import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/Navigation_bar.dart';

// class AdminUserScreen extends StatelessWidget {
//   final String userName;
//   final String shopName;
//   final String phoneNumber;
//   final String address;
//   final String panNo;
//   final String loginTime;
//   final String userRole; // Add userRole parameter

//   const AdminUserScreen({
//     super.key,
//     required this.userName,
//     required this.shopName,
//     required this.phoneNumber,
//     required this.address,
//     required this.panNo,
//     required this.loginTime,
//     required this.userRole, // Initialize userRole
//   });

//   @override
//   Widget build(BuildContext context) {
//     final TextTheme textTheme = Theme.of(context).textTheme;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Admin Page"),
//       ),
//       drawer: ReusableDrawer(
//         shopName: shopName,
//         userName: userName,
//         loginTime: loginTime,
//         phoneNumber: phoneNumber,
//         drawerItems: [
//           ListTile(
//             title: const Text('Home'),
//             onTap: () {
//               Navigator.pop(context);
//             },
//           ),
//           ListTile(
//             title: const Text('Settings'),
//             onTap: () {
//               Navigator.pop(context);
//             },
//           ),
//         ],
//         footerItems: [
//           ListTile(
//             title: const Text('Logout'),
//             onTap: () async {
//               await FirebaseAuth.instance.signOut();
//               Navigator.pushReplacementNamed(context, '/signIn');
//             },
//           ),
//         ],
//       ),
//       bottomNavigationBar:
//           NavigationBarBanako(userRole: userRole), // Pass userRole here
//     );
//   }
// }
