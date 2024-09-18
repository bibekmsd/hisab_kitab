import 'dart:math' as math;
import 'package:flutter/material.dart';

class BanakoLoadingPage extends StatefulWidget {
  const BanakoLoadingPage({super.key});

  @override
  _BanakoLoadingPageState createState() => _BanakoLoadingPageState();
}

class _BanakoLoadingPageState extends State<BanakoLoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        );
      },
      child: Container(
        width: 60,
        height: 60,
        child: CustomPaint(
          painter: _ModernLoadingPainter(),
        ),
      ),
    );
  }
}

class _ModernLoadingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Main circle
    paint.color = Colors.white.withOpacity(0.2);
    canvas.drawCircle(center, radius, paint);

    // Animated arc
    paint.color = Colors.white;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      paint,
    );

    // Center dot
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
