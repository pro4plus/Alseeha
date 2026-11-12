// مدير الصوت v3.0: مجموعة من 6 مشغلات قابلة لإعادة الاستخدام حتى
// تتداخل الأصوات (انزلاق ثم أكل مثلاً)، مع تحميل مسبق لكل الملفات.
// أي صوت مفقود أو فاشل يُتجاهل بصمت — الصوت لا يوقف اللعبة أبداً.
import 'dart:math';

import 'package:just_audio/just_audio.dart';

import '../services/settings_store.dart';

class SoundManager {
  static final SoundManager instance = SoundManager._();

  SoundManager._();

  static const List<String> _files = [
    'ui_tap',
    'select',
    'place1',
    'place2',
    'place3',
    'slide1',
    'slide2',
    'slide3',
    'land',
    'capture1',
    'capture2',
    'capture3',
    'capture_multi',
    'invalid',
    'turn',
    'hint',
    'undo',
    'start',
    'win',
    'lose',
    'draw',
  ];

  static const int _poolSize = 6;

  final List<AudioPlayer?> _pool = List.filled(_poolSize, null);
  final Map<String, AudioSource> _sources = {};
  final Random _random = Random();
  int _next = 0;
  bool _ready = false;

  bool get enabled => AppSettings.instance.soundOn;
  double get volume => AppSettings.instance.volume;

  /// أنشئ المشغلات وحمّل كل الملفات. آمن للاستدعاء من الاختبارات
  /// (الفشل هنا لا يرمي أي استثناء).
  Future<void> init() async {
    if (_ready) return;
    _ready = true;
    for (var i = 0; i < _poolSize; i++) {
      try {
        _pool[i] = AudioPlayer();
      } catch (_) {
        _pool[i] = null;
      }
    }
    for (final name in _files) {
      try {
        _sources[name] =
            AudioSource.asset('assets/sounds/$name.wav');
      } catch (_) {}
    }
    // تحميل مسبق: جهّز أول مشغلين بأكثر الأصوات استعمالاً.
    for (final name in ['ui_tap', 'place1', 'select']) {
      try {
        final p = _pool[0];
        if (p != null && _sources.containsKey(name)) {
          await p.setAudioSource(_sources[name]!);
        }
      } catch (_) {}
    }
  }

  Future<void> _play(String name, {double pitch = 1.0}) async {
    if (!enabled) return;
    final source = _sources[name];
    if (source == null) return;
    final player = _pool[_next];
    _next = (_next + 1) % _poolSize;
    if (player == null) return;
    try {
      await player.setVolume(volume);
      await player.setSpeed(pitch);
      await player.setAudioSource(source);
      await player.play();
    } catch (_) {}
  }

  double _jitterPitch() => 0.96 + _random.nextDouble() * 0.08;

  /// تناوب دائري بين متغيرات الصوت المتكرر (place/slide/capture).
  String _variant(String base) {
    final i = 1 + _random.nextInt(3);
    return '$base$i';
  }

  Future<void> tap() => _play('ui_tap', pitch: _jitterPitch());
  Future<void> select() => _play('select', pitch: _jitterPitch());
  Future<void> place() => _play(_variant('place'), pitch: _jitterPitch());
  Future<void> slide() => _play(_variant('slide'));
  Future<void> land() => _play('land');
  Future<void> capture({bool multi = false, int step = 0}) {
    if (multi) return _play('capture_multi');
    // كل أكل متتابع في نفس الدور أعلى نبرة قليلاً.
    final pitch = (1.0 + step * 0.06).clamp(1.0, 1.18);
    return _play(_variant('capture'), pitch: pitch);
  }

  Future<void> invalid() => _play('invalid');
  Future<void> turn() => _play('turn');
  Future<void> hint() => _play('hint');
  Future<void> undo() => _play('undo');
  Future<void> start() => _play('start');
  Future<void> win() => _play('win');
  Future<void> lose() => _play('lose');
  Future<void> draw() => _play('draw');

  Future<void> dispose() async {
    for (final p in _pool) {
      try {
        await p?.dispose();
      } catch (_) {}
    }
  }
}
