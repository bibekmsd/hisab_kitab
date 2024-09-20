import 'package:flutter/material.dart';
import 'package:hisab_kitab/reuseable_widgets/appbar_data.dart';
import 'package:hisab_kitab/utils/constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color titleColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: AppBar(
          backgroundColor: AppBarData.appBarColor,
          elevation: 0,
          title: Text(
            title,
            style: AppTextStyle.appBarHeader.copyWith(color: titleColor),
          ),
          actions: actions,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.shade300,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
