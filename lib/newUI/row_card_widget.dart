import 'package:flutter/material.dart';

class BanakoCardRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color textColor;
  final Gradient backgroundGradient;
  final double radius;
  final IconData rakhneIcon;
  final double width;
  final double height;
  final VoidCallback onTap;
  const BanakoCardRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.backgroundGradient,
    required this.radius,
    required this.rakhneIcon,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: backgroundGradient,
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    rakhneIcon,
                    color: textColor,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
