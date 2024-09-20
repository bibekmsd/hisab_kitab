import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.onTap,
    required this.label,
    this.width,
    this.isLoading = false,
    super.key,
    this.isNegativeButton = false,
    this.foregroundColor,
    this.backgroundColor,
  });

  final VoidCallback onTap;
  final String label;
  final double? width;
  final bool isLoading;
  final bool isNegativeButton;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap, // Disable button when loading
      style: ButtonStyle(
        elevation: WidgetStateProperty.all<double>(isNegativeButton ? 0 : 2),
        minimumSize: WidgetStateProperty.all<Size>(
          Size(width ?? double.infinity, 45),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(
          isNegativeButton
              ? Colors.transparent
              : backgroundColor ?? Theme.of(context).primaryColor,
        ),
        foregroundColor: WidgetStateProperty.all<Color>(
          foregroundColor ?? Colors.black,
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isNegativeButton
                ? BorderSide(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    width: 2.0,
                  ) // Add border for negative button
                : BorderSide.none,
          ),
        ),
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ), // Custom text style for the button
                ),
              ),
      ),
    );
  }
}
