import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/homepage_body.dart';
import 'package:hisab_kitab/newUI/settings%20folder/settings_page.dart';
import 'package:hisab_kitab/pages/sign_in_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HisabKitab",
      theme: ThemeData(
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            color: Color.fromRGBO(18, 29, 45, 1),
            titleTextStyle: TextStyle(
              fontSize: 24,
              color: Color.fromARGB(255, 155, 204, 50),
            ),
          ),
          textTheme: const TextTheme(
              titleSmall: TextStyle(fontSize: 16),
              titleLarge: TextStyle(fontSize: 32),
              titleMedium: TextStyle(fontSize: 20))),
      home: const SignInPage(),
      // home: const AdminUserScreen(),
      // home: const StaffUserScreen(),
      // home: NabhetekoProductPage(),
      //home :const TransactionsPage(),
    );
  }
}
//^ 4987176014955
//^ 6928001826358
//^ 8904106854005
//* 8901247574328 //florozon
