// السيجا السودانية — نقطة الدخول.
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/sudanese_theme.dart';

void main() {
  runApp(const SeegaGame());
}

class SeegaGame extends StatelessWidget {
  const SeegaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'السيجا السودانية',
      debugShowCheckedModeBanner: false,
      theme: SudaneseTheme.theme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SudaneseTheme.sand,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/nubax.png',
              width: 180,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.grid_4x4,
                size: 120,
                color: SudaneseTheme.clay,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'السيجا السودانية',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: SudaneseTheme.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لعبة الحصار والدهاء',
              style: TextStyle(
                fontSize: 16,
                color: SudaneseTheme.clay,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: SudaneseTheme.nile,
            ),
          ],
        ),
      ),
    );
  }
}
