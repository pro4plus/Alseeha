import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';

class MatPainter extends CustomPainter {
  final bool topThread;
  final bool fringe;
  const MatPainter({this.topThread = false, this.fringe = false});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFD9AF67));
    final rng = math.Random(7007);
    // خيوط القصب الرأسية والأفقية، مع اختلافات خفيفة حتى لا تبدو كخلفية مسطحة.
    for (var x = -2.0; x < size.width + 4; x += 5) {
      canvas.drawLine(Offset(x, 0), Offset(x + rng.nextDouble() * 1.5 - .75, size.height), Paint()..color = SudaneseTheme.mudBrick.withValues(alpha: .10 + rng.nextDouble() * .10)..strokeWidth = 1.1);
    }
    for (var y = 3.0; y < size.height; y += 12) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + rng.nextDouble() * 1.4), Paint()..color = const Color(0xFF8A5129).withValues(alpha: .10)..strokeWidth = 1);
    }
    for (var x = 11.0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), Paint()..color = SudaneseTheme.mudBrick.withValues(alpha: .16)..strokeWidth = 2.2);
    }
    // أحزمة النسيج المميزة.
    for (final y in [size.height * .22, size.height * .74]) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 4), Paint()..color = SudaneseTheme.earthBlack.withValues(alpha: .72));
      canvas.drawRect(Rect.fromLTWH(0, y + 4, size.width, 4), Paint()..color = SudaneseTheme.tabaqRed.withValues(alpha: .84));
      for (var x = -size.height; x < size.width + size.height; x += 18) {
        final path = Path()..moveTo(x, y)..lineTo(x + 9, y + 4)..lineTo(x, y + 8)..close();
        canvas.drawPath(path, Paint()..color = SudaneseTheme.sunGold.withValues(alpha: .42));
      }
    }
    if (topThread) {
      canvas.drawRect(Rect.fromLTWH(0, size.height * .135, size.width, 5), Paint()..color = SudaneseTheme.tabaqRed);
      canvas.drawRect(Rect.fromLTWH(0, size.height * .135 + 5, size.width, 1.5), Paint()..color = SudaneseTheme.earthBlack.withValues(alpha: .6));
    }
    if (fringe) {
      final base = size.height - 17;
      for (var x = 2.0; x < size.width; x += 5) {
        final len = 10 + ((x ~/ 5) % 3) * 3;
        canvas.drawLine(Offset(x, base), Offset(x + (x % 3 - 1), base + len), Paint()..color = SudaneseTheme.earthBlack.withValues(alpha: .60)..strokeWidth = 1.7..strokeCap = StrokeCap.round);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MatPainter oldDelegate) => oldDelegate.topThread != topThread || oldDelegate.fringe != fringe;
}
