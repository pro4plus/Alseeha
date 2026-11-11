// الشاشة الرئيسية + شاشة الإعداد + طريقة اللعب + عن اللعبة.
// التصميم: خلفية رملية، شريط نوبي ملوّن، وأزرار كبيرة مريحة.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../game/seega_ai.dart';
import '../l10n/strings.dart';
import '../theme/sudanese_theme.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isArabic = true;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showHowToPlay() {
    final s = Strings(isArabic);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.howToPlay),
        content: SingleChildScrollView(child: Text(s.howToPlayBody)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.close),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    final s = Strings(isArabic);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.aboutGame),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.aboutBody),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => _launch('mailto:nubaaxx@gmail.com'
                      '?subject=${Uri.encodeComponent('استفسار عن لعبة السيجا')}'),
                  child: Text(s.contactUs),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings(isArabic);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.appTitle),
        actions: [
          TextButton(
            onPressed: () => setState(() => isArabic = !isArabic),
            child: Text(
              isArabic ? 'EN' : 'عربي',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SudaneseTheme.nubianStrip(height: 10),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Image.asset('assets/seja.png', width: 170, height: 110,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.grid_4x4,
                          size: 90,
                          color: SudaneseTheme.clay)),
                  const SizedBox(height: 8),
                  Text(
                    s.appTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.tagline,
                    style: const TextStyle(
                        fontSize: 15, color: SudaneseTheme.clay),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openSetup(vsComputer: true),
                      icon: const Icon(Icons.smart_toy),
                      label: Text(s.playVsComputer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SudaneseTheme.nile,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openSetup(vsComputer: false),
                      icon: const Icon(Icons.people),
                      label: Text(s.playVsFriend),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SudaneseTheme.palm,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showHowToPlay,
                      icon: const Icon(Icons.help_outline),
                      label: Text(s.howToPlay),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: _showAbout,
                    child: Text(s.aboutGame),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () =>
                        _launch('https://www.tiktok.com/@nubax'),
                    child: Image.asset('assets/tiktok.png',
                        width: 48, height: 48,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.music_note, size: 40)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SudaneseTheme.nubianStrip(height: 10),
        ],
      ),
    );
  }

  void _openSetup({required bool vsComputer}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetupScreen(
          isArabic: isArabic,
          vsComputer: vsComputer,
        ),
      ),
    );
  }
}

class SetupScreen extends StatefulWidget {
  final bool isArabic;
  final bool vsComputer;
  const SetupScreen(
      {super.key, required this.isArabic, required this.vsComputer});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int gridSize = 5;
  Difficulty difficulty = Difficulty.medium;
  String? playerOneStone;
  String? playerTwoStone;

  final List<String> stoneAssets = [
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

  Widget _stonePicker({
    required String label,
    required String? selected,
    required bool isPlayerOne,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          children: stoneAssets.map((stone) {
            final isSelected = selected == stone;
            return GestureDetector(
              onTap: () => _selectStone(stone, isPlayerOne),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? SudaneseTheme.goldLight
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? SudaneseTheme.gold
                        : Colors.transparent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(stone, width: 48, height: 48),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _difficultyCard(
      Difficulty d, String title, String desc, IconData icon) {
    final selected = difficulty == d;
    return GestureDetector(
      onTap: () => setState(() => difficulty = d),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? SudaneseTheme.goldLight : Colors.white,
          border: Border.all(
              color: selected ? SudaneseTheme.gold : Colors.grey.shade300,
              width: selected ? 3 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected
                    ? SudaneseTheme.clay
                    : Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  Text(desc, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: SudaneseTheme.palm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings(widget.isArabic);
    final canStart = playerOneStone != null && playerTwoStone != null;
    return Scaffold(
      appBar: AppBar(title: Text(s.startGame)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(s.chooseBoard,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _sizeButton(5, s.board5),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _sizeButton(7, s.board7),
                ),
              ],
            ),
            if (widget.vsComputer) ...[
              const SizedBox(height: 24),
              Text(s.chooseDifficulty,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _difficultyCard(
                  Difficulty.easy, s.easy, s.easyDesc, Icons.sentiment_satisfied),
              const SizedBox(height: 8),
              _difficultyCard(Difficulty.medium, s.medium, s.mediumDesc,
                  Icons.psychology),
              const SizedBox(height: 8),
              _difficultyCard(Difficulty.hard, s.hard, s.hardDesc,
                  Icons.emoji_events),
            ],
            const SizedBox(height: 24),
            Text(s.chooseStones,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _stonePicker(
              label: widget.vsComputer
                  ? s.computerStone
                  : s.player1Stone,
              selected: playerOneStone,
              isPlayerOne: true,
            ),
            const SizedBox(height: 12),
            _stonePicker(
              label: widget.vsComputer
                  ? s.computer
                  : s.player2Stone,
              selected: playerTwoStone,
              isPlayerOne: false,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: canStart
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            isArabic: widget.isArabic,
                            gridSize: gridSize,
                            vsComputer: widget.vsComputer,
                            difficulty: difficulty,
                            playerOneStone: playerOneStone!,
                            playerTwoStone: playerTwoStone!,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: SudaneseTheme.sudanRed,
              ),
              child: Text(s.startPlaying),
            ),
            if (!canStart)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  s.chooseStones,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: SudaneseTheme.clay),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sizeButton(int size, String label) {
    final selected = gridSize == size;
    return ElevatedButton(
      onPressed: () => setState(() => gridSize = size),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selected ? SudaneseTheme.nile : Colors.grey.shade300,
        foregroundColor:
            selected ? Colors.white : SudaneseTheme.ink,
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}
