// نظام تصميم v4.0 — الحوش: لوحة مسطّحة مشبعة من الطبق والنيل،
// بلا تدرجات زجاجية ولا مظهر Material افتراضي.
// الخطوط: Reem Kufi 700 للعناوين، Tajawal 500/700/800 للنصوص.
import 'package:flutter/material.dart';

/// تعريف حجر (حصاة) من الأحجار السبعة: لون أساسي وفاتح وغامق.
class PebbleDef {
  final String nameAr;
  final String nameEn;
  final Color base;
  final Color light;
  final Color dark;

  const PebbleDef({
    required this.nameAr,
    required this.nameEn,
    required this.base,
    required this.light,
    required this.dark,
  });
}

class SudaneseTheme {
  // ---- لوحة §5.1 ----
  static const Color tabaqRed = Color(0xFFB3261E);
  static const Color palmGreen = Color(0xFF1F6B3A);
  static const Color dateOrange = Color(0xFFE58A1F);
  static const Color hibiscus = Color(0xFFA3205F);
  static const Color indigo = Color(0xFF1D2A5B);
  static const Color turquoise = Color(0xFF1AA3A8);
  static const Color straw = Color(0xFFD9B36A);
  static const Color cream = Color(0xFFF5E6C4);
  static const Color mudBrick = Color(0xFF8A5129);
  static const Color mudBrickDark = Color(0xFF6E3C1E);
  static const Color earthBlack = Color(0xFF1A1210);
  static const Color sunGold = Color(0xFFF2C14E);

  // ---- ألوان مساعدة ----
  static const Color ink = Color(0xFF2B1A12); // نص على الفاتح
  static const Color whitewash = Color(0xFFF3EAD2); // الجدار المبيّض
  static const Color sand = Color(0xFFE3C184); // لوحة الرمل
  static const Color sandDark = Color(0xFFC9A15E);
  static const Color pitDark = Color(0xFF9A7438); // داخل الحفرة
  static const Color pitDeep = Color(0xFF7A5A2C);
  static const Color clayBowl = Color(0xFFA85B32); // الطين
  static const Color clayBowlDark = Color(0xFF7E4022);
  static const Color woodDark = Color(0xFF4A2C17); // خشب داكن
  static const Color wood = Color(0xFF7A4A22); // خشب
  static const Color duskSky = Color(0xFF2B3A6B); // سماء الغروب (مسطحة)

  /// الأحجار السبعة (§5.2): نيلي، طيني، أخضر، أحمر، فيروزي، كهرماني، فحمي.
  static const List<PebbleDef> pebbles = [
    PebbleDef(
      nameAr: 'نيلي',
      nameEn: 'Indigo',
      base: Color(0xFF1D2A5B),
      light: Color(0xFF33477F),
      dark: Color(0xFF121B3D),
    ),
    PebbleDef(
      nameAr: 'طيني',
      nameEn: 'Clay',
      base: Color(0xFFB4552D),
      light: Color(0xFFC96A3F),
      dark: Color(0xFF8A3E1F),
    ),
    PebbleDef(
      nameAr: 'أخضر',
      nameEn: 'Green',
      base: Color(0xFF1F6B3A),
      light: Color(0xFF2E8B4F),
      dark: Color(0xFF14512A),
    ),
    PebbleDef(
      nameAr: 'أحمر',
      nameEn: 'Red',
      base: Color(0xFFB3261E),
      light: Color(0xFFC93A30),
      dark: Color(0xFF8A1B15),
    ),
    PebbleDef(
      nameAr: 'فيروزي',
      nameEn: 'Turquoise',
      base: Color(0xFF1AA3A8),
      light: Color(0xFF2EC4C9),
      dark: Color(0xFF12787C),
    ),
    PebbleDef(
      nameAr: 'كهرماني',
      nameEn: 'Ochre',
      base: Color(0xFFE58A1F),
      light: Color(0xFFF0A94E),
      dark: Color(0xFFB26A12),
    ),
    PebbleDef(
      nameAr: 'فحمي',
      nameEn: 'Charcoal',
      base: Color(0xFF3A3230),
      light: Color(0xFF574C46),
      dark: Color(0xFF241E1C),
    ),
  ];

  // ---- الخطوط ----
  static const String displayFont = 'ReemKufi';
  static const String bodyFont = 'Tajawal';

  static TextStyle get display => const TextStyle(
        fontFamily: displayFont,
        fontWeight: FontWeight.w700,
        color: ink,
        height: 1.2,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: displayFont,
        fontWeight: FontWeight.w700,
        fontSize: 30,
        color: ink,
        height: 1.3,
      );

  static TextStyle get heading => const TextStyle(
        fontFamily: displayFont,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: ink,
        height: 1.3,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: bodyFont,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: ink,
        height: 1.4,
      );

  static TextStyle get bodyBold => const TextStyle(
        fontFamily: bodyFont,
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: ink,
        height: 1.4,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: bodyFont,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: ink,
        height: 1.4,
      );

  /// ظل صلب منزاح (حرفة يدوية، لا ظل ناعم عام).
  static List<BoxShadow> hardShadow({Color color = earthBlack}) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 0,
          offset: const Offset(0, 5),
        ),
      ];

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: bodyFont,
      scaffoldBackgroundColor: mudBrickDark,
      colorScheme: const ColorScheme.light(
        primary: tabaqRed,
        secondary: sunGold,
        surface: cream,
        onPrimary: cream,
        onSecondary: ink,
      ),
      textTheme: TextTheme(
        displayLarge: display.copyWith(fontSize: 72),
        displayMedium: display.copyWith(fontSize: 48),
        headlineMedium: title,
        titleLarge: heading,
        titleMedium: bodyBold,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: bodyBold,
      ),
    );
  }
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
