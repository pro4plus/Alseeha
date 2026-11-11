// موجة صدمة دائرية تتسع وتتلاشى حول خانة مأكولة.
import 'package:flutter/material.dart';

class Shockwave extends StatefulWidget {
  final Offset origin;
  final double maxRadius;
  final Color color;
  final Duration duration;

  const Shockwave({
    super.key,
    required this.origin,
    required this.maxRadius,
    this.color = const Color(0xFFD9A441),
    this.duration = const Duration(milliseconds: 420),
  });

  @override
  State<Shockwave> createState() => _ShockwaveState();
}

class _ShockwaveState extends State<Shockwave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
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
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_controller.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _ShockwavePainter(
            origin: widget.origin,
            radius: widget.maxRadius * t,
            alpha: (1 - t) * 0.85,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _ShockwavePainter extends CustomPainter {
  final Offset origin;
  final double radius;
  final double alpha;
  final Color color;

  _ShockwavePainter({
    required this.origin,
    required this.radius,
    required this.alpha,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0) return;
    final paint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(origin, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _ShockwavePainter oldDelegate) =>
      oldDelegate.radius != radius;
}
