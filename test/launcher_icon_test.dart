// يولّد أيقونة المشغّل من كود الرسم (طبق على مربع طيني)
// ويكتبها في android/app/src/main/res/mipmap-*.
// إعادة تشغيل الاختبار حتمية: نفس المدخلات تعطي نفس الملفات.
// لا يُستورد أي صورة: الطبق مرسوم بـ TabaqPainter.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:alseeja/theme/sudanese_theme.dart';
import 'package:alseeja/ui/painters/tabaq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('launcher icon is generated from TabaqPainter', () async {
    final root = _repoRoot();
    const sizes = {
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    };
    for (final entry in sizes.entries) {
      final png = await _renderLegacy(entry.value);
      final file = File(
        '$root/android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
      );
      await file.writeAsBytes(png);
      expect(await file.exists(), isTrue);
      expect(_isPng(await file.readAsBytes()), isTrue);
    }
    // المقدمة للأيقونة التكيفية: طبق على شفافية (432×432،
    // الطبق في المنطقة الآمنة الوسطى 60%).
    final fg = await _renderForeground();
    for (final entry in sizes.entries) {
      final file = File(
        '$root/android/app/src/main/res/mipmap-${entry.key}/ic_launcher_foreground.png',
      );
      await file.writeAsBytes(fg);
      expect(await file.exists(), isTrue);
      expect(_isPng(await file.readAsBytes()), isTrue);
    }
  });
}

String _repoRoot() {
  final cwd = Directory.current.path;
  if (File('$cwd/pubspec.yaml').existsSync()) return cwd;
  // احتياط: مسار ملف الاختبار.
  final script = File(Platform.script.toFilePath());
  return script.parent.parent.path;
}

/// الأيقونة القديمة: مربع طيني بحواف مدورة والطبق في وسطه (78%).
Future<Uint8List> _renderLegacy(int size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final rrect = RRect.fromRectAndRadius(
    Offset.zero & Size(size.toDouble(), size.toDouble()),
    Radius.circular(size * 0.22),
  );
  canvas.drawRRect(rrect, Paint()..color = SudaneseTheme.mudBrick);
  final d = size * 0.78;
  final off = (size - d) / 2;
  canvas.save();
  canvas.translate(off, off);
  const TabaqPainter().paint(canvas, Size(d, d));
  canvas.restore();
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

/// المقدمة التكيفية: طبق على شفافية.
Future<Uint8List> _renderForeground() async {
  const size = 432;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const d = size * 0.60;
  const off = (size - d) / 2;
  canvas.save();
  canvas.translate(off, off);
  const TabaqPainter().paint(canvas, const Size(d, d));
  canvas.restore();
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

bool _isPng(Uint8List bytes) =>
    bytes.length > 8 &&
    bytes[0] == 0x89 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x4E &&
    bytes[3] == 0x47 &&
    bytes[4] == 0x0D &&
    bytes[5] == 0x0A &&
    bytes[6] == 0x1A &&
    bytes[7] == 0x0A;
