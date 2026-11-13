// لوحة السيجا: لوح رمل عضوي بحواف منحوتة وحفر عميقة، لا مربعات ولا رقعة شطرنج.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/sudanese_theme.dart';
import 'tabaq.dart';

class BoardPainter extends CustomPainter {
  final int size;
  final bool centreOccupied;
  const BoardPainter({required this.size, this.centreOccupied = false});

  static Offset pitCenter(Size boardSize, int cells, int r, int c) {
    final inner = boardSize.shortestSide - 16;
    final cell = inner / cells;
    return Offset(8 + (c + 0.5) * cell, 8 + (r + 0.5) * cell);
  }

  static double pitDiameter(Size boardSize, int cells) => (boardSize.shortestSide - 16) / cells * 0.72;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final side = canvasSize.shortestSide;
    final rect = Rect.fromLTWH((canvasSize.width - side) / 2, (canvasSize.height - side) / 2, side, side);
    final shadow = Paint()..color = SudaneseTheme.earthBlack.withValues(alpha: 0.40);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.translate(0, 8), const Radius.circular(28)), shadow);

    // حواف غير منتظمة، كقطعة رمل وضعت باليد.
    final slab = _slabPath(rect, 0);
    canvas.drawPath(slab, Paint()..color = const Color(0xFFDDB66E));
    canvas.drawPath(_slabPath(rect.deflate(4), 1), Paint()..color = SudaneseTheme.sand);

    final rng = math.Random(422);
    for (var i = 0; i < 260; i++) {
      final p = Offset(rect.left + 8 + rng.nextDouble() * (side - 16), rect.top + 8 + rng.nextDouble() * (side - 16));
      final color = i.isEven ? SudaneseTheme.sandDark : const Color(0xFFF2D49A);
      canvas.drawCircle(p, 0.45 + rng.nextDouble() * 1.3, Paint()..color = color.withValues(alpha: 0.24 + rng.nextDouble() * 0.22));
    }
    canvas.drawPath(_slabPath(rect.deflate(3), 2), Paint()..color = const Color(0xFF9F773E)..style = PaintingStyle.stroke..strokeWidth = 2.4);
    canvas.drawPath(_slabPath(rect.deflate(7), 3), Paint()..color = Colors.white.withValues(alpha: 0.25)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    final inner = side - 16;
    final cell = inner / size;
    final pitR = cell * 0.36;
    final centre = size ~/ 2;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final p = Offset(rect.left + 8 + (c + 0.5) * cell, rect.top + 8 + (r + 0.5) * cell);
        _paintPit(canvas, p, pitR, r, c);
        if (r == centre && c == centre && !centreOccupied) {
          paintDashedCircle(canvas, p, pitR * 0.92, SudaneseTheme.palmGreen, 2.5, dashes: 16);
          paintEightStar(canvas, p, pitR * 0.40, SudaneseTheme.tabaqRed);
        }
      }
    }
  }

  Path _slabPath(Rect r, int seed) {
    final n = 12.0 + seed;
    return Path()
      ..moveTo(r.left + n, r.top + 2)
      ..quadraticBezierTo(r.center.dx, r.top - 2, r.right - n, r.top + 3)
      ..quadraticBezierTo(r.right + 2, r.center.dy, r.right - 3, r.bottom - n)
      ..quadraticBezierTo(r.center.dx, r.bottom + 2, r.left + 4, r.bottom - 4)
      ..quadraticBezierTo(r.left - 2, r.center.dy, r.left + 2, r.top + n)
      ..close();
  }

  void _paintPit(Canvas canvas, Offset p, double r, int row, int col) {
    canvas.drawOval(Rect.fromCenter(center: p + Offset(0, r * 0.38), width: r * 1.75, height: r * 0.52), Paint()..color = SudaneseTheme.earthBlack.withValues(alpha: 0.18));
    canvas.drawCircle(p, r, Paint()..color = const Color(0xFFB78B4B));
    canvas.drawCircle(p + Offset(0, -r * 0.08), r * 0.94, Paint()..color = SudaneseTheme.pitDark);
    canvas.drawCircle(p + Offset(-r * 0.08, -r * 0.20), r * 0.70, Paint()..color = SudaneseTheme.pitDeep);
    canvas.drawArc(Rect.fromCircle(center: p + Offset(0, -r * 0.08), radius: r * 0.78), 0.2, math.pi * 0.75, false,
        Paint()..color = const Color(0xFFF1D39B).withValues(alpha: 0.55)..style = PaintingStyle.stroke..strokeWidth = 2.4..strokeCap = StrokeCap.round);
    canvas.drawArc(Rect.fromCircle(center: p, radius: r * 0.93), math.pi * 0.9, math.pi * 0.8, false,
        Paint()..color = SudaneseTheme.earthBlack.withValues(alpha: 0.28)..style = PaintingStyle.stroke..strokeWidth = 1.4);
    if ((row + col) % 3 == 0) canvas.drawCircle(p + Offset(r * .28, -r * .18), 1.2, Paint()..color = const Color(0xFFE9C987).withValues(alpha: .6));
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => oldDelegate.size != size || oldDelegate.centreOccupied != centreOccupied;
}
