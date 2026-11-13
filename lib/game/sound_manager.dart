// مدير الصوت: ستة مشغلات متوازية حتى تتداخل أصوات الحركة والأكل بدون قطع بعضها.
// أي فشل في جهاز الصوت يُتجاهل؛ المؤثرات لا توقف اللعب.
import 'dart:math';

import 'package:just_audio/just_audio.dart';

import '../services/settings_store.dart';

class SoundManager {
  static final SoundManager instance = SoundManager._();

  SoundManager._();

  static const List<String> _files = [
    'ui_tap', 'select', 'place1', 'place2', 'place3',
    'slide1', 'slide2', 'slide3', 'land',
    'capture1', 'capture2', 'capture3', 'capture_multi',
    'invalid', 'turn', 'hint', 'undo', 'start', 'win', 'lose', 'draw',
  ];

  static const int _poolSize = 6;

  final List<AudioPlayer?> _pool = List<AudioPlayer?>.filled(_poolSize, null);
  final Map<String, AudioSource> _sources = <String, AudioSource>{};
  final Random _random = Random();
  Future<void>? _initFuture;
  int _next = 0;
  bool _ready = false;

  bool get enabled => AppSettings.instance.soundOn;
  double get volume => AppSettings.instance.volume.clamp(0.0, 1.0).toDouble();

  /// التهيئة قابلة للاستدعاء عدة مرات، لكن التنفيذ يحدث مرة واحدة فقط.
  Future<void> init() => _initFuture ??= _initOnce();

  Future<void> _initOnce() async {
    for (var i = 0; i < _poolSize; i++) {
      try {
        _pool[i] = AudioPlayer();
      } catch (_) {
        _pool[i] = null;
      }
    }
    for (final name in _files) {
      try {
        _sources[name] = AudioSource.asset('assets/sounds/$name.wav');
      } catch (_) {
        // يبقى الاسم غير متاح فقط، وتستمر بقية الأصوات.
      }
    }
    _ready = true;
  }

  Future<void> _play(String name, {double pitch = 1.0}) async {
    // التهيئة تتم مرة واحدة في main بعد تهيئة Flutter binding.
    // لا نبدأ just_audio تلقائيًا من اختبارات المحرك أو callbacks مبكرة.
    if (!enabled || !_ready) return;
    final source = _sources[name];
    if (source == null) return;
    final player = _pool[_next];
    _next = (_next + 1) % _poolSize;
    if (player == null) return;
    try {
      await player.setAudioSource(source);
      await player.setVolume(volume);
      await player.setSpeed(pitch.clamp(0.85, 1.2).toDouble());
      await player.play();
    } catch (_) {
      // الصوت تحسين اختياري؛ لا نسمح له بإفشال الحركة.
    }
  }

  double _jitterPitch() => 0.96 + _random.nextDouble() * 0.08;

  String _variant(String base) => '$base${1 + _random.nextInt(3)}';

  Future<void> tap() => _play('ui_tap', pitch: _jitterPitch());
  Future<void> select() => _play('select', pitch: _jitterPitch());
  Future<void> place() => _play(_variant('place'), pitch: _jitterPitch());
  Future<void> slide() => _play(_variant('slide'));
  Future<void> land() => _play('land');

  Future<void> capture({bool multi = false, int step = 0}) {
    if (multi) return _play('capture_multi');
    final pitch = (1.0 + step * 0.06).clamp(1.0, 1.18).toDouble();
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
    final players = List<AudioPlayer?>.from(_pool);
    for (final player in players) {
      try {
        await player?.dispose();
      } catch (_) {}
    }
    for (var i = 0; i < _pool.length; i++) {
      _pool[i] = null;
    }
    _sources.clear();
    _ready = false;
    _initFuture = null;
    _next = 0;
  }
}
