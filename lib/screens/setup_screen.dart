// شاشة الإعداد "اجلس للعب" (§6.3 + لوحة التصميم):
// شاشة واحدة بلا تمرير عند 390×844. ضد الكمبيوتر: ثلاث كوات
// (ود البلد/الأستاذ/الشيخ) ثم لوحتان مصغرتان ثم صينية الحجارة.
// لاعبان: الصينية للاعب 1 ثم تنزلق وتعود للاعب 2.
// زر "يلا" طبق دائري ثابت أسفل الوسط.
import 'package:flutter/material.dart';

import '../game/seega_ai.dart';
import '../game/sound_manager.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/painters/board.dart';
import '../ui/painters/elder.dart';
import '../ui/painters/pebble.dart';
import '../ui/painters/tabaq.dart';
import '../ui/widgets/niche.dart';
import '../ui/widgets/wood_token.dart';
import 'game_screen.dart';

class SetupScreen extends StatefulWidget {
  final bool vsComputer;

  const SetupScreen({super.key, required this.vsComputer});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with TickerProviderStateMixin {
  Difficulty _difficulty = Difficulty.medium;
  int _boardSize = 5;
  int? _p1Pebble;
  int? _p2Pebble;
  int _step = 0; // لاعبان فقط: 0 = حجر اللاعب 1، 1 = حجر اللاعب 2.
  bool _spinning = false;
  late final AnimationController _pulse;
  late final AnimationController _spin;

  Strings get s => Strings(AppSettings.instance.isArabic);

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    _spin.dispose();
    super.dispose();
  }

  bool get _ready {
    if (widget.vsComputer) return _p1Pebble != null;
    return _p1Pebble != null && _p2Pebble != null;
  }

  /// الكمبيوتر يأخذ حجراً مختلفاً تلقائياً.
  int get _computerPebble {
    if (_p1Pebble == null) return 1;
    return (_p1Pebble! + 3) % SudaneseTheme.pebbles.length;
  }

