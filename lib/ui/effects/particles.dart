// جزيئات صغيرة تطير من الخانات المأكولة (نقاط بلون حجر الضحية).
import 'dart:math' as math;

import 'package:flutter/material.dart';

class ParticleBurst extends StatefulWidget {
  final Offset origin;
  final double size;
  final Color color;
  final int count;

  const ParticleBurst({
    super.key,
    required this.origin,
    required this.size,
    required this.color,
    this.count = 8,
  });

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<({double angle, double distance, double radius})> _parts;

  @override
  void initState() {
    super.initState();
    final random = math.Random(widget.origin.dx.hashCode ^
        widget.origin.dy.hashCode ^ DateTime.now().microsecondsSinceEpoch);
    _parts = List.generate(widget.count, (_) {
      final angle = random.nextDouble() * math.pi * 2;
      return (
        angle: angle,
        distance: widget.size * (0.7 + random.nextDouble() * 0.8),
        radius: 2.5 + random.nextDouble() * 3.5,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
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
          painter: _ParticlePainter(
            origin: widget.origin,
            parts: _parts,
            progress: t,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final Offset origin;
  final List<({double angle, double distance, double radius})> parts;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.origin,
    required this.parts,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 1 - progress);
    for (final p in parts) {
      final d = p.distance * progress;
      final pos = Offset(
        origin.dx + d * math.cos(p.angle),
        origin.dy + d * math.sin(p.angle),
      );
      canvas.drawCircle(pos, p.radius * (1 - progress * 0.6), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
