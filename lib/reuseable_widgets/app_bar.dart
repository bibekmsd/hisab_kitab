import 'package:flutter/material.dart';
import 'package:hisab_kitab/utils/constants/apptextstyles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final String title;
  final List<Widget> actions;
  final Color titleColor;

  const CustomAppBar({
    super.key,
    required this.backgroundColor,
    required this.title,
    required this.actions,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // backgroundColor: backgroundColor,
      title: Text(title, style: AppTextStyle.appBarHeader),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
