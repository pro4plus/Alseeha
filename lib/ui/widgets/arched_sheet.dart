// الصفحة المقوّسة (§5.3 + لوحة التصميم): لوح كريمي بقمة
// نصف دائرية (شكل الباب)، بإطار فيروزي وخط أحمر متقطع
// داخلي. كل القوائم والنتيجة والإعدادات تظهر فيها —
// لا حوارات Material افتراضية أبداً.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

/// يرسم خطاً متقطعاً على مسار معطى.
void paintDashedPath(
  Canvas canvas,
  Path path,
  Color color,
  double strokeWidth, {
  double dash = 8,
  double gap = 6,
}) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth;
  for (final metric in path.computeMetrics()) {
    var dist = 0.0;
    while (dist < metric.length) {
      final seg = metric.extractPath(dist, (dist + dash).clamp(0, metric.length));
      canvas.drawPath(seg, paint);
      dist += dash + gap;
    }
  }
}

/// اللوح المقوّس نفسه (بدون منطق العرض).
class ArchedPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const ArchedPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 26, 20, 28),
  });

  static const double _archRadius = 190;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SudaneseTheme.turquoise,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_archRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: const BoxDecoration(
            color: SudaneseTheme.cream,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(_archRadius - 5),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _DashedArchPainter(),
                ),
              ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const inset = 14.0;
    final r = (size.width / 2 - inset).clamp(0.0, 190.0);
    final path = Path()
      ..moveTo(inset, size.height - inset)
      ..lineTo(inset, r + inset)
      ..arcTo(
        Rect.fromCircle(
          center: Offset(size.width / 2, r + inset),
          radius: r,
        ),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(size.width - inset, size.height - inset);
    paintDashedPath(
      canvas,
      path,
      SudaneseTheme.tabaqRed.withValues(alpha: 0.7),
      2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// يعرض صفحة مقوّسة من أسفل الشاشة.
Future<T?> showArchedSheet<T>({
  required BuildContext context,
  required Widget child,
  bool dismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: dismissible,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ArchedPanel(child: child),
      );
    },
  );
}
