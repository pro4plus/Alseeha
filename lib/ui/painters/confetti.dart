// قصاصات النصر (§6.5 + لوحة التصميم): ~80 مثلثاً
// (أحمر/ذهبي/أخضر/فيروزي) تسقط فوق اللوحة 3 ثوانٍ.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

class ConfettiPiece {
  final double x; // 0..1 عبر العرض
  final double delay; // 0..1 تأخير البدء
  final double speed; // سرعة السقوط
  final double size;
  final double spin;
  final Color color;

  const ConfettiPiece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.spin,
    required this.color,
  });
}

class ConfettiPainter extends CustomPainter {
  final double progress; // 0..1 خلال 3 ثوانٍ
  final List<ConfettiPiece> pieces;

  ConfettiPainter({required this.progress, required this.pieces});

  static List<ConfettiPiece> generate({int count = 80, int seed = 11}) {
    final rng = math.Random(seed);
    const colors = [
      SudaneseTheme.tabaqRed,
      SudaneseTheme.sunGold,
      SudaneseTheme.palmGreen,
      SudaneseTheme.turquoise,
    ];
    return List.generate(count, (_) {
      return ConfettiPiece(
        x: rng.nextDouble(),
        delay: rng.nextDouble() * 0.35,
        speed: 0.7 + rng.nextDouble() * 0.6,
        size: 7 + rng.nextDouble() * 9,
        spin: (rng.nextDouble() - 0.5) * 12,
        color: colors[rng.nextInt(colors.length)],
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final t = ((progress - p.delay) * p.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final x = p.x * size.width + math.sin(t * 9 + p.x * 20) * 14;
      final y = -20 + t * (size.height + 40);
      final alpha = t > 0.85 ? (1 - t) / 0.15 : 1.0;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * t);
      final path = Path()
        ..moveTo(0, -p.size / 2)
        ..lineTo(p.size / 2, p.size / 2)
        ..lineTo(-p.size / 2, p.size / 2)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = p.color.withValues(alpha: alpha.clamp(0.0, 1.0)),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// طبقة قصاصات فوق اللوحة (3 ثوانٍ، ثم تختفي).
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    _pieces = ConfettiPainter.generate();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ConfettiPainter(
              progress: _controller.value,
              pieces: _pieces,
            ),
          );
        },
      ),
    );
  }
}
