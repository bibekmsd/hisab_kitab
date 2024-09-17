import 'package:flutter/material.dart';

class BanakoTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double fontSize;
  final Color textColor;
  final EdgeInsetsGeometry padding;

  const BanakoTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.fontSize,
    // this.fontSize = 14.0,
    required this.textColor,
    // this.textColor = Colors.blue,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding,
        // Text color
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, color: textColor),
      ),
    );
  }
}
