// // ignore_for_file: prefer_const_constructors

// import 'package:flutter/material.dart';
// import 'package:hisab_kitab/newUI/drawer.dart';
// import 'package:hisab_kitab/pages/log_in_page.dart';
// import 'package:hisab_kitab/pages/sign_up_page.dart';

// class StaffDrawer extends StatelessWidget {
//   const StaffDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ReusableDrawer(
//       shopName: 'Bibek Kirana',
//       userName: 'Bibek Gautam',
//       loginTime: '10:00 AM',
//       phoneNumber: '9843026009',
//       drawerItems: [
//         ListTile(
//           title: const Text('My Stock'),
//           onTap: () {},
//         ),
//         ListTile(
//           title: const Text('My Customers'),
//           onTap: () {},
//         ),
//       ],
//       footerItems: [
//         Divider(
//           height: 0,
//         ),
//         ListTile(
//             leading: Icon(Icons.logout_outlined),
//             title: Text('Log Out'),
//             onTap: () {
//               Navigator.pop(context);
//             }),
//         Divider(
//           height: 0,
//         ),
//         Divider(
//           height: 0,
//         ),
//         ListTile(
//           leading: Icon(Icons.delete_forever_outlined),
//           title: Text('Delete Staff'),
//           onTap: () {},
//         ),
//       ],
//     );
//   }
// }
