// رسّام لوحة الرمل (§5.2 + لوحة التصميم): لوح رملي مستطيل
// بحواف دائرية وظل صلب، حبيبات رمل، وحُفَر دائرية مجوّفة.
// الوسطى الفارغة فيها حلقة خضراء متقطعة ونجمة حمراء ونقطة ذهبية.
// لا مربعات ولا رقعة شطرنج أبداً.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';
import 'tabaq.dart';

class BoardPainter extends CustomPainter {
  final int size;
  final bool centreOccupied;

  const BoardPainter({required this.size, this.centreOccupied = false});

  /// مركز حفرة (r, c) ضمن مساحة اللوحة الكاملة.
  static Offset pitCenter(Size boardSize, int cells, int r, int c) {
    final inner = boardSize.shortestSide - 16;
    final cell = inner / cells;
    return Offset(8 + (c + 0.5) * cell, 8 + (r + 0.5) * cell);
  }

  /// قطر الحفرة.
  static double pitDiameter(Size boardSize, int cells) {
    final inner = boardSize.shortestSide - 16;
    return (inner / cells) * 0.72;
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final side = canvasSize.shortestSide;
    final rect = Rect.fromLTWH(
      (canvasSize.width - side) / 2,
      (canvasSize.height - side) / 2,
      side,
      side,
    );
    // ظل صلب منزاح.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.translate(0, 6),
        const Radius.circular(24),
      ),
      Paint()..color = SudaneseTheme.earthBlack.withValues(alpha: 0.28),
    );
    // اللوح الرملي.
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(24)),
      Paint()..color = SudaneseTheme.sand,
    );
    // حبيبات رمل (عشوائية ثابتة البذرة).
    final rng = math.Random(42);
    final grain = Paint()
      ..color = SudaneseTheme.sandDark.withValues(alpha: 0.35);
    for (var i = 0; i < 140; i++) {
      final x = rect.left + 10 + rng.nextDouble() * (side - 20);
      final y = rect.top + 10 + rng.nextDouble() * (side - 20);
      canvas.drawCircle(Offset(x, y), 0.8 + rng.nextDouble() * 1.1, grain);
    }
    // حافة اللوح.
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(22)),
      Paint()
        ..color = const Color(0xFFB98F52)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // الحُفَر.
    final inner = side - 16;
    final cell = inner / size;
    final pitR = cell * 0.36;
    final centre = size ~/ 2;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final p = Offset(
          rect.left + 8 + (c + 0.5) * cell,
          rect.top + 8 + (r + 0.5) * cell,
        );
        _paintPit(canvas, p, pitR);
        if (r == centre && c == centre && !centreOccupied) {
          // حلقة خضراء متقطعة + نجمة حمراء + نقطة ذهبية.
          paintDashedCircle(
            canvas,
            p,
            pitR * 0.92,
            SudaneseTheme.palmGreen,
            2.5,
            dashes: 16,
          );
          paintEightStar(canvas, p, pitR * 0.42, SudaneseTheme.tabaqRed);
        }
      }
    }
  }

  /// حفرة مجوّفة: حلقة فاتحة، داخل غامق، ولمعة سفلية.
  void _paintPit(Canvas canvas, Offset p, double r) {
    // حلقة الحفرة (حافة محفورة).
    canvas.drawCircle(
      p,
      r,
      Paint()
        ..color = SudaneseTheme.sandDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // داخل الحفرة.
    canvas.drawCircle(p, r * 0.94, Paint()..color = SudaneseTheme.pitDark);
    canvas.drawCircle(
      p + Offset(0, -r * 0.12),
      r * 0.72,
      Paint()..color = SudaneseTheme.pitDeep,
    );
    // لمعة سفلية خفيفة (عمق).
    canvas.drawArc(
      Rect.fromCircle(center: p, radius: r * 0.8),
      math.pi * 0.15,
      math.pi * 0.7,
      false,
      Paint()
        ..color = const Color(0xFFF0D6A0).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) =>
      oldDelegate.size != size ||
      oldDelegate.centreOccupied != centreOccupied;
}
