// نقطة دخول اللعبة v4: Splash (طبق + جدار) → الرئيسية → الإعداد → اللعب.
// الاتجاه RTL عند العربية وLTR عند الإنجليزية.
import 'package:flutter/material.dart';

import 'game/sound_manager.dart';
import 'screens/game_screen.dart';
import 'screens/splash_screen.dart';
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
        final isArabic = AppSettings.instance.isArabic;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Alseeja — السيجا السودانية',
          theme: SudaneseTheme.theme,
          // الاتجاه يُضبط صراحةً حسب اللغة (builder) لئلا يعتمد
          // على إعدادات النظام.
          builder: (context, child) => Directionality(
            textDirection:
                isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
          home: const SplashScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/game' &&
                settings.arguments is GameConfig) {
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
