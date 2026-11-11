// رسّام البرش (§5.2 + لوحة التصميم): خلفية قش بخطوط قصب
// عمودية، وشريط خيط أحمر أعلى (في اللعب)، وحاشية أسفل الحافة.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

class MatPainter extends CustomPainter {
  /// إظهار شريط الخيط الأحمر أعلى البرش.
  final bool topThread;

  /// إظهار الحاشية أسفل الحافة.
  final bool fringe;

  const MatPainter({this.topThread = false, this.fringe = false});

  @override
  void paint(Canvas canvas, Size size) {
    // قاعدة القش.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFDDBB77),
    );
    // خطوط القصب العمودية.
    final rng = math.Random(7);
    for (var x = 0.0; x < size.width; x += 6) {
      final alpha = 0.08 + rng.nextDouble() * 0.10;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = SudaneseTheme.mudBrick.withValues(alpha: alpha)
          ..strokeWidth = 1.2,
      );
    }
    // قصب أسمك كل ~48px.
    for (var x = 12.0; x < size.width; x += 48) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = SudaneseTheme.mudBrick.withValues(alpha: 0.14)
          ..strokeWidth = 2,
      );
    }
    // شريط خيط أحمر أعلى.
    if (topThread) {
      final y = size.height * 0.135;
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, 5),
        Paint()..color = SudaneseTheme.tabaqRed,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, y + 5, size.width, 1.5),
        Paint()
          ..color = SudaneseTheme.earthBlack.withValues(alpha: 0.5),
      );
    }
    // الحاشية أسفل الحافة: خيوط عمودية قصيرة.
    if (fringe) {
      final base = size.height - 16;
      for (var x = 2.0; x < size.width; x += 5) {
        final len = 10 + ((x ~/ 5) % 3) * 3;
        canvas.drawLine(
          Offset(x, base),
          Offset(x, base + len),
          Paint()
            ..color = SudaneseTheme.mudBrick.withValues(alpha: 0.55)
            ..strokeWidth = 1.6,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant MatPainter oldDelegate) =>
      oldDelegate.topThread != topThread || oldDelegate.fringe != fringe;
}
