import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';

class PebblePainter extends CustomPainter {
  final PebbleDef def;
  const PebblePainter({required this.def});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = math.min(size.width, size.height) / 2;
    final center = Offset(cx, cy);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * .72), width: r * 1.55, height: r * .42), Paint()..color = Colors.black.withValues(alpha: .32));

    final pebble = Path();
    const points = 12;
    final radii = [0.88, .96, .91, .98, .90, .94, .87, .96, .91, .98, .89, .95];
    for (var i = 0; i < points; i++) {
      final a = -math.pi / 2 + i * math.pi * 2 / points;
      final rr = r * radii[i];
      final p = center + Offset(math.cos(a) * rr * (i.isEven ? 1.0 : .94), math.sin(a) * rr);
      if (i == 0) pebble.moveTo(p.dx, p.dy); else pebble.lineTo(p.dx, p.dy);
    }
    pebble.close();
    canvas.drawPath(pebble, Paint()..color = def.base);
    canvas.save();
    canvas.clipPath(pebble);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(-r * .24, -r * .28), width: r * 1.15, height: r * .95), Paint()..color = def.light.withValues(alpha: .52));
    canvas.drawOval(Rect.fromCenter(center: center + Offset(r * .22, r * .48), width: r * 1.2, height: r * .62), Paint()..color = def.dark.withValues(alpha: .58));
    canvas.restore();
    canvas.drawPath(pebble, Paint()..color = def.dark.withValues(alpha: .65)..style = PaintingStyle.stroke..strokeWidth = 1.25);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(-r * .28, -r * .43), width: r * .42, height: r * .21), Paint()..color = Colors.white.withValues(alpha: .86));
    canvas.drawCircle(center + Offset(-r * .1, -r * .12), r * .07, Paint()..color = Colors.white.withValues(alpha: .38));
  }

  @override
  bool shouldRepaint(covariant PebblePainter oldDelegate) => oldDelegate.def != def;
}
