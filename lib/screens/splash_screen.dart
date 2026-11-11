// شاشة البداية v4 (2.2 ث): جدار الحوش يظهر، شمس الطبق
// تشرق خلف الأهرامات، العنوان يُرسم مسحاً حرفاً حرفاً،
// والأطباق الستة تظهر واحداً واحداً (60ms بينها)، ثم
// يكبر الباب كتلاشٍ متقاطع إلى الرئيسية.
import 'package:flutter/material.dart';

import '../game/sound_manager.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/painters/wall.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _soundPlayed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _controller.addListener(() {
      if (!_soundPlayed && _controller.value > 0.05) {
        _soundPlayed = true;
        SoundManager.instance.start();
      }
    });
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        FadeSlidePageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _interval(double start, double end, double value) {
    if (value <= start) return 0.0;
    if (value >= end) return 1.0;
    final t = (value - start) / (end - start);
    return Curves.easeOutCubic.transform(t);
  }

  double _pop(int i, double value) {
    final start = 0.15 + i * 0.06;
    final t = _interval(start, start + 0.15, value);
    return Curves.easeOutBack.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings(AppSettings.instance.isArabic);
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final v = _controller.value;
          final sunT = _interval(0.0, 0.5, v);
          final glow = _interval(0.0, 0.4, v);
          final plates = List.generate(6, (i) => _pop(i, v));
          final titleReveal = _interval(0.35, 0.75, v);
          final subFade = _interval(0.6, 0.85, v);
          return Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: WallPainter(
                    sunT: sunT,
                    glow: glow,
                    plates: plates,
                    // الباب تحت منطقة العنوان.
                    doorTopFraction: 0.18,
                    doorHeightFraction: 0.75,
                  ),
                ),
              ),
              // العنوان يُرسم مسحاً من اليمين (RTL).
              Positioned(
                top: 48,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerRight,
                        widthFactor:
                            titleReveal.clamp(0.01, 1.0),
                        child: Text(
                          strings.appTitle,
                          style: SudaneseTheme.display.copyWith(
                            fontSize: 64,
                            color: SudaneseTheme.indigo,
                            shadows: const [
                              Shadow(
                                color: SudaneseTheme.tabaqRed,
                                offset: Offset(3, 4),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: subFade,
                      child: Text(
                        strings.tagline,
                        style: SudaneseTheme.bodyBold.copyWith(
                          fontSize: 17,
                          color: SudaneseTheme.ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
