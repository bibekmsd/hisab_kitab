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
  // Define your color palette
  static const lightBlue = Color(0xFF7EB6FF);
  static const purple = Color(0xFF9599E2);
  static const veryLightBlue = Color(0xFFF0F4FF);
  static const darkNavy = Color(0xFF0C1E3C);

  // Create gradient colors
  static const primaryGradient = LinearGradient(
    colors: [lightBlue, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light theme
  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightBlue,
    scaffoldBackgroundColor: veryLightBlue,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      iconTheme: IconThemeData(color: darkNavy),
      backgroundColor: lightBlue,
      titleTextStyle: TextStyle(
        fontSize: 24,
        color: darkNavy,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      titleSmall: TextStyle(fontSize: 16, color: darkNavy),
      titleMedium: TextStyle(fontSize: 20, color: darkNavy),
      titleLarge: TextStyle(fontSize: 32, color: darkNavy),
      bodyMedium: TextStyle(color: darkNavy),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: darkNavy,
        backgroundColor: lightBlue,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: lightBlue,
      secondary: purple,
      surface: veryLightBlue,
      background: veryLightBlue,
    ),
  );

  // Dark theme
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkNavy,
    scaffoldBackgroundColor: darkNavy,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      iconTheme: IconThemeData(color: veryLightBlue),
      backgroundColor: darkNavy,
      titleTextStyle: TextStyle(
        fontSize: 24,
        color: lightBlue,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      titleSmall: TextStyle(fontSize: 16, color: veryLightBlue),
      titleMedium: TextStyle(fontSize: 20, color: veryLightBlue),
      titleLarge: TextStyle(fontSize: 32, color: veryLightBlue),
      bodyMedium: TextStyle(color: veryLightBlue),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: veryLightBlue,
        backgroundColor: purple,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: purple,
      secondary: lightBlue,
      surface: darkNavy,
      background: darkNavy,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "HisabKitab",
          theme: isDark ? darkTheme : lightTheme,
          home: HomePage(userRole: "admin", username: "bibek_msd"),
        );
      },
    );
  }
}

// Custom gradient background widget
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _MyAppState.primaryGradient,
      ),
      child: child,
    );
  }
}
