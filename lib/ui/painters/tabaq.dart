// رسّام الطبق (§5.2): دائرة قش بحلقات متحدة المركز
// (أسود، أحمر متقطع، أخضر متقطع، أسود رفيع، برتقالي، كركدي)
// ووردة وسطى من 16 إسفيناً وحافة سوداء رفيعة.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

/// يرسم دائرة متقطعة (شرطات) — تُستخدم للحلقات والأطر.
void paintDashedCircle(
  Canvas canvas,
  Offset center,
  double radius,
  Color color,
  double strokeWidth, {
  int dashes = 24,
  double gapFraction = 0.5,
}) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.butt;
  final step = 2 * math.pi / dashes;
  final sweep = step * (1 - gapFraction);
  for (var i = 0; i < dashes; i++) {
    final a0 = i * step;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      a0,
      sweep,
      false,
      paint,
    );
  }
}

/// نجمة ثمانية الرؤوس حمراء مع نقطة ذهبية (لوسط اللوحة والميدالية).
void paintEightStar(
  Canvas canvas,
  Offset center,
  double outer,
  Color color, {
  Color dotColor = SudaneseTheme.sunGold,
}) {
  final inner = outer * 0.45;
  final path = Path();
  for (var i = 0; i < 16; i++) {
    final r = i.isEven ? outer : inner;
    final a = -math.pi / 2 + i * math.pi / 8;
    final x = center.dx + r * math.cos(a);
    final y = center.dy + r * math.sin(a);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  canvas.drawPath(path, Paint()..color = color);
  canvas.drawCircle(
    center,
    outer * 0.2,
    Paint()..color = dotColor,
  );
}

/// يرسم طبقاً كاملاً في المستطيل المعطى (لإعادة الاستخدام من
/// رسّامين آخرين كالجدار والميدالية وأيقونة التطبيق).
void paintTabaq(Canvas canvas, Rect rect, {double rotation = 0}) {
  final center = rect.center;
  final r = math.min(rect.width, rect.height) / 2;
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(rotation);
  canvas.translate(-center.dx, -center.dy);

  // القاعدة: قش.
  canvas.drawCircle(
    center,
    r,
    Paint()..color = SudaneseTheme.straw,
  );
  // حلقات قش خافتة (نسيج).
  for (var i = 1; i <= 4; i++) {
    canvas.drawCircle(
      center,
      r * i / 5,
      Paint()
        ..color = SudaneseTheme.sandDark.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }
  // الحلقات الملونة من الخارج إلى الداخل.
  canvas.drawCircle(
    center,
    r * 0.96,
    Paint()
      ..color = SudaneseTheme.earthBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.05,
  );
  paintDashedCircle(canvas, center, r * 0.84, SudaneseTheme.tabaqRed,
      r * 0.055,
      dashes: 28);
  paintDashedCircle(canvas, center, r * 0.71, SudaneseTheme.palmGreen,
      r * 0.05,
      dashes: 24);
  paintDashedCircle(canvas, center, r * 0.60, SudaneseTheme.earthBlack,
      r * 0.02,
      dashes: 36);
  canvas.drawCircle(
    center,
    r * 0.52,
    Paint()
      ..color = SudaneseTheme.dateOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.045,
  );
  canvas.drawCircle(
    center,
    r * 0.44,
    Paint()
      ..color = SudaneseTheme.hibiscus
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.045,
  );
  // الوردة الوسطى: 16 إسفيناً متناوبة.
  for (var i = 0; i < 16; i++) {
    final a0 = i * math.pi / 8;
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: r * 0.36),
        a0,
        math.pi / 8,
        false,
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = i.isEven
            ? SudaneseTheme.tabaqRed
            : SudaneseTheme.sunGold,
    );
  }
  canvas.drawCircle(
    center,
    r * 0.10,
    Paint()..color = SudaneseTheme.earthBlack,
  );
  // الحافة السوداء الرفيعة.
  canvas.drawCircle(
    center,
    r * 0.99,
    Paint()
      ..color = SudaneseTheme.earthBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5,
  );
  canvas.restore();
}

class TabaqPainter extends CustomPainter {
  final double rotation;

  const TabaqPainter({this.rotation = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // ظل صلب منزاح قليلاً.
    canvas.drawCircle(
      Offset(rect.center.dx, rect.center.dy + size.height * 0.03),
      size.shortestSide / 2,
      Paint()
        ..color = SudaneseTheme.earthBlack.withValues(alpha: 0.25),
    );
    paintTabaq(canvas, rect, rotation: rotation);
  }

  @override
  bool shouldRepaint(covariant TabaqPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}
