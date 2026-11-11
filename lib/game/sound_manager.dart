// مدير الصوت: يشغّل الأصوات الموجودة، ويفشل بصمت إذا غاب ملف،
// حتى لا تتوقف اللعبة أبداً بسبب الصوت.
import 'package:just_audio/just_audio.dart';

class SoundManager {
  final AudioPlayer _player = AudioPlayer();
  bool enabled = true;
  String? _lastAsset;

  Future<void> _play(String asset) async {
    if (!enabled) return;
    try {
      // إعادة استخدام نفس المشغل؛ إعادة تعيين الأصل فقط عند التغيير.
      if (_lastAsset != asset) {
        await _player.setAsset(asset);
        _lastAsset = asset;
      } else {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    } catch (_) {
      // الصوت تجميلي — تجاهل الخطأ تماماً.
    }
  }

  Future<void> place() => _play('assets/sounds/place.wav');
  Future<void> select() => _play('assets/sounds/select.wav');
  Future<void> move() => _play('assets/sounds/move.mp3');
  Future<void> eat() => _play('assets/sounds/eat.mp3');
  Future<void> win() => _play('assets/sounds/win.wav');
  Future<void> lose() => _play('assets/sounds/lose.wav');
  Future<void> invalid() => _play('assets/sounds/invalid.wav');
  Future<void> start() => _play('assets/sounds/start.wav');

  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (_) {}
  }
}
