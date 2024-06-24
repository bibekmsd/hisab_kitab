import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
              color: Color.fromRGBO(81, 152, 255, 1),
              titleTextStyle: TextStyle(
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            textTheme: const TextTheme(
                titleSmall: TextStyle(fontSize: 16),
                titleLarge: TextStyle(fontSize: 32),
                titleMedium: TextStyle(fontSize: 20))),
        home: const SignInPage());
  }
}
