// الطابع السوداني: ألوان النيل والرمل والطين النوبي،
// بلا أي اعتماد خارجي — ألوان وتدرجات فقط.
import 'package:flutter/material.dart';

class SudaneseTheme {
  // رمل الصحراء — خلفية دافئة.
  static const Color sand = Color(0xFFF3E7CE);
  static const Color sandDark = Color(0xFFE3CFA5);
  // طين نوبي / بني اللوحة.
  static const Color clay = Color(0xFF7B4A2B);
  static const Color clayDark = Color(0xFF5A3320);
  // أزرق النيل.
  static const Color nile = Color(0xFF146B8A);
  static const Color nileDark = Color(0xFF0E4E66);
  // أخضر النخيل.
  static const Color palm = Color(0xFF1E7A4C);
  // أحمر العلم السوداني — للّمسات فقط، ليس خلفية كاملة.
  static const Color sudanRed = Color(0xFFC1442E);
  // ذهبي الشمس.
  static const Color gold = Color(0xFFD9A441);
  static const Color goldLight = Color(0xFFF2C96B);
  static const Color ink = Color(0xFF2B2118);

  static const Color tileLight = Color(0xFFEFDDB8);
  static const Color tileDark = Color(0xFFD9B98A);
  static const Color centerTile = Color(0xFFBFE3E8);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: sand,
      colorScheme: const ColorScheme.light(
        primary: nile,
        secondary: gold,
        surface: Color(0xFFFFFBF2),
        onPrimary: Colors.white,
        onSecondary: ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: clay,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: nile,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: ink),
        titleLarge: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: ink),
        bodyLarge: TextStyle(fontSize: 17, color: ink),
        bodyMedium: TextStyle(fontSize: 15, color: ink),
      ),
    );
  }

  /// زخرفة نوبية بسيطة: مثلثات متكررة بألوان العلم، تُرسم فوق الخلفية.
  static Widget nubianStrip({double height = 10}) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _NubianPainter(),
    );
  }
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
