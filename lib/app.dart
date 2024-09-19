// app.dart
import 'package:flutter/material.dart';
import 'package:hisab_kitab/splash_screen.dart';
import 'package:hisab_kitab/Theme/theme.dart';

// Define the ValueNotifier globally so it can be accessed across the app
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
          title: "HisabKitaab",
          theme: AppTheme.primaryTheme,
          // theme: isDark ? darkTheme : lightTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}
