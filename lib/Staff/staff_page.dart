// import 'package:flutter/material.dart';
// import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/Navigation_bar.dart';
// import 'package:hisab_kitab/newUI/Drawers/drawer.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class StaffUserScreen extends StatelessWidget {
//   final String userName;
//   final String shopName;
//   final String phoneNumber;
//   final String loginTime;
//   final String userRole; // Add role parameter

//   const StaffUserScreen({
//     super.key,
//     required this.userName,
//     required this.shopName,
//     required this.phoneNumber,
//     required this.loginTime,
//     required this.userRole, // Add role parameter
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Staff Page"),
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
//               // Handle logout
//               try {
//                 await FirebaseAuth.instance.signOut();
//                 Navigator.of(context).pushReplacementNamed('/signin');
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Error logging out: $e')),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       bottomNavigationBar:
//           NavigationBarBanako(userRole: userRole), // Pass role here
//     );
//   }
// }
