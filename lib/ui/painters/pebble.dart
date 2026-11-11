// رسّام الحصاة (§5.2 + لوحة التصميم): كرة لامعة مستديرة
// (كما في اللوحة: لمعة بيضاء أعلى اليسار وتظليل سفلي غامق)،
// مع ظل تلامس أسفلها. بلا عيون وبلا تفاصيل أخرى.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

class PebblePainter extends CustomPainter {
  final PebbleDef def;

  const PebblePainter({required this.def});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) / 2;
    final center = Offset(cx, cy);

    // ظل تلامس أسفل الحصاة.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.72),
        width: r * 1.5,
        height: r * 0.42,
      ),
      Paint()..color = const Color(0xFF000000).withValues(alpha: 0.28),
    );
    // الجسم: لون أساسي.
    canvas.drawCircle(center, r * 0.92, Paint()..color = def.base);
    // تفتيح علوي (كروية).
    canvas.drawCircle(
      center + Offset(-r * 0.18, -r * 0.22),
      r * 0.62,
      Paint()..color = def.light.withValues(alpha: 0.55),
    );
    // تظليل سفلي.
    final shade = Path()
      ..addOval(Rect.fromCircle(center: center, radius: r * 0.92));
    canvas.save();
    canvas.clipPath(shade);
    canvas.drawCircle(
      center + Offset(r * 0.15, r * 0.45),
      r * 0.7,
      Paint()..color = def.dark.withValues(alpha: 0.55),
    );
    canvas.restore();
    // لمعة بيضاء أعلى اليسار.
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-r * 0.34, -r * 0.42),
        width: r * 0.5,
        height: r * 0.3,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    // حافة خفيفة.
    canvas.drawCircle(
      center,
      r * 0.92,
      Paint()
        ..color = def.dark.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant PebblePainter oldDelegate) =>
      oldDelegate.def != def;
}
