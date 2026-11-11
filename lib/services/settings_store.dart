// إعدادات اللعبة المحفوظة: الصوت + مستوى الصوت + الاهتزاز + اللغة.
// تُحفظ في shared_preferences وتُحمَّل مرة واحدة عند بدء التطبيق.
// أي فشل في التخزين يُتجاهل بصمت وتُستخدم القيم الافتراضية.
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings instance = AppSettings._();

  AppSettings._();

  bool soundOn = true;
  double volume = 0.8;
  bool hapticsOn = true;
  bool isArabic = true;

  bool _loaded = false;
  bool get loaded => _loaded;

  SharedPreferences? _prefs;

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      soundOn = _prefs!.getBool('soundOn') ?? true;
      volume = _prefs!.getDouble('volume') ?? 0.8;
      hapticsOn = _prefs!.getBool('hapticsOn') ?? true;
      isArabic = _prefs!.getBool('isArabic') ?? true;
    } catch (_) {
      // الافتراضيات تكفي — لا توقف اللعبة بسبب التخزين.
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final p = _prefs ??= await SharedPreferences.getInstance();
      await p.setBool('soundOn', soundOn);
      await p.setDouble('volume', volume);
      await p.setBool('hapticsOn', hapticsOn);
      await p.setBool('isArabic', isArabic);
    } catch (_) {}
  }

  Future<void> setSoundOn(bool value) async {
    if (soundOn == value) return;
    soundOn = value;
    notifyListeners();
    await _save();
  }

  Future<void> setVolume(double value) async {
    volume = value.clamp(0.0, 1.0);
    notifyListeners();
    await _save();
  }

  Future<void> setHapticsOn(bool value) async {
    if (hapticsOn == value) return;
    hapticsOn = value;
    notifyListeners();
    await _save();
  }

  Future<void> setArabic(bool value) async {
    if (isArabic == value) return;
    isArabic = value;
    notifyListeners();
    await _save();
  }
}
