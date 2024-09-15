// // ignore_for_file: prefer_const_constructors

// import 'package:flutter/material.dart';
// import 'package:hisab_kitab/newUI/drawer.dart';
// import 'package:hisab_kitab/pages/log_in_page.dart';
// import 'package:hisab_kitab/pages/sign_up_page.dart';

// class AdminDrawer extends StatelessWidget {
//   const AdminDrawer({Key? key}) : super(key: key);

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
//         ListTile(
//           title: const Text('Add Staffs'),
//           onTap: () {},
//         ),
//       ],
//       footerItems: [
//         Divider(
//           height: 0,
//         ),
//         ListTile(
//           leading: Icon(Icons.logout_outlined),
//           title: Text('Log Out'),
//           onTap: () {
//             // Navigator.push(
//             //   context,
//             //   MaterialPageRoute(
//             //     builder: (context) {
//             //       return LoggedOutPage();
//             //     },
//             //   ),
//             // );
//           },
//         ),
//         Divider(
//           height: 0,
//         ),
//         ListTile(
//           leading: Icon(Icons.login),
//           title: Text('Login'),
//           onTap: () {
//             Navigator.push(context, MaterialPageRoute(
//               builder: (context) {
//                 return SignInPage();
//               },
//             ));
//           },
//         ),
//         Divider(
//           height: 0,
//         ),
//         ListTile(
//           leading: Icon(Icons.app_registration),
//           title: Text('Signup'),
//           onTap: () {
//             Navigator.push(context, MaterialPageRoute(
//               builder: (context) {
//                 return SignUpPage();
//               },
//             ));
//           },
//         ),
//       ],
//     );
//   }
// }
