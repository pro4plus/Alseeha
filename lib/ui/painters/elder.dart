// شخصيات الحوش السوداني: رسومات متجهة تفصيلية، بملامح وملابس وحياكة واضحة.
import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ElderKind { young, teacher, elder }

class ElderPainter extends CustomPainter {
  final ElderKind kind;
  final double tilt;
  final double bow;

  const ElderPainter({required this.kind, this.tilt = 0, this.bow = 0});

  static const _skin = Color(0xFF8C5733);
  static const _skinLight = Color(0xFFB8794D);
  static const _skinDark = Color(0xFF4B2A1D);
  static const _robe = Color(0xFFFFF8E8);
  static const _robeShade = Color(0xFFD8C49D);
  static const _cloth = Color(0xFFF7F0DF);
  static const _clothShade = Color(0xFFB9A889);
  static const _red = Color(0xFFB3261E);
  static const _turquoise = Color(0xFF1AA3A8);
  static const _gold = Color(0xFFF2C14E);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 100, size.height / 130);
    canvas.save();
    canvas.translate((size.width - 100 * scale) / 2, (size.height - 130 * scale) / 2);
    canvas.scale(scale, scale);

    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.24);
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 127), width: 88, height: 10), shadow);

    // خلفية المقعد والكتف، حتى لا تبدو الشخصية كأيقونة عائمة.
    final back = Path()
      ..moveTo(18, 125)
      ..quadraticBezierTo(15, 82, 27, 65)
      ..quadraticBezierTo(50, 54, 73, 65)
      ..quadraticBezierTo(86, 83, 82, 125)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFFE7D7B5));

    // الجلابية مع كتفين وثنيات وطرز على الصدر.
    final robe = Path()
      ..moveTo(50, 57)
      ..quadraticBezierTo(22, 62, 12, 91)
      ..lineTo(9, 128)
      ..lineTo(91, 128)
      ..lineTo(88, 91)
      ..quadraticBezierTo(78, 62, 50, 57)
      ..close();
    canvas.drawPath(robe, Paint()..color = _robe);
    final fold = Paint()
      ..color = _robeShade
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (final line in [
      const [Offset(31, 72), Offset(27, 126)],
      const [Offset(42, 68), Offset(40, 127)],
      const [Offset(58, 68), Offset(60, 127)],
      const [Offset(69, 72), Offset(73, 126)],
    ]) {
      canvas.drawLine(line[0], line[1], fold);
    }
    final trim = Paint()..color = _turquoise..strokeWidth = 1.8..style = PaintingStyle.stroke;
    canvas.drawPath(Path()..moveTo(42, 59)..lineTo(50, 70)..lineTo(58, 59), trim);
    canvas.drawLine(const Offset(50, 71), const Offset(50, 93), trim);
    for (var x = 44.0; x <= 56; x += 4) {
      canvas.drawCircle(Offset(x, 78), 1.1, Paint()..color = _red);
    }

    canvas.save();
    canvas.translate(50, 58);
    canvas.rotate(tilt + bow * 0.30);
    canvas.translate(-50, -58);

    // الرقبة والوجه مع ظل جانبي.
    canvas.drawRect(const Rect.fromLTWH(43, 49, 14, 15), Paint()..color = _skinDark);
    canvas.drawCircle(const Offset(50, 37), 20.5, Paint()..color = _skin);
    canvas.drawArc(Rect.fromCircle(center: const Offset(47, 34), radius: 16), math.pi, math.pi * 0.8, false,
        Paint()..color = _skinLight.withValues(alpha: 0.45)..style = PaintingStyle.stroke..strokeWidth = 4);

    _paintFace(canvas);
    switch (kind) {
      case ElderKind.young:
        _paintMoustache(canvas);
        _paintCap(canvas);
        break;
      case ElderKind.teacher:
        _paintMoustache(canvas);
        _paintImma(canvas, large: false);
        _paintGlasses(canvas);
        break;
      case ElderKind.elder:
        _paintBeard(canvas);
        _paintImma(canvas, large: true);
        break;
    }
    canvas.restore();
    canvas.restore();
  }

  void _paintFace(Canvas canvas) {
    final eye = Paint()..color = _skinDark;
    canvas.drawOval(Rect.fromCenter(center: const Offset(42, 38), width: 4.5, height: 2.2), eye);
    canvas.drawOval(Rect.fromCenter(center: const Offset(58, 38), width: 4.5, height: 2.2), eye);
    canvas.drawCircle(const Offset(42, 38), 0.8, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(58, 38), 0.8, Paint()..color = Colors.white);
    final nose = Paint()..color = _skinDark..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(50, 39)..quadraticBezierTo(47, 46, 51, 46), nose);
    canvas.drawArc(Rect.fromCenter(center: const Offset(50, 49), width: 10, height: 5), 0.15, math.pi - 0.3, false,
        Paint()..color = _skinDark..style = PaintingStyle.stroke..strokeWidth = 1.4);
  }

  void _paintBeard(Canvas canvas) {
    final beard = Path()
      ..moveTo(31, 44)
      ..quadraticBezierTo(30, 67, 50, 75)
      ..quadraticBezierTo(70, 67, 69, 44)
      ..quadraticBezierTo(59, 52, 50, 52)
      ..quadraticBezierTo(41, 52, 31, 44)
      ..close();
    canvas.drawPath(beard, Paint()..color = Colors.white);
    canvas.drawPath(beard, Paint()..color = _clothShade..style = PaintingStyle.stroke..strokeWidth = 1.6);
    for (var x = 38.0; x <= 62; x += 6) {
      canvas.drawLine(Offset(x, 55), Offset(x + (x - 50) * 0.12, 68), Paint()..color = _clothShade..strokeWidth = 1.1);
    }
  }

  void _paintMoustache(Canvas canvas) {
    final p = Paint()..color = _skinDark..style = PaintingStyle.stroke..strokeWidth = 2.7..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: const Offset(45, 49), width: 10, height: 7), math.pi * 1.05, math.pi * 0.8, false, p);
    canvas.drawArc(Rect.fromCenter(center: const Offset(55, 49), width: 10, height: 7), math.pi * 1.15, math.pi * 0.8, false, p);
  }

  void _paintImma(Canvas canvas, {required bool large}) {
    final top = large ? 5.0 : 9.0;
    final half = large ? 30.0 : 26.0;
    final dome = Path()
      ..moveTo(50 - half, 35)
      ..quadraticBezierTo(50 - half - 2, top + 7, 50, top)
      ..quadraticBezierTo(50 + half + 2, top + 7, 50 + half, 35)
      ..quadraticBezierTo(50, 30, 50 - half, 35)
      ..close();
    canvas.drawPath(dome, Paint()..color = _cloth);
    final wrap = Paint()..color = _clothShade..style = PaintingStyle.stroke..strokeWidth = 1.6;
    for (var i = 0; i < 3; i++) {
      canvas.drawArc(Rect.fromCenter(center: Offset(50, top + 9 + i * 6), width: half * 1.65, height: 15), math.pi * 1.08, math.pi * 0.83, false, wrap);
    }
    canvas.drawLine(Offset(50 - half + 3, 28), Offset(50 + half - 3, 28), Paint()..color = _turquoise..strokeWidth = 3);
    canvas.drawCircle(Offset(50 + half - 2, 30), 4, Paint()..color = _cloth);
  }

  void _paintCap(Canvas canvas) {
    final cap = Path()
      ..moveTo(32, 32)
      ..quadraticBezierTo(32, 14, 50, 14)
      ..quadraticBezierTo(68, 14, 68, 32)
      ..close();
    canvas.drawPath(cap, Paint()..color = _cloth);
    canvas.drawRect(const Rect.fromLTWH(32, 29, 36, 4), Paint()..color = _red);
    final stitch = Paint()..color = _turquoise..strokeWidth = 1.2;
    for (var x = 37.0; x <= 63; x += 6) canvas.drawLine(Offset(x, 18), Offset(x, 26), stitch);
    canvas.drawCircle(const Offset(50, 20), 2, Paint()..color = _gold);
  }

  void _paintGlasses(Canvas canvas) {
    final frame = Paint()..color = _skinDark..strokeWidth = 2.2..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(40, 38), 7.7, frame);
    canvas.drawCircle(const Offset(60, 38), 7.7, frame);
    canvas.drawLine(const Offset(47.7, 38), const Offset(52.3, 38), frame);
    canvas.drawLine(const Offset(32.3, 38), const Offset(29, 35), frame);
    canvas.drawLine(const Offset(67.7, 38), const Offset(71, 35), frame);
  }

  @override
  bool shouldRepaint(covariant ElderPainter oldDelegate) => oldDelegate.kind != kind || oldDelegate.tilt != tilt || oldDelegate.bow != bow;
}
