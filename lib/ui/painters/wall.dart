// رسّام جدار الحوش (§5.2 + لوحة التصميم):
// جدار مبيّض، قاعدة طوب لبن، باب مقوّس بإطار فيروزي وإفريز
// أحمر متقطع، وبداخله مشهد غروب (سماء بنفسجي→برتقالي، شمس طبق،
// أهرامات مروي، النيل، نخلة تتمايل)، و6 أطباق في الحائط.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';
import 'tabaq.dart';

class WallPainter extends CustomPainter {
  /// ارتفاع الشمس داخل الباب 0..1 (0 = عند الأفق، 1 = أعلى الباب).
  final double sunT;

  /// تمايل النخلة بالراديان.
  final double palmSway;

  /// مقياس ظهور كل طبق من الأطباق الستة 0..1 (لظهور متدرج في البداية).
  final List<double> plates;

  /// توهج الباب (للبداية).
  final double glow;

  /// أعلى الباب كنسبة من ارتفاع الجدار: يجب أن يكون تحت منطقة
  /// العنوان (الرئيسية والبداية تضعان العنوان فوق الجدار).
  final double doorTopFraction;

  /// ارتفاع الباب كنسبة من ارتفاع الجدار.
  final double doorHeightFraction;

  const WallPainter({
    this.sunT = 1.0,
    this.palmSway = 0.0,
    this.plates = const [1, 1, 1, 1, 1, 1],
    this.glow = 0.0,
    this.doorTopFraction = 0.06,
    this.doorHeightFraction = 0.82,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ---- الجدار المبيّض ----
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = SudaneseTheme.whitewash,
    );
    // بقع جص خافتة.
    final smudge = Paint()
      ..color = SudaneseTheme.sandDark.withValues(alpha: 0.10);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.2, size.height * 0.25),
            width: 90,
            height: 46),
        smudge);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.85, size.height * 0.6),
            width: 70,
            height: 34),
        smudge);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.5, size.height * 0.08),
            width: 120,
            height: 30),
        smudge);

    // ---- الباب المقوّس ----
    final doorW = size.width * 0.56;
    final doorH = size.height * doorHeightFraction;
    final doorLeft = (size.width - doorW) / 2;
    final doorTop = size.height * doorTopFraction;
    final archR = doorW / 2;
    final doorRect = Rect.fromLTWH(doorLeft, doorTop, doorW, doorH);
    final archPath = Path()
      ..moveTo(doorRect.left, doorRect.bottom)
      ..lineTo(doorRect.left, doorRect.top + archR)
      ..arcTo(
        Rect.fromCircle(
            center: Offset(doorRect.center.dx, doorRect.top + archR),
            radius: archR),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(doorRect.right, doorRect.bottom)
      ..close();

    // الإطار الفيروزي.
    canvas.drawPath(archPath, Paint()..color = SudaneseTheme.turquoise);
    // الإفريز الأحمر المتقطع على الإطار.
    _paintFrieze(canvas, doorRect, archR);

    // ---- مشهد الغروب داخل الباب ----
    const frame = 13.0;
    final innerRect = Rect.fromLTWH(
      doorRect.left + frame,
      doorRect.top + frame,
      doorRect.width - frame * 2,
      doorRect.height - frame,
    );
    final innerArch = Path()
      ..moveTo(innerRect.left, innerRect.bottom)
      ..lineTo(innerRect.left, innerRect.top + archR - frame)
      ..arcTo(
        Rect.fromCircle(
            center:
                Offset(innerRect.center.dx, innerRect.top + archR - frame),
            radius: archR - frame),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(innerRect.right, innerRect.bottom)
      ..close();
    canvas.save();
    canvas.clipPath(innerArch);
    _paintDusk(canvas, innerRect, sunT);
    canvas.restore();

    // توهج الباب (للبداية).
    if (glow > 0) {
      canvas.save();
      canvas.clipPath(archPath);
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = SudaneseTheme.sunGold.withValues(alpha: 0.25 * glow),
      );
      canvas.restore();
    }

    // ---- الأطباق الستة في الحائط (3 يمين و3 يسار) ----
    final plateSpots = <(double, double, double)>[
      (0.10, 0.22, 0.085), // يسار كبير
      (0.90, 0.22, 0.085), // يمين كبير
      (0.13, 0.48, 0.065), // يسار وسط
      (0.87, 0.48, 0.065), // يمين وسط
      (0.09, 0.72, 0.05), // يسار صغير
      (0.91, 0.72, 0.05), // يمين صغير
    ];
    for (var i = 0; i < 6; i++) {
      final s = plates[i.clamp(0, plates.length - 1)];
      if (s <= 0) continue;
      final (fx, fy, fr) = plateSpots[i];
      final center = Offset(size.width * fx, size.height * fy);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(s);
      canvas.translate(-center.dx, -center.dy);
      paintTabaq(
        canvas,
        Rect.fromCircle(center: center, radius: size.width * fr),
      );
      canvas.restore();
    }

    // ---- قاعدة الطوب اللبن أسفل الجدار ----
    final plinthH = size.height * 0.07;
    final plinth = Rect.fromLTWH(
        0, size.height - plinthH, size.width, plinthH);
    canvas.drawRect(
        plinth, Paint()..color = SudaneseTheme.mudBrick);
    final brickPaint = Paint()
      ..color = SudaneseTheme.mudBrickDark
      ..strokeWidth = 1.5;
    for (var y = plinth.top + plinthH / 2; y < size.height; y += plinthH / 2) {
      canvas.drawLine(
          Offset(0, y), Offset(size.width, y), brickPaint);
    }
    for (var x = 0.0; x < size.width; x += 34) {
      final off = ((x / 34) % 2 == 0) ? 0.0 : 17.0;
      canvas.drawLine(Offset(x + off, plinth.top),
          Offset(x + off, size.height), brickPaint);
    }
  }

  /// إفريز أحمر: مربعات صغيرة على طول الإطار المقوّس.
  void _paintFrieze(Canvas canvas, Rect doorRect, double archR) {
    final paint = Paint()..color = SudaneseTheme.tabaqRed;
    const sq = 7.0;
    // الجانبان العموديان.
    for (var y = doorRect.top + archR + 10;
        y < doorRect.bottom - 8;
        y += 22) {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(doorRect.left + 7, y), width: sq, height: sq),
          paint);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(doorRect.right - 7, y), width: sq, height: sq),
          paint);
    }
    // القوس العلوي.
    final cx = doorRect.center.dx;
    final cy = doorRect.top + archR;
    for (var a = math.pi; a <= 2 * math.pi; a += 0.22) {
      final x = cx + (archR - 7) * math.cos(a);
      final y = cy + (archR - 7) * math.sin(a);
      canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: sq, height: sq),
          paint);
    }
  }

  /// مشهد الغروب: سماء (بنفسجي→كركدي→برتقالي)، شمس طبق،
  /// أهرامات، النيل، نخلة.
  void _paintDusk(Canvas canvas, Rect rect, double sunT) {
    // سماء الغروب من شرائط لونية مسطحة: شكل مطبوع باليد لا غشاوة رقمية.
    final sky = Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * 0.62);
    const bands = [
      Color(0xFF252552),
      Color(0xFF343063),
      Color(0xFF512C6B),
      Color(0xFF762C68),
      Color(0xFFA63A55),
      Color(0xFFD45D35),
      Color(0xFFE58A1F),
    ];
    final bandH = sky.height / bands.length;
    for (var i = 0; i < bands.length; i++) {
      canvas.drawRect(Rect.fromLTWH(sky.left, sky.top + i * bandH, sky.width, bandH + 1), Paint()..color = bands[i]);
    }
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.16)..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(sky.left + 10, sky.top + sky.height * .28), Offset(sky.left + sky.width * .34, sky.top + sky.height * .25), cloud);
    canvas.drawLine(Offset(sky.left + sky.width * .58, sky.top + sky.height * .38), Offset(sky.right - 12, sky.top + sky.height * .35), cloud);
    // الأفق البرتقالي.
    final horizonY = rect.top + rect.height * 0.62;
    canvas.drawRect(
      Rect.fromLTWH(rect.left, horizonY, rect.width, 3),
      Paint()..color = SudaneseTheme.dateOrange,
    );
    // شمس الطبق.
    final sunR = rect.width * 0.20;
    final sunY = horizonY - sunR * 0.4 - sunT * rect.height * 0.18;
    paintTabaq(
      canvas,
      Rect.fromCircle(
          center: Offset(rect.center.dx, sunY), radius: sunR),
    );
    // أهرامات مروي.
    final pyr = Paint()..color = const Color(0xFF4A2A4A);
    final base = horizonY + 2;
    for (final (fx, fw, fh) in [
      (0.12, 0.26, 0.16),
      (0.42, 0.34, 0.22),
      (0.74, 0.22, 0.13),
    ]) {
      final x0 = rect.left + rect.width * fx;
      final w = rect.width * fw;
      final h = rect.height * fh;
      canvas.drawPath(
        Path()
          ..moveTo(x0, base)
          ..lineTo(x0 + w / 2, base - h)
          ..lineTo(x0 + w, base)
          ..close(),
        pyr,
      );
    }
    // النيل: شريط فيروزي بخطوط أفقية فاتحة.
    final nileTop = rect.top + rect.height * 0.74;
    canvas.drawRect(
      Rect.fromLTWH(rect.left, nileTop, rect.width,
          rect.bottom - nileTop),
      Paint()..color = SudaneseTheme.turquoise,
    );
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.5;
    for (var i = 0; i < 3; i++) {
      final y = nileTop + 8 + i * 9;
      canvas.drawLine(
          Offset(rect.left + 10, y), Offset(rect.right - 10, y), linePaint);
    }
    // النخلة (يمين الباب).
    final palmX = rect.right - rect.width * 0.16;
    final palmBase = rect.bottom - 2;
    final trunk = Paint()
      ..color = const Color(0xFF3A2418)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(palmX, palmBase);
    canvas.rotate(palmSway);
    canvas.translate(-palmX, -palmBase);
    final trunkPath = Path()
      ..moveTo(palmX, palmBase)
      ..quadraticBezierTo(
          palmX + 10, palmBase - 40, palmX + 4, palmBase - 62);
    canvas.drawPath(trunkPath, trunk);
    final top = Offset(palmX + 4, palmBase - 62);
    final frond = Paint()
      ..color = SudaneseTheme.palmGreen
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 6; i++) {
      final a = -math.pi * (0.15 + i * 0.14);
      final end = top + Offset(math.cos(a) * 26, math.sin(a) * 14 - 6);
      canvas.drawPath(
        Path()
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(
              top.dx + math.cos(a) * 16, top.dy - 12, end.dx, end.dy),
        frond,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WallPainter oldDelegate) =>
      oldDelegate.sunT != sunT ||
      oldDelegate.palmSway != palmSway ||
      oldDelegate.glow != glow ||
      oldDelegate.plates != plates ||
      oldDelegate.doorTopFraction != doorTopFraction ||
      oldDelegate.doorHeightFraction != doorHeightFraction;
}
