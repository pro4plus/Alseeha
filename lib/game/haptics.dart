// اهتزازات اللعبة: كل حدث صوتي له ما يقابله من الاهتزاز.
// تحترم مفتاح الاهتزاز، وتفشل بصمت إذا لم يدعم الجهاز ذلك.
import 'dart:async';

import 'package:flutter/services.dart';

import '../services/settings_store.dart';

class Haptics {
  static bool get enabled => AppSettings.instance.hapticsOn;

  static Future<void> _run(Future<void> Function() fn) async {
    if (!enabled) return;
    try {
      await fn();
    } catch (_) {}
  }

  /// نقرة خفيفة عند الاختيار.
  static Future<void> select() =>
      _run(() => HapticFeedback.selectionClick());

  /// أثر خفيف عند وضع حجر أو هبوطه.
  static Future<void> light() => _run(() => HapticFeedback.lightImpact());

  /// أثر متوسط عند الأكل.
  static Future<void> medium() =>
      _run(() => HapticFeedback.mediumImpact());

  /// أثران متوسطان سريعان عند الأكل المتعدد.
  static Future<void> multiCapture() => _run(() async {
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 90));
        await HapticFeedback.mediumImpact();
      });

  /// أثر قوي عند الحركة غير القانونية.
  static Future<void> heavy() => _run(() => HapticFeedback.heavyImpact());

  /// نمط نجاح قصير عند الفوز: قوي ثم متوسط ثم خفيف.
  static Future<void> win() => _run(() async {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 120));
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 120));
        await HapticFeedback.lightImpact();
      });
}
