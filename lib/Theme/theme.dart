import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisab_kitab/utils/constants/appcolors.dart';

class AppTheme {
  static ThemeData primaryTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    textTheme: GoogleFonts.openSansTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      shadowColor: AppColors.secondaryColor,
      elevation: 1,
      centerTitle: false,
      titleTextStyle: GoogleFonts.openSans(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bottomNavBarColor,
      selectedItemColor: AppColors.selectedBNavItemColor,
      unselectedItemColor: AppColors.unselectedItemColor,
      elevation: 5, // Optional: Adjust elevation if needed
    ),
  );
}
