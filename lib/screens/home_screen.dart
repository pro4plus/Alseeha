// الشاشة الرئيسية + شاشة الإعداد + طريقة اللعب + عن اللعبة (v3.0).
// الرئيسية: 3 مناطق (35/40/25)، أحجار عائمة، بطاقتا وضع بدخول متدرج.
// الإعداد: بلا تمرير على 390×844، زر "أبدأ" مثبّت أسفل.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../game/seega_ai.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/pressable_button.dart';
import '../ui/settings_sheet.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _showHowToPlay() {
    final s = Strings(AppSettings.instance.isArabic);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HowToPlaySheet(strings: s),
    );
  }

  void _showAbout() {
    final s = Strings(AppSettings.instance.isArabic);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AboutSheet(strings: s, onLaunch: _launch),
    );
  }

  void _openSetup({required bool vsComputer}) {
    Navigator.push(
      context,
      FadeSlidePageRoute(
        builder: (_) => SetupScreen(vsComputer: vsComputer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, child) {
        final s = Strings(AppSettings.instance.isArabic);
        return Scaffold(
          body: SudaneseTheme.gradientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // شريط علوي رفيع: ترس الإعدادات فقط.
                  Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        onPressed: () =>
                            SettingsSheet.show(context, s),
                        icon: const Icon(Icons.settings,
                            color: SudaneseTheme.clay),
                        tooltip: s.settings,
                      ),
                    ],
                  ),
                  // ---- المنطقة 1 (~35%): الشعار والعنوان ----
                  Expanded(
                    flex: 35,
                    child: Stack(
                      children: [
                        _floatingStone(0.12, 0.25, 0.0, 34),
                        _floatingStone(0.78, 0.18, 1.1, 28),
                        _floatingStone(0.85, 0.62, 2.2, 24),
                        _floatingStone(0.06, 0.60, 3.0, 26),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/seja.png',
                                width: 150,
                                height: 96,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.grid_4x4,
                                        size: 80,
                                        color: SudaneseTheme.clay),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                s.appTitle,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: SudaneseTheme.ink,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.tagline,
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
                      ],
                    ),
                  ),
                  // ---- المنطقة 2 (~40%): بطاقتا الوضع ----
                  Expanded(
                    flex: 40,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _modeCard(
                            interval: const Interval(0.15, 0.55,
                                curve: Curves.easeOutCubic),
                            icon: Icons.smart_toy,
                            title: s.playVsComputer,
                            subtitle: s.threeLevels,
                            gradient: SudaneseTheme.nileGradient,
                            onTap: () =>
                                _openSetup(vsComputer: true),
                          ),
                          const SizedBox(height: 16),
                          _modeCard(
                            interval: const Interval(0.35, 0.75,
                                curve: Curves.easeOutCubic),
                            icon: Icons.people,
                            title: s.playVsFriend,
                            subtitle: s.sameDevice,
                            gradient: SudaneseTheme.palmGradient,
                            onTap: () =>
                                _openSetup(vsComputer: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ---- المنطقة 3 (~25%): أزرار شبحية + تيك توك + شريط ----
                  Expanded(
                    flex: 25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: PressableButton(
                                  label: s.howToPlay,
                                  icon: Icons.help_outline,
                                  variant: ButtonVariant.ghost,
                                  onPressed: _showHowToPlay,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PressableButton(
                                  label: s.aboutGame,
                                  icon: Icons.info_outline,
                                  variant: ButtonVariant.ghost,
                                  onPressed: _showAbout,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () =>
                              _launch('https://www.tiktok.com/@nubax'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/tiktok.png',
                                width: 28,
                                height: 28,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.music_note,
                                        size: 26,
                                        color: SudaneseTheme.ink),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '@nubax',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: SudaneseTheme.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SudaneseTheme.nubianStrip(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _floatingStone(
      double fx, double fy, double phase, double size) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final dy =
            math.sin((_float.value * 2 * math.pi) + phase) * 7;
        return Positioned(
          left: MediaQuery.of(context).size.width * fx,
          top: 20 + MediaQuery.of(context).size.height * 0.30 * fy + dy,
          child: Opacity(
            opacity: 0.75,
            child: Image.asset(
              'assets/yellow_stone.png',
              width: size,
              height: size,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }

  Widget _modeCard({
    required Interval interval,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    final animation = CurvedAnimation(
      parent: _entrance,
      curve: interval,
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation),
        child: SizedBox(
          height: 96,
          width: double.infinity,
          child: PressableButton(
            label: title,
            subtitle: subtitle,
            icon: icon,
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- الإعداد

class SetupScreen extends StatefulWidget {
  final bool vsComputer;
  const SetupScreen({super.key, required this.vsComputer});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int gridSize = 5;
  Difficulty difficulty = Difficulty.medium;
  String? playerOneStone;
  String? playerTwoStone;

  static const List<String> stoneAssets = [
    'assets/blue_stone.png',
    'assets/brown_stone.png',
    'assets/green_stone.png',
    'assets/red_stone.png',
    'assets/turquoise_stone.png',
    'assets/yellow_stone.png',
    'assets/gray_stone.png',
  ];

  void _selectStone(String stone, bool isPlayerOne) {
    setState(() {
      if (isPlayerOne) {
        if (playerTwoStone != stone) playerOneStone = stone;
      } else {
        if (playerOneStone != stone) playerTwoStone = stone;
      }
    });
  }

  String? get _startDisabledReason {
    final s = Strings(AppSettings.instance.isArabic);
    if (playerOneStone == null) {
      return widget.vsComputer
          ? s.chooseYourStoneFirst
          : s.chooseStoneP1First;
    }
    if (playerTwoStone == null) {
      return widget.vsComputer
          ? s.chooseOpponentStoneFirst
          : s.chooseStoneP2First;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, child) {
        final s = Strings(AppSettings.instance.isArabic);
        final canStart =
            playerOneStone != null && playerTwoStone != null;
        final startLabel = canStart
            ? s.startPlaying
            : (_startDisabledReason ?? s.startPlaying);
        return Scaffold(
          body: SudaneseTheme.gradientBackground(
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // شريط علوي مثبّت (56).
                    SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back,
                                color: SudaneseTheme.ink),
                          ),
                          Expanded(
                            child: Text(
                              s.startGame,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: SudaneseTheme.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // حجم اللوحة + معاينة مصغرة.
                    Text(s.chooseBoard,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _boardToggle(),
                        ),
                        const SizedBox(width: 12),
                        _miniBoardPreview(),
                      ],
                    ),
                    if (widget.vsComputer) ...[
                      const SizedBox(height: 16),
                      Text(s.chooseDifficulty,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _difficultySegments(s),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 22,
                        child: AnimatedSwitcher(
                          duration:
                              const Duration(milliseconds: 250),
                          child: Text(
                            switch (difficulty) {
                              Difficulty.easy => s.easyDesc,
                              Difficulty.medium => s.mediumDesc,
                              Difficulty.hard => s.hardDesc,
                            },
                            key: ValueKey(difficulty),
                            style: const TextStyle(
                              fontSize: 14,
                              color: SudaneseTheme.clay,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(s.chooseStones,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _stoneRow(
                      label: widget.vsComputer
                          ? s.computerStone
                          : s.player1Stone,
                      selected: playerOneStone,
                      otherSelected: playerTwoStone,
                      isPlayerOne: true,
                    ),
                    const SizedBox(height: 12),
                    _stoneRow(
                      label: widget.vsComputer
                          ? s.computer
                          : s.player2Stone,
                      selected: playerTwoStone,
                      otherSelected: playerOneStone,
                      isPlayerOne: false,
                    ),
                    const Spacer(),
                    // زر البدء مثبّت أسفل.
                    PressableButton(
                      label: startLabel,
                      icon: Icons.play_arrow,
                      enabled: canStart,
                      onPressed: canStart
                          ? () {
                              Navigator.push(
                                context,
                                FadeSlidePageRoute(
                                  builder: (_) => GameScreen(
                                    config: GameConfig(
                                      boardSize: gridSize,
                                      vsComputer: widget.vsComputer,
                                      difficulty: difficulty,
                                      p1Asset: playerOneStone!,
                                      p2Asset: playerTwoStone!,
                                    ),
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _boardToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: SudaneseTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SudaneseTheme.sandDark),
      ),
      child: Row(
        children: [5, 7].map((size) {
          final selected = gridSize == size;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => gridSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 40,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: SudaneseTheme.nileGradient)
                      : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  size == 5 ? '5×5' : '7×7',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : SudaneseTheme.ink,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _miniBoardPreview() {
    final n = gridSize;
    return Container(
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SudaneseTheme.tileLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SudaneseTheme.clay),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: n,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
        ),
        itemCount: n * n,
        itemBuilder: (context, index) {
          final r = index ~/ n;
          final c = index % n;
          final isCentre = r == n ~/ 2 && c == n ~/ 2;
          return Container(
            decoration: BoxDecoration(
              color: isCentre
                  ? SudaneseTheme.centerTile
                  : (r + c) % 2 == 0
                      ? SudaneseTheme.sand
                      : SudaneseTheme.sandDark,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        },
      ),
    );
  }

  Widget _difficultySegments(Strings s) {
    final options = [
      (Difficulty.easy, s.easy),
      (Difficulty.medium, s.medium),
      (Difficulty.hard, s.hard),
    ];
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: SudaneseTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SudaneseTheme.sandDark),
      ),
      child: Row(
        children: options.map((opt) {
          final selected = difficulty == opt.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => difficulty = opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 40,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: SudaneseTheme.nileGradient)
                      : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  opt.$2,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : SudaneseTheme.ink,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _stoneRow({
    required String label,
    required String? selected,
    required String? otherSelected,
    required bool isPlayerOne,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stoneAssets.map((stone) {
            final isSelected = selected == stone;
            final isLocked = otherSelected == stone;
            return GestureDetector(
              onTap: isLocked
                  ? null
                  : () => _selectStone(stone, isPlayerOne),
              child: AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 180),
                child: Opacity(
                  opacity: isLocked ? 0.3 : 1.0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: SudaneseTheme.gold, width: 2.5)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: SudaneseTheme.gold
                                    .withValues(alpha: 0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(stone,
                            width: 38, height: 38),
                        if (isSelected)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: SudaneseTheme.palm,
                              ),
                              child: const Icon(Icons.check,
                                  size: 10, color: Colors.white),
                            ),
                          ),
                        if (isLocked)
                          const Icon(Icons.lock,
                              size: 16,
                              color: SudaneseTheme.clay),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------- طريقة اللعب

class HowToPlaySheet extends StatefulWidget {
  final Strings strings;
  const HowToPlaySheet({super.key, required this.strings});

  @override
  State<HowToPlaySheet> createState() => _HowToPlaySheetState();
}

class _HowToPlaySheetState extends State<HowToPlaySheet> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final pages = [
      (s.howPage1Title, s.howPage1Body, 0),
      (s.howPage2Title, s.howPage2Body, 1),
      (s.howPage3Title, s.howPage3Body, 2),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: SudaneseTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SudaneseTheme.sandDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            s.howToPlay,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: SudaneseTheme.ink,
            ),
          ),
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final page = pages[i];
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    _HowDiagram(page: page.$3),
                    const SizedBox(height: 16),
                    Text(
                      page.$1,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: SudaneseTheme.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      page.$2,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: SudaneseTheme.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pages.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? SudaneseTheme.nile
                      : SudaneseTheme.sandDark,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          PressableButton(
            label: s.close,
            variant: ButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// رسم توضيحي صغير متحرك (لوحة 5×5 مصغرة) لكل صفحة من طريقة اللعب.
class _HowDiagram extends StatefulWidget {
  final int page;
  const _HowDiagram({required this.page});

  @override
  State<_HowDiagram> createState() => _HowDiagramState();
}

class _HowDiagramState extends State<_HowDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cell = 26.0;
    const boardPx = cell * 5;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          width: boardPx + 8,
          height: boardPx + 8,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: SudaneseTheme.tileLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SudaneseTheme.clay),
          ),
          child: Stack(
            children: [
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                ),
                itemCount: 25,
                itemBuilder: (context, index) {
                  final r = index ~/ 5;
                  final c = index % 5;
                  final isCentre = r == 2 && c == 2;
                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isCentre
                          ? SudaneseTheme.centerTile
                          : (r + c) % 2 == 0
                              ? SudaneseTheme.sand
                              : SudaneseTheme.sandDark,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              ),
              ..._diagramStones(t, cell),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _diagramStones(double t, double cell) {
    Offset at(int r, int c) =>
        Offset(c * cell + 3, r * cell + 3);
    const stone = 20.0;
    Widget stoneImg(String asset, Offset pos, {double opacity = 1}) =>
        Positioned(
          left: pos.dx,
          top: pos.dy,
          child: Opacity(
            opacity: opacity,
            child: Image.asset(asset, width: stone, height: stone),
          ),
        );
    switch (widget.page) {
      case 0:
        // التوزيع: 3 أحجار تظهر متتابعة.
        return [
          stoneImg('assets/red_stone.png', at(0, 0),
              opacity: t > 0.1 ? 1 : 0),
          stoneImg('assets/blue_stone.png', at(0, 4),
              opacity: t > 0.35 ? 1 : 0),
          stoneImg('assets/red_stone.png', at(4, 2),
              opacity: t > 0.6 ? 1 : 0),
        ];
      case 1:
        // الحركة: حجر ينزلق إلى الوسطى.
        final slide = Curves.easeInOut.transform(
            ((t - 0.15) / 0.5).clamp(0.0, 1.0));
        final from = at(2, 1);
        final to = at(2, 2);
        final pos = Offset.lerp(from, to, slide)!;
        return [
          stoneImg('assets/red_stone.png', pos),
          stoneImg('assets/blue_stone.png', at(0, 2)),
        ];
      default:
        // الأكل: حجر وسطي يتلاشى بين حجرين.
        final fade = (1 - ((t - 0.3) / 0.4).clamp(0.0, 1.0));
        return [
          stoneImg('assets/red_stone.png', at(2, 1)),
          stoneImg('assets/blue_stone.png', at(2, 2),
              opacity: fade),
          stoneImg('assets/red_stone.png', at(2, 3)),
        ];
    }
  }
}

// ---------------------------------------------------------------- عن اللعبة

class AboutSheet extends StatelessWidget {
  final Strings strings;
  final Future<void> Function(String url) onLaunch;

  const AboutSheet(
      {super.key, required this.strings, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    final s = strings;
    return Container(
      decoration: const BoxDecoration(
        color: SudaneseTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SudaneseTheme.sandDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.aboutGame,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: SudaneseTheme.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            s.aboutBody,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 16),
          PressableButton(
            label: s.contactUs,
            icon: Icons.email,
            onPressed: () => onLaunch(
                'mailto:nubaaxx@gmail.com?subject=${Uri.encodeComponent('استفسار عن لعبة السيجا')}'),
          ),
          const SizedBox(height: 10),
          PressableButton(
            label: 'TikTok @nubax',
            icon: Icons.music_note,
            variant: ButtonVariant.ghost,
            onPressed: () =>
                onLaunch('https://www.tiktok.com/@nubax'),
          ),
        ],
      ),
    );
  }
}
