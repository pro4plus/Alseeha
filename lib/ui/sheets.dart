// الصفحات المشتركة: الإعدادات، طريقة اللعب، عن اللعبة.
// كلها صفحات مقوّسة (§5.3) — لا حوارات Material افتراضية.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../game/sound_manager.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import 'painters/tabaq.dart';
import 'widgets/arched_sheet.dart';
import 'widgets/plank_button.dart';

// ------------------------------------------------------------ مفتاح مخصص

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 56,
        height: 30,
        decoration: BoxDecoration(
          color: value
              ? SudaneseTheme.palmGreen
              : SudaneseTheme.sandDark,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: SudaneseTheme.earthBlack, width: 1.5),
        ),
        child: AnimatedAlign(
          alignment:
              value ? Alignment.centerLeft : Alignment.centerRight,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: SudaneseTheme.cream,
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ منزلق مخصص

class _VolumeSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _VolumeSlider({required this.value, required this.onChanged});

  @override
  State<_VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<_VolumeSlider> {
  double? _dragValue;

  double get _v => _dragValue ?? widget.value;

  void _update(Offset local, double width) {
    final v = (local.dx / width).clamp(0.0, 1.0);
    setState(() => _dragValue = v);
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragStart: (d) =>
              _update(d.localPosition, width),
          onHorizontalDragUpdate: (d) =>
              _update(d.localPosition, width),
          onHorizontalDragEnd: (_) =>
              setState(() => _dragValue = null),
          onTapDown: (d) => _update(d.localPosition, width),
          child: SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: SudaneseTheme.sandDark,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: SudaneseTheme.earthBlack, width: 1),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: _v,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: SudaneseTheme.sunGold,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(_v * 2 - 1, 0),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SudaneseTheme.tabaqRed,
                      border: Border.all(
                          color: SudaneseTheme.cream, width: 2),
                      boxShadow: SudaneseTheme.hardShadow(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------ الإعدادات

Future<void> showSettingsSheet(
    BuildContext context, Strings s) async {
  final settings = AppSettings.instance;
  await showArchedSheet<void>(
    context: context,
    child: AnimatedBuilder(
      animation: settings,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.settings,
              style: SudaneseTheme.title.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.sound, style: SudaneseTheme.bodyBold),
                _Toggle(
                  value: settings.soundOn,
                  onChanged: (v) async {
                    await settings.setSoundOn(v);
                    if (v) SoundManager.instance.tap();
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(s.volume, style: SudaneseTheme.bodyBold),
            const SizedBox(height: 4),
            _VolumeSlider(
              value: settings.volume,
              onChanged: (v) => settings.setVolume(v),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.haptics, style: SudaneseTheme.bodyBold),
                _Toggle(
                  value: settings.hapticsOn,
                  onChanged: (v) => settings.setHapticsOn(v),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(s.language, style: SudaneseTheme.bodyBold),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _LangButton(
                    label: s.arabic,
                    selected: settings.isArabic,
                    onTap: () => settings.setArabic(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LangButton(
                    label: s.english,
                    selected: !settings.isArabic,
                    onTap: () => settings.setArabic(false),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? SudaneseTheme.tabaqRed
              : SudaneseTheme.cream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? SudaneseTheme.tabaqRed
                : SudaneseTheme.straw,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: SudaneseTheme.bodyBold.copyWith(
            color: selected ? SudaneseTheme.cream : SudaneseTheme.ink,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ طريقة اللعب

enum _DiagramKind { placement, movement, capture }

class _MiniDiagram extends StatelessWidget {
  final _DiagramKind kind;

  const _MiniDiagram({required this.kind});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(150, 110),
        painter: _DiagramPainter(kind: kind),
      ),
    );
  }
}

class _DiagramPainter extends CustomPainter {
  final _DiagramKind kind;

  _DiagramPainter({required this.kind});

  @override
  void paint(Canvas canvas, Size size) {
    // لوحة مصغرة 3×3.
    const cell = 34.0;
    final ox = (size.width - cell * 3) / 2;
    final oy = (size.height - cell * 3) / 2;
    final pit = Paint()..color = SudaneseTheme.pitDark;
    final ring = Paint()
      ..color = SudaneseTheme.sandDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        final p = Offset(ox + (c + 0.5) * cell, oy + (r + 0.5) * cell);
        canvas.drawCircle(p, 13, pit);
        canvas.drawCircle(p, 13, ring);
      }
    }
    Offset at(int r, int c) =>
        Offset(ox + (c + 0.5) * cell, oy + (r + 0.5) * cell);
    void pebble(int r, int c, Color color) {
      final p = at(r, c);
      canvas.drawCircle(p, 11, Paint()..color = color);
      canvas.drawOval(
        Rect.fromCenter(
            center: p + const Offset(-3, -4), width: 7, height: 4),
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }

    const indigo = SudaneseTheme.indigo;
    const clay = Color(0xFFB4552D);
    switch (kind) {
      case _DiagramKind.placement:
        pebble(0, 0, indigo);
        pebble(0, 2, indigo);
        pebble(2, 1, indigo);
        // خانات فاضية مميزة بحلقات خضراء متقطعة.
        for (final (r, c) in [(1, 1), (2, 2)]) {
          paintDashedCircle(
            canvas,
            at(r, c),
            15,
            SudaneseTheme.palmGreen,
            2,
            dashes: 10,
          );
        }
        break;
      case _DiagramKind.movement:
        pebble(1, 0, indigo);
        pebble(2, 2, clay);
        final from = at(1, 0);
        final to = at(1, 1);
        final arrow = Paint()
          ..color = SudaneseTheme.sunGold
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(from, to, arrow);
        canvas.drawPath(
          Path()
            ..moveTo(to.dx + 8, to.dy)
            ..lineTo(to.dx - 2, to.dy - 6)
            ..lineTo(to.dx - 2, to.dy + 6)
            ..close(),
          Paint()..color = SudaneseTheme.sunGold,
        );
        break;
      case _DiagramKind.capture:
        pebble(1, 0, indigo);
        pebble(1, 2, indigo);
        pebble(1, 1, clay);
        // علامة الأكل على الحجر المحصور.
        final p = at(1, 1);
        final x = Paint()
          ..color = SudaneseTheme.tabaqRed
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p + const Offset(-6, -6), p + const Offset(6, 6), x);
        canvas.drawLine(p + const Offset(-6, 6), p + const Offset(6, -6), x);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<void> showHowToPlaySheet(
    BuildContext context, Strings s) async {
  final pages = [
    (s.howPage1Title, s.howPage1Body, _DiagramKind.placement),
    (s.howPage2Title, s.howPage2Body, _DiagramKind.movement),
    (s.howPage3Title, s.howPage3Body, _DiagramKind.capture),
  ];
  var page = 0;
  await showArchedSheet<void>(
    context: context,
    child: StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.howToPlay,
              style: SudaneseTheme.title.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => page = i),
                itemBuilder: (context, i) {
                  final (title, body, kind) = pages[i];
                  return Column(
                    children: [
                      _MiniDiagram(kind: kind),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: SudaneseTheme.heading,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            body,
                            style: SudaneseTheme.body,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                return Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == page
                        ? SudaneseTheme.tabaqRed
                        : SudaneseTheme.sandDark,
                  ),
                );
              }),
            ),
          ],
        );
      },
    ),
  );
}

// ------------------------------------------------------------ عن اللعبة

Future<void> showAboutSheet(BuildContext context, Strings s) async {
  Future<void> openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  await showArchedSheet<void>(
    context: context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.aboutGame,
          style: SudaneseTheme.title.copyWith(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          s.aboutBody,
          style: SudaneseTheme.body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Text(
          s.threeLevels,
          style: SudaneseTheme.bodyBold,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${s.easyDesc} · ${s.mediumDesc} · ${s.hardDesc}',
          style: SudaneseTheme.caption,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        PlankButton(
          label: s.contactUs,
          caption: 'nubaaxx@gmail.com',
          kind: PlankKind.dark,
          onPressed: () => openUrl('mailto:nubaaxx@gmail.com'),
        ),
        const SizedBox(height: 10),
        PlankButton(
          label: s.tiktokLink,
          caption: 'https://www.tiktok.com/@nubax',
          kind: PlankKind.dark,
          onPressed: () =>
              openUrl('https://www.tiktok.com/@nubax'),
        ),
      ],
    ),
  );
}
