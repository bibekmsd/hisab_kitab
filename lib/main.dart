import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Analytics/analytics_page.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/homepage_body.dart';
import 'package:hisab_kitab/newUI/settings%20folder/settings_page.dart';
import 'package:hisab_kitab/pages/sign_in_page.dart';
import 'package:hisab_kitab/utils/theme_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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

  // Dark theme
  // Light theme
  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightBlue,
    scaffoldBackgroundColor: veryLightBlue,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      iconTheme: IconThemeData(color: lightTextColor),
      backgroundColor: lightBlue,
      titleTextStyle: TextStyle(
        fontSize: 24,
        color: lightTextColor,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      titleSmall: TextStyle(fontSize: 16, color: lightTextColor),
      titleMedium: TextStyle(fontSize: 20, color: lightTextColor),
      titleLarge: TextStyle(fontSize: 32, color: lightTextColor),
      bodyMedium: TextStyle(color: lightTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: lightTextColor,
        backgroundColor: lightBlue,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: lightBlue,
      secondary: purple,
      surface: veryLightBlue,
    ),
  );

// Dark theme
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkNavy,
    scaffoldBackgroundColor: darkNavy,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      iconTheme: IconThemeData(color: darkTextColor),
      backgroundColor: darkNavy,
      titleTextStyle: TextStyle(
        fontSize: 24,
        color: lightBlue,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      titleSmall: TextStyle(fontSize: 16, color: darkTextColor),
      titleMedium: TextStyle(fontSize: 20, color: darkTextColor),
      titleLarge: TextStyle(fontSize: 32, color: darkTextColor),
      bodyMedium: TextStyle(color: darkTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: darkTextColor,
        backgroundColor: purple,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: purple,
      secondary: lightBlue,
      surface: darkNavy,
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
          //
          //home: const SplashScreen(),
          home: const AnalyticsPage(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _navigateToHome();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignInPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: _MyAppState.primaryGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'HisabKitab',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: _MyAppState.primaryGradient,
      ),
      child: child,
    );
  }
}
