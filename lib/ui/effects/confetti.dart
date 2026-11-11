// قصاصات احتفالية (~80 جسيماً) تنهمر عند الفوز، تستمر 3 ثوانٍ.
import 'dart:math' as math;

import 'package:flutter/material.dart';

class Confetti extends StatefulWidget {
  final int count;
  final Duration duration;

  const Confetti({
    super.key,
    this.count = 80,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;

  static const _colors = [
    Color(0xFFD9A441),
    Color(0xFF146B8A),
    Color(0xFFC1442E),
    Color(0xFF1E7A4C),
    Color(0xFFF2C96B),
    Color(0xFFFFFBF2),
  ];

  @override
  void initState() {
    super.initState();
    final random = math.Random(DateTime.now().microsecondsSinceEpoch);
    _pieces = List.generate(widget.count, (_) {
      return _Piece(
        startX: random.nextDouble(),
        startY: -0.05 - random.nextDouble() * 0.15,
        size: 5 + random.nextDouble() * 7,
        color: _colors[random.nextInt(_colors.length)],
        fallSpeed: 0.55 + random.nextDouble() * 0.6,
        swayPhase: random.nextDouble() * math.pi * 2,
        swayAmount: 0.02 + random.nextDouble() * 0.04,
        rotationSpeed: (random.nextDouble() - 0.5) * 12,
        isCircle: random.nextBool(),
        delay: random.nextDouble() * 0.35,
      );
    });
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
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            pieces: _pieces,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Piece {
  final double startX, startY, size, fallSpeed, swayPhase, swayAmount;
  final double rotationSpeed, delay;
  final Color color;
  final bool isCircle;

  const _Piece({
    required this.startX,
    required this.startY,
    required this.size,
    required this.color,
    required this.fallSpeed,
    required this.swayPhase,
    required this.swayAmount,
    required this.rotationSpeed,
    required this.isCircle,
    required this.delay,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double progress;

  _ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final eased = Curves.easeInQuad.transform(t);
      final x = (p.startX + math.sin(t * math.pi * 2 + p.swayPhase) * p.swayAmount) *
          size.width;
      final y = p.startY * size.height + eased * p.fallSpeed * size.height * 1.4;
      if (y > size.height + 20) continue;
      final paint = Paint()
        ..color = p.color.withValues(alpha: (1 - t * 0.4).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotationSpeed * t);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
