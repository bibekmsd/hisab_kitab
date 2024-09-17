import 'dart:math' as math;
import 'package:flutter/material.dart';

class BanakoLoadingPage extends StatelessWidget {
  final String message;
  const BanakoLoadingPage({
    Key? key,
    this.message = 'Loading...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModernLoadingIndicator(),
            SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernLoadingIndicator extends StatefulWidget {
  @override
  _ModernLoadingIndicatorState createState() => _ModernLoadingIndicatorState();
}

class _ModernLoadingIndicatorState extends State<ModernLoadingIndicator>
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
        width: 80,
        height: 80,
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

    final gradientColors = [
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final startAngle = (i * math.pi / 3) - (math.pi / 2);
      final sweepAngle = math.pi / 4;

      paint.shader = SweepGradient(
        colors: [gradientColors[i], gradientColors[(i + 1) % 6]],
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
