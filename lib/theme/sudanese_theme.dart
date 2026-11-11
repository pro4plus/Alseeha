// نظام تصميم v3.0: دافئ، غني، ملموس — لوحة خشبية منحوتة على طاولة
// رملية بإضاءة ناعمة من الأعلى، بروح سودانية.
import 'dart:math' as math;

import 'package:flutter/material.dart';

class SudaneseTheme {
  // ---- الألوان ----
  static const Color bgTop = Color(0xFFF6EBD3);
  static const Color bgBottom = Color(0xFFEBD8B2);
  static const Color surface = Color(0xFFFFFBF2);
  static const Color sand = Color(0xFFF3E7CE);
  static const Color sandDark = Color(0xFFE3CFA5);
  static const Color clay = Color(0xFF7B4A2B);
  static const Color clayDark = Color(0xFF5A3320);
  static const Color nile = Color(0xFF146B8A);
  static const Color nileDark = Color(0xFF0E4E66);
  static const Color palm = Color(0xFF1E7A4C);
  static const Color sudanRed = Color(0xFFC1442E);
  static const Color gold = Color(0xFFD9A441);
  static const Color goldLight = Color(0xFFF2C96B);
  static const Color ink = Color(0xFF2B2118);
  static const Color tileLight = Color(0xFFEFDDB8);
  static const Color tileDark = Color(0xFFD9B98A);
  static const Color centerTile = Color(0xFFBFE3E8);

  static const List<Color> nileGradient = [nile, nileDark];
  static const List<Color> palmGradient = [palm, Color(0xFF14603A)];
  static const List<Color> redGradient = [sudanRed, Color(0xFF9E3220)];
  static const List<Color> goldGradient = [goldLight, gold];

  // ---- الأبعاد ----
  static const double radiusButton = 18;
  static const double radiusCard = 24;
  static const double radiusBoard = 28;
  static const double radiusDialog = 28;
  static const double buttonHeight = 56;

  static List<BoxShadow> softShadow({double opacity = 0.12}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  static ThemeData get theme {
    const fontFamily = 'Tajawal';
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: bgBottom,
      colorScheme: const ColorScheme.light(
        primary: nile,
        secondary: gold,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: ink,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.w900, color: ink,
            height: 1.3),
        headlineMedium: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w900, color: ink,
            height: 1.4),
        titleLarge: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: ink,
            height: 1.5),
        titleMedium: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: ink,
            height: 1.5),
        bodyLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: ink,
            height: 1.5),
        bodyMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: ink,
            height: 1.5),
        bodySmall: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: ink,
            height: 1.5),
        labelLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: ink,
            height: 1.4),
      ),
    );
  }

  /// خلفية التدرج الرملي مع نمط نوبي خافت (4%).
  static Widget gradientBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgTop, bgBottom],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Opacity(
            opacity: 0.04,
            child: CustomPaint(painter: _NubianPatternPainter()),
          ),
          child,
        ],
      ),
    );
  }

  /// شريط نوبي: مثلثات متكررة بألوان العلم.
  static Widget nubianStrip({double height = 10}) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _NubianPainter(),
    );
  }

  /// لون تمثيلي لحجر ما (لاستخدامه في النقاط والتوهجات).
  static Color stoneColor(String asset) {
    if (asset.contains('blue')) return const Color(0xFF2B4C9B);
    if (asset.contains('brown')) return const Color(0xFF8B5A2B);
    if (asset.contains('green')) return const Color(0xFF2E7D4F);
    if (asset.contains('red')) return const Color(0xFFC0392B);
    if (asset.contains('turquoise')) return const Color(0xFF1ABC9C);
    if (asset.contains('yellow')) return const Color(0xFFD9A441);
    if (asset.contains('gray')) return const Color(0xFF7F8C8D);
    return nile;
  }
}

/// نمط هندسي نوبي خافت للخلفية: معيّنات صغيرة.
class _NubianPatternPainter extends CustomPainter {
  const _NubianPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SudaneseTheme.clayDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const step = 56.0;
    for (var y = -step; y < size.height + step; y += step) {
      for (var x = -step; x < size.width + step; x += step) {
        final cx = x + ((y / step) % 2 == 0 ? 0 : step / 2);
        final path = Path()
          ..moveTo(cx, y - 10)
          ..lineTo(cx + 10, y)
          ..lineTo(cx, y + 10)
          ..lineTo(cx - 10, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NubianPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      SudaneseTheme.sudanRed,
      SudaneseTheme.gold,
      SudaneseTheme.palm,
      SudaneseTheme.nile,
    ];
    final w = size.width / 16;
    for (var i = 0; i < 16; i++) {
      final paint = Paint()..color = colors[i % colors.length];
      final path = Path()
        ..moveTo(i * w, size.height)
        ..lineTo(i * w + w / 2, 0)
        ..lineTo((i + 1) * w, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// نجمة نوبية ثمانية الرؤوس تُرسم (لا تعتمد على أي خط).
class NubianStarPainter extends CustomPainter {
  final Color color;
  final double glow; // 0..1: توهج إضافي حول النجمة.

  const NubianStarPainter({required this.color, this.glow = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = math.min(size.width, size.height) / 2;
    final inner = outer * 0.45;
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 8;
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    if (glow > 0) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.35 * glow)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), outer * (1 + 0.35 * glow), glowPaint);
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(Offset(cx, cy), outer * 0.16, dotPaint);
  }

  @override
  bool shouldRepaint(covariant NubianStarPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.glow != glow;
}

/// انتقال مشترك: تلاشٍ + انزلاق 24 بكسل (320ms, easeOutCubic).
class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  FadeSlidePageRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}
