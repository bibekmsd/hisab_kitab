import 'package:flutter/material.dart';
import 'package:hisab_kitab/utils/constants/appcolors.dart';


class AppTextStyle {
  static const TextStyle header = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle appBarHeader = TextStyle(
    fontSize: 18,
    // color: AppColors.appBarTitleColor,
    color: Colors.white,
    // color: AppColors.secondaryColor,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subHeader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle body = TextStyle(
      fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.greyColor);
  static const TextStyle bodyBlack = TextStyle(
      fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.blackColor);

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static TextStyle customStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