  void _pickPebble(int index) {
    SoundManager.instance.tap();
    setState(() {
      if (widget.vsComputer) {
        _p1Pebble = index;
      } else if (_step == 0) {
        _p1Pebble = index;
        // انزلاق الصينية وعودتها للاعب 2 بعد لحظة.
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) setState(() => _step = 1);
        });
      } else {
        _p2Pebble = index;
      }
    });
  }

  void _start() {
    if (!_ready || _spinning) return;
    SoundManager.instance.start();
    setState(() => _spinning = true);
    _spin.forward(from: 0).then((_) {
      if (!mounted) return;
      final config = GameConfig(
        boardSize: _boardSize,
        vsComputer: widget.vsComputer,
        difficulty: _difficulty,
        p1Pebble: _p1Pebble ?? 0,
        p2Pebble: widget.vsComputer ? _computerPebble : (_p2Pebble ?? 1),
      );
      Navigator.of(context).pushNamed('/game', arguments: config);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              const RepaintBoundary(
                child: CustomPaint(painter: _SetupMatPainter()),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ---- الأعلى: رجوع + عنوان ----
                      Row(
                        children: [
                          WoodToken(
                            // arrow_back معكوس في RTL فيشير يميناً (→)
                            // كما في اللوحة.
                            icon: Icons.arrow_back,
                            size: 48,
                            tooltip: s.close,
                            onPressed: () {
                              SoundManager.instance.tap();
                              Navigator.of(context).pop();
                            },
                          ),
                          Expanded(
                            child: Text(
                              s.sitToPlay,
                              style: SudaneseTheme.title.copyWith(
                                fontSize: 30,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // ---- الكوات (ضد الكمبيوتر فقط) ----
                      if (widget.vsComputer) ...[
                        _SectionLabel(s.againstWho),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OpponentNiche(
                                kind: ElderKind.young,
                                name: s.elderYoung,
                                level: s.easy,
                                selected:
                                    _difficulty == Difficulty.easy,
                                onTap: () {
                                  SoundManager.instance.tap();
                                  setState(() =>
                                      _difficulty = Difficulty.easy);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OpponentNiche(
                                kind: ElderKind.teacher,
                                name: s.elderTeacher,
                                level: s.medium,
                                selected:
                                    _difficulty == Difficulty.medium,
                                onTap: () {
                                  SoundManager.instance.tap();
                                  setState(() =>
                                      _difficulty = Difficulty.medium);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OpponentNiche(
                                kind: ElderKind.elder,
                                name: s.elderElder,
                                level: s.hard,
                                selected:
                                    _difficulty == Difficulty.hard,
                                onTap: () {
                                  SoundManager.instance.tap();
                                  setState(() =>
                                      _difficulty = Difficulty.hard);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                      // ---- اللوحة ----
                      _SectionLabel(s.boardSection),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _BoardMini(
                              size: 5,
                              caption: s.board5Short,
                              selected: _boardSize == 5,
                              onTap: () {
                                SoundManager.instance.tap();
                                setState(() => _boardSize = 5);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _BoardMini(
                              size: 7,
                              caption: s.board7Short,
                              selected: _boardSize == 7,
                              onTap: () {
                                SoundManager.instance.tap();
                                setState(() => _boardSize = 7);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // ---- صينية الحجارة ----
                      _SectionLabel(widget.vsComputer
                          ? s.yourPebble
                          : (_step == 0
                              ? s.chooseStoneP1First
                              : s.chooseStoneP2First)),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.4),
                              end: Offset.zero,
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: _PebbleTray(
                          key: ValueKey(_step),
                          selected: widget.vsComputer
                              ? _p1Pebble
                              : (_step == 0 ? _p1Pebble : _p2Pebble),
                          locked: widget.vsComputer
                              ? null
                              : (_step == 1 ? _p1Pebble : null),
                          onPick: _pickPebble,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // سطر حجر الكمبيوتر / تغيير حجر اللاعب 1.
                      SizedBox(
                        height: 20,
                        child: Center(
                          child: widget.vsComputer
                              ? (_p1Pebble == null
                                  ? const SizedBox.shrink()
                                  : Text(
                                      s.computerTakes(
                                        SudaneseTheme
                                            .pebbles[_computerPebble]
                                            .nameAr,
                                      ),
                                      style: SudaneseTheme.caption,
                                    ))
                              : (_step == 1
                                  ? GestureDetector(
                                      onTap: () => setState(() {
                                        _step = 0;
                                        _p2Pebble = null;
                                      }),
                                      child: Text(
                                        s.chooseStoneP1First,
                                        style: SudaneseTheme.caption
                                            .copyWith(
                                          color:
                                              SudaneseTheme.tabaqRed,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()),
                        ),
                      ),
                      const Spacer(),
                      // ---- زر يلا (طبق دائري) ----
                      Center(child: _YallaButton(
                        ready: _ready,
                        pulse: _pulse,
                        spin: _spin,
                        onTap: _start,
                      )),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: SudaneseTheme.heading.copyWith(fontSize: 19),
      textAlign: TextAlign.right,
    );
  }
}

/// خلفية الإعداد: برش أغمق قليلاً من الرئيسية.
class _SetupMatPainter extends CustomPainter {
  const _SetupMatPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFD3AC62),
    );
    for (var x = 0.0; x < size.width; x += 6) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = SudaneseTheme.mudBrick.withValues(alpha: 0.10)
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// لوحة مصغرة على لوح كريمي؛ المختارة بإطار أحمر.
class _BoardMini extends StatelessWidget {
  final int size;
  final String caption;
  final bool selected;
  final VoidCallback onTap;

  const _BoardMini({
    required this.size,
    required this.caption,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: SudaneseTheme.cream.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? SudaneseTheme.tabaqRed
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              child: CustomPaint(
                size: const Size(120, 120),
                painter:
                    BoardPainter(size: size, centreOccupied: false),
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                caption,
                style: SudaneseTheme.bodyBold.copyWith(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// صينية الحجارة: 7 حصوات في صينية خشب داكن؛ المختارة
/// ترتفع بتوهج ذهبي، وحجر الطرف الآخر مقفل ومعتم.
class _PebbleTray extends StatelessWidget {
  final int? selected;
  final int? locked;
  final ValueChanged<int> onPick;

  const _PebbleTray({
    super.key,
    required this.selected,
    required this.locked,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: SudaneseTheme.woodDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: SudaneseTheme.hardShadow(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(SudaneseTheme.pebbles.length, (i) {
          final def = SudaneseTheme.pebbles[i];
          final isSelected = selected == i;
          final isLocked = locked == i;
          return GestureDetector(
            onTap: isLocked ? null : () => onPick(i),
            child: AnimatedScale(
              scale: isSelected ? 1.18 : 1.0,
              duration: const Duration(milliseconds: 180),
              child: Opacity(
                opacity: isLocked ? 0.35 : 1.0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: SudaneseTheme.sunGold, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: SudaneseTheme.sunGold
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
                      RepaintBoundary(
                        child: CustomPaint(
                          size: const Size(38, 38),
                          painter: PebblePainter(def: def),
                        ),
                      ),
                      if (isLocked)
                        const Icon(
                          Icons.lock,
                          size: 16,
                          color: SudaneseTheme.cream,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// زر "يلا": طبق دائري 92 بكسل بقرص أحمر في الوسط.
/// جاهز: ينبض. عند النقر: يدور مرة واحدة.
class _YallaButton extends StatelessWidget {
  final bool ready;
  final Animation<double> pulse;
  final Animation<double> spin;
  final VoidCallback onTap;

  const _YallaButton({
    required this.ready,
    required this.pulse,
    required this.spin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = Strings(AppSettings.instance.isArabic);
    return GestureDetector(
      onTap: ready ? onTap : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([pulse, spin]),
        builder: (context, child) {
          final scale = ready ? 1.0 + pulse.value * 0.05 : 1.0;
          return Transform.scale(
            scale: scale,
            child: RotationTransition(
              turns: spin,
              child: Opacity(
                opacity: ready ? 1.0 : 0.45,
                child: child,
              ),
            ),
          );
        },
        child: SizedBox(
          width: 92,
          height: 92,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const RepaintBoundary(
                child: CustomPaint(
                  size: Size(92, 92),
                  painter: TabaqPainter(),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: SudaneseTheme.tabaqRed,
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    s.letsGo,
                    style: SudaneseTheme.display.copyWith(
                      fontSize: 20,
                      color: SudaneseTheme.cream,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
