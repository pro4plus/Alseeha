// رسّام الصحن الطيني (§5.2 + تعديل المستخدم الثاني):
// صحن طين، وفيه حتى 7 حصوات بلون الحجارة الموجودة فيه فعلاً
// (حجر اللاعب في صحن «باقي»، وحجر الخصم في صحن «أكلت»).
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

class BowlPainter extends CustomPainter {
  final PebbleDef pebble;
  final int count;

  const BowlPainter({required this.pebble, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    // جسم الصحن: نصف قطع ناقص.
    final body = Path()
      ..moveTo(cx - w * 0.48, h * 0.34)
      ..quadraticBezierTo(cx - w * 0.42, h * 0.95, cx, h * 0.98)
      ..quadraticBezierTo(cx + w * 0.42, h * 0.95, cx + w * 0.48, h * 0.34)
      ..close();
    canvas.drawPath(body, Paint()..color = SudaneseTheme.clayBowl);
    // تظليل سفلي.
    canvas.drawPath(
      Path()
        ..moveTo(cx - w * 0.40, h * 0.72)
        ..quadraticBezierTo(cx - w * 0.34, h * 0.94, cx, h * 0.96)
        ..quadraticBezierTo(cx + w * 0.34, h * 0.94, cx + w * 0.40, h * 0.72)
        ..close(),
      Paint()..color = SudaneseTheme.clayBowlDark.withValues(alpha: 0.6),
    );
    // فتحة الصحن (داخل غامق).
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, h * 0.34), width: w * 0.96, height: h * 0.30),
      Paint()..color = const Color(0xFF3A2418),
    );
    // الحصوات داخل الفتحة (حتى 7) بلون حجر صاحب الصحن.
    final n = count.clamp(0, 7);
    if (n > 0) {
      final pr = w * 0.115;
      final span = w * 0.62;
      final y0 = h * 0.30;
      for (var i = 0; i < n; i++) {
        final t = n == 1 ? 0.5 : i / (n - 1);
        final x = cx - span / 2 + t * span;
        final y = y0 - math.sin(t * math.pi) * h * 0.05;
        // حصاة صغيرة لامعة.
        canvas.drawCircle(Offset(x, y), pr, Paint()..color = pebble.base);
        canvas.drawCircle(
          Offset(x - pr * 0.3, y - pr * 0.35),
          pr * 0.45,
          Paint()..color = pebble.light.withValues(alpha: 0.7),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x - pr * 0.3, y - pr * 0.45),
            width: pr * 0.5,
            height: pr * 0.3,
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.85),
        );
      }
    }
    // حافة الصحن الأمامية (تغطي أسفل الحصوات).
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cx, h * 0.34), width: w * 0.96, height: h * 0.30),
      0,
      math.pi,
      false,
      Paint()
        ..color = SudaneseTheme.clayBowl
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant BowlPainter oldDelegate) =>
      oldDelegate.pebble != pebble || oldDelegate.count != count;
}
