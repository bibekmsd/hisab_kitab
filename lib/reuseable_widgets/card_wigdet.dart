import 'package:flutter/material.dart';

class BanakoCardColumn extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  // final Color textColor;
  final Gradient backgroundGradient;
  final double radius;
  final IconData rakhneIcon;
  // final double width = 100;
  // final double height;

  const BanakoCardColumn({
    super.key,
    required this.text,
    // required this.textColor,
    required this.backgroundGradient,
    required this.radius,
    required this.rakhneIcon,
    // this.width,
    // required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Container(
          width: 100,
          height: 90,
          decoration: BoxDecoration(
            gradient: backgroundGradient,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                rakhneIcon,
                // color: textColor,
                size: 40,
              ),
              const SizedBox(height: 2.0),
              Text(
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.fade,
                text,
                style: const TextStyle(
                  // color: textColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
