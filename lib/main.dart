import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/homepage_body.dart';
import 'package:hisab_kitab/newUI/settings%20folder/settings_page.dart';
import 'package:hisab_kitab/pages/sign_in_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// Create a ValueNotifier to track theme mode (light or dark)
ValueNotifier<bool> isDarkMode = ValueNotifier(false);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "HisabKitab",
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              color: isDark ? Colors.black : Color.fromRGBO(18, 29, 45, 1),
              titleTextStyle: const TextStyle(
                fontSize: 24,
                color: Color.fromARGB(255, 155, 204, 50),
              ),
            ),
            textTheme: const TextTheme(
              titleSmall: TextStyle(fontSize: 16),
              titleLarge: TextStyle(fontSize: 32),
              titleMedium: TextStyle(fontSize: 20),
            ),
          ),
          home: const SignInPage(),
          // You can test other pages here
        );
      },
    );
  }
}
