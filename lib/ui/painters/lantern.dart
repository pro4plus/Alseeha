// رسّام الفانوس (§5.2 + لوحة التصميم): فانوس صغير بمقبض
// وغطاء وجسم زجاجي وقاعدة. مضيء: هالة دافئة وزجاج ذهبي.
// مطفأ: زجاج غامق بلا هالة.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

class LanternPainter extends CustomPainter {
  final bool lit;

  const LanternPainter({required this.lit});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    if (lit) {
      // هالة دافئة: حلقات متحدة المركز خافتة.
      for (final (r, a) in [
        (0.48, 0.10),
        (0.38, 0.14),
        (0.28, 0.20),
      ]) {
        canvas.drawCircle(
          Offset(cx, h * 0.5),
          w * r,
          Paint()..color = SudaneseTheme.sunGold.withValues(alpha: a),
        );
      }
    }
    // مقبض.
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cx, h * 0.14), width: w * 0.4, height: h * 0.22),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = SudaneseTheme.earthBlack
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
    // غطاء.
    canvas.drawPath(
      Path()
        ..moveTo(cx - w * 0.22, h * 0.24)
        ..lineTo(cx + w * 0.22, h * 0.24)
        ..lineTo(cx + w * 0.12, h * 0.14)
        ..lineTo(cx - w * 0.12, h * 0.14)
        ..close(),
      Paint()..color = SudaneseTheme.earthBlack,
    );
    // جسم زجاجي (سداسي مبسط).
    final glass = Path()
      ..moveTo(cx - w * 0.30, h * 0.30)
      ..lineTo(cx + w * 0.30, h * 0.30)
      ..lineTo(cx + w * 0.36, h * 0.62)
      ..lineTo(cx + w * 0.28, h * 0.80)
      ..lineTo(cx - w * 0.28, h * 0.80)
      ..lineTo(cx - w * 0.36, h * 0.62)
      ..close();
    canvas.drawPath(
      glass,
      Paint()
        ..color = lit
            ? SudaneseTheme.sunGold
            : const Color(0xFF3A3230),
    );
    if (lit) {
      canvas.drawCircle(
        Offset(cx, h * 0.55),
        w * 0.12,
        Paint()..color = const Color(0xFFFFE9A8),
      );
    }
    // قضبان الجسم.
    final bar = Paint()
      ..color = SudaneseTheme.earthBlack
      ..strokeWidth = 2;
    for (final dx in [-0.12, 0.0, 0.12]) {
      canvas.drawLine(
        Offset(cx + w * dx, h * 0.30),
        Offset(cx + w * dx * 0.85, h * 0.80),
        bar,
      );
    }
    // قاعدة.
    canvas.drawRect(
      Rect.fromLTWH(cx - w * 0.30, h * 0.80, w * 0.60, h * 0.08),
      Paint()..color = SudaneseTheme.earthBlack,
    );
    // شعلة صغيرة فوق الغطاء عند الإضاءة.
    if (lit) {
      canvas.drawCircle(
        Offset(cx, h * 0.10),
        2.5,
        Paint()..color = SudaneseTheme.sunGold,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LanternPainter oldDelegate) =>
      oldDelegate.lit != lit;
}
