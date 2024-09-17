import 'package:flutter/material.dart';

class BanakoButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final int textSize;
  const BanakoButton({
    super.key,
    required this.text,
    required this.textSize,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: textSize.toDouble()),
        ),
      ),
    );
  }
}
