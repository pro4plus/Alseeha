// رسّام الشخصيات (§5.2 + لوحة التصميم + تعديل المستخدم):
// ثلاث شخصيات جالسة بجلابية بيضاء، بلا عيون إطلاقاً
// (لا نقاط عيون ولا رمش). إمالة الرأس أثناء تفكير الكمبيوتر،
// إيماءة عند الاختيار، وانحناءة عند الفوز.
// ود البلد: طاقية بيضاء بشريط أحمر + شارب.
// الأستاذ: عمامة + نظارات دائرية فارغة (بلا عيون خلفها) + شارب.
// الشيخ: عمامة كبيرة + لحية بيضاء.
import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ElderKind { young, teacher, elder }

class ElderPainter extends CustomPainter {
  final ElderKind kind;

  /// إمالة الرأس بالراديان (أثناء تفكير الكمبيوتر).
  final double tilt;

  /// انحناءة 0..1 (عند الفوز).
  final double bow;

  const ElderPainter({
    required this.kind,
    this.tilt = 0,
    this.bow = 0,
  });

  static const _skin = Color(0xFF7A4A28);
  static const _skinDark = Color(0xFF5E3820);
  static const _robe = Color(0xFFFBF6E8);
  static const _robeShade = Color(0xFFE0D3B0);
  static const _cloth = Color(0xFFF5F1E6);
  static const _clothShade = Color(0xFFD8CDB2);

  @override
  void paint(Canvas canvas, Size size) {
    // فضاء تصميم 100×130 يُقاس إلى حجم الصندوق.
    final s = math.min(size.width / 100, size.height / 130);
    canvas.save();
    canvas.translate(
      (size.width - 100 * s) / 2,
      (size.height - 130 * s) / 2,
    );
    canvas.scale(s, s);

    // ظل أرضي.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 126), width: 84, height: 9),
      Paint()..color = const Color(0xFF000000).withValues(alpha: 0.18),
    );

