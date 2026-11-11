// نقطة دخول اللعبة v3.0: شاشة البداية 2.0 ث ثم الرئيسية.
// شجرة: Splash → Home (الوضع + الإعداد) → Game.
import 'package:flutter/material.dart';

import 'game/sound_manager.dart';
import 'l10n/strings.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'services/settings_store.dart';
import 'theme/sudanese_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.load();
  await SoundManager.instance.init();
  runApp(const SeegaGame());
}

class SeegaGame extends StatelessWidget {
  const SeegaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Alseeja — السيجا السودانية',
          theme: SudaneseTheme.theme,
          home: const SplashScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/game' && settings.arguments is GameConfig) {
              final config = settings.arguments as GameConfig;
              return FadeSlidePageRoute(
                builder: (_) => GameScreen(config: config),
              );
            }
            return null;
          },
        );
      },
    );
  }
}

/// شاشة البداية (2.0 ث): شعار يكبر 0.8→1.0 مع تلاشٍ (600ms easeOutBack)،
/// العنوان يصعد مع تلاشٍ، شريط نوبي يمر، وخط تقدم رفيع، ثم تلاشٍ إلى الرئيسية.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _stripSweep;
  late final Animation<double> _progress;
  bool _soundPlayed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    _stripSweep = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.95, curve: Curves.easeOut),
      ),
    );
    _controller.addListener(() {
      if (!_soundPlayed && _controller.value > 0.05) {
        _soundPlayed = true;
        SoundManager.instance.start();
      }
    });
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2000), () {
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

  @override
  Widget build(BuildContext context) {
    final strings = Strings(AppSettings.instance.isArabic);
    return Scaffold(
      body: SudaneseTheme.gradientBackground(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: SudaneseTheme.nileGradient,
                        ),
                        boxShadow: SudaneseTheme.softShadow(opacity: 0.25),
                      ),
                      child: const Center(
                        child: CustomPaint(
                          size: Size(64, 64),
                          painter: NubianStarPainter(
                            color: SudaneseTheme.goldLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: Column(
                      children: [
                        Text(
                          strings.appTitle,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: SudaneseTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.tagline,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: SudaneseTheme.clay,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Opacity(
                  opacity: _stripSweep.value,
                  child: SudaneseTheme.nubianStrip(height: 10),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: LinearProgressIndicator(
                    value: _progress.value,
                    backgroundColor: SudaneseTheme.sandDark,
                    valueColor: const AlwaysStoppedAnimation(
                        SudaneseTheme.nile),
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            );
          },
        ),
      ),
    );
  }
}
