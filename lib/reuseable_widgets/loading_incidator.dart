import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double size; // Size of the indicator
  final Color color; // Color of the indicator
  final bool isCircular; // To toggle between circular and linear indicator

  const LoadingIndicator({
    Key? key,
    this.size = 50.0, // Default size
    this.color = Colors.blueAccent, // Default color
    this.isCircular = true, // Default to circular indicator
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isCircular
          ? SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 5.0,
              ),
            )
          : LinearProgressIndicator(
              color: color,
              minHeight: size / 10, // Adjust size for linear indicator
            ),
    );
  }
}