    // ---- الجلابية ----
    final robe = Path()
      ..moveTo(50, 58)
      ..quadraticBezierTo(18, 64, 12, 92)
      ..lineTo(10, 128)
      ..lineTo(90, 128)
      ..lineTo(88, 92)
      ..quadraticBezierTo(82, 64, 50, 58)
      ..close();
    canvas.drawPath(robe, Paint()..color = _robe);
    // ثنيات الجلابية.
    final fold = Paint()
      ..color = _robeShade
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(50, 66), const Offset(50, 126), fold);
    canvas.drawLine(const Offset(34, 78), const Offset(30, 126), fold);
    canvas.drawLine(const Offset(66, 78), const Offset(70, 126), fold);
    // ياقة على شكل V.
    canvas.drawPath(
      Path()
        ..moveTo(42, 58)
        ..lineTo(50, 70)
        ..lineTo(58, 58),
      Paint()
        ..color = _robeShade
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // ---- مجموعة الرأس (تميل وتنحني) ----
    canvas.save();
    canvas.translate(50, 58);
    canvas.rotate(tilt + bow * 0.30);
    canvas.translate(-50, -58);

    // الوجه.
    canvas.drawCircle(
        const Offset(50, 38), 20, Paint()..color = _skin);
    // تظليل سفلي للوجه.
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(50, 38), radius: 20),
      math.pi * 0.2,
      math.pi * 0.6,
      false,
      Paint()
        ..color = _skinDark.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    switch (kind) {
      case ElderKind.elder:
        _paintBeard(canvas);
        _paintImma(canvas, large: true);
        break;
      case ElderKind.teacher:
        _paintMoustache(canvas);
        _paintImma(canvas, large: false);
        _paintGlasses(canvas);
        break;
      case ElderKind.young:
        _paintMoustache(canvas);
        _paintCap(canvas);
        break;
    }
    canvas.restore();
    canvas.restore();
  }

  /// لحية بيضاء للشيخ — بيضاء صافية مع حافة ظاهرة حتى تُقرأ
  /// ككتلة مستقلة تحت الذقن ولا تذوب في الجلابية (لونها قريب
  /// جداً من لون القماش، فكانت اللحية تختفي).
  void _paintBeard(Canvas canvas) {
    final beard = Path()
      ..moveTo(30, 44)
      ..quadraticBezierTo(29, 68, 50, 74)
      ..quadraticBezierTo(71, 68, 70, 44)
      ..quadraticBezierTo(60, 52, 50, 52)
      ..quadraticBezierTo(40, 52, 30, 44)
      ..close();
    canvas.drawPath(beard, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawPath(
      beard,
      Paint()
        ..color = _clothShade
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    final shade = Paint()
      ..color = _clothShade
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(42, 56), const Offset(42, 66), shade);
    canvas.drawLine(const Offset(58, 56), const Offset(58, 66), shade);
  }

  /// شارب صغير (ود البلد والأستاذ).
  void _paintMoustache(Canvas canvas) {
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(50, 50), width: 18, height: 8),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      Paint()
        ..color = _skinDark
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  /// عمامة بيضاء (كبيرة للشيخ، متوسطة للأستاذ).
  void _paintImma(Canvas canvas, {required bool large}) {
    final top = large ? 6.0 : 10.0;
    final halfW = large ? 29.0 : 26.0;
    final dome = Path()
      ..moveTo(50 - halfW, 36)
      ..quadraticBezierTo(50 - halfW - 2, top + 6, 50, top)
      ..quadraticBezierTo(50 + halfW + 2, top + 6, 50 + halfW, 36)
      ..quadraticBezierTo(50, 30, 50 - halfW, 36)
      ..close();
    canvas.drawPath(dome, Paint()..color = _cloth);
    // خطوط اللف.
    final wrap = Paint()
      ..color = _clothShade
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(50, top + 10), width: halfW * 1.7, height: 16),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      wrap,
    );
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(50, top + 18), width: halfW * 1.8, height: 14),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      wrap,
    );
    // عقدة جانبية صغيرة.
    canvas.drawCircle(
        Offset(50 + halfW - 2, 30), 4, Paint()..color = _cloth);
  }

  /// طاقية بيضاء بشريط أحمر (ود البلد).
  void _paintCap(Canvas canvas) {
    final cap = Path()
      ..moveTo(32, 32)
      ..quadraticBezierTo(32, 14, 50, 14)
      ..quadraticBezierTo(68, 14, 68, 32)
      ..lineTo(32, 32)
      ..close();
    canvas.drawPath(cap, Paint()..color = _cloth);
    // شريط أحمر أسفل الطاقية.
    canvas.drawRect(
      const Rect.fromLTWH(32, 29, 36, 4),
      Paint()..color = const Color(0xFFB3261E),
    );
    // غرز.
    final stitch = Paint()
      ..color = _clothShade
      ..strokeWidth = 1.2;
    for (var x = 38.0; x <= 62; x += 6) {
      canvas.drawLine(Offset(x, 18), Offset(x, 26), stitch);
    }
  }

  /// نظارات دائرية فارغة (الأستاذ) — إطاران بلا عيون خلفهما.
  void _paintGlasses(Canvas canvas) {
    final frame = Paint()
      ..color = const Color(0xFF2B1A12)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(40, 38), 7.5, frame);
    canvas.drawCircle(const Offset(60, 38), 7.5, frame);
    canvas.drawLine(const Offset(47.5, 38), const Offset(52.5, 38), frame);
    canvas.drawLine(const Offset(32.5, 38), const Offset(29, 34), frame);
    canvas.drawLine(const Offset(67.5, 38), const Offset(71, 34), frame);
  }

  @override
  bool shouldRepaint(covariant ElderPainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.tilt != tilt ||
      oldDelegate.bow != bow;
}
