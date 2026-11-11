// ورقة الإعدادات (منبثقة من الأسفل): الصوت + مستوى الصوت، الاهتزاز، اللغة.
// كلها محفوظة في AppSettings (shared_preferences).
import 'package:flutter/material.dart';

import '../game/haptics.dart';
import '../game/sound_manager.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';

class SettingsSheet extends StatelessWidget {
  final Strings strings;

  const SettingsSheet({super.key, required this.strings});

  static Future<void> show(BuildContext context, Strings strings) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsSheet(strings: strings),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    return Container(
      decoration: const BoxDecoration(
        color: SudaneseTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: AnimatedBuilder(
        animation: settings,
        builder: (context, child) {
          return Column(
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
                strings.settings,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: SudaneseTheme.ink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // الصوت.
              SwitchListTile(
                title: Text(strings.sound,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                value: settings.soundOn,
                activeThumbColor: SudaneseTheme.nile,
                onChanged: (v) async {
                  await settings.setSoundOn(v);
                  if (v) SoundManager.instance.tap();
                },
              ),
              if (settings.soundOn)
                Row(
                  children: [
                    const Icon(Icons.volume_down,
                        color: SudaneseTheme.nile),
                    Expanded(
                      child: Slider(
                        value: settings.volume,
                        onChanged: (v) => settings.setVolume(v),
                        activeColor: SudaneseTheme.nile,
                        inactiveColor: SudaneseTheme.sandDark,
                      ),
                    ),
                    const Icon(Icons.volume_up,
                        color: SudaneseTheme.nile),
                  ],
                ),
              const Divider(),
              // الاهتزاز.
              SwitchListTile(
                title: Text(strings.haptics,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                value: settings.hapticsOn,
                activeThumbColor: SudaneseTheme.nile,
                onChanged: (v) async {
                  await settings.setHapticsOn(v);
                  if (v) Haptics.light();
                },
              ),
              const Divider(),
              // اللغة.
              ListTile(
                title: Text(strings.language,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                trailing: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: true,
                      label: Text(strings.arabic),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text(strings.english),
                    ),
                  ],
                  selected: {settings.isArabic},
                  onSelectionChanged: (sel) async {
                    await settings.setArabic(sel.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? SudaneseTheme.nile
                          : null,
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? Colors.white
                          : SudaneseTheme.ink,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
