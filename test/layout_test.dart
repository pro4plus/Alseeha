// تخطيط v4 (§9): كل شاشة يجب أن تتسع بلا تجاوز عند
// عرض 360 بكسل وخط مكبّر 130%.
import 'package:alseeja/game/seega_ai.dart';
import 'package:alseeja/game/turn_controller.dart';
import 'package:alseeja/main.dart';
import 'package:alseeja/screens/game_screen.dart';
import 'package:alseeja/screens/setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _setSmallScreen(WidgetTester tester) async {
  // 360×844 بكسل منطقي @2x.
  tester.view.physicalSize = const Size(720, 1688);
  tester.view.devicePixelRatio = 2.0;
  tester.platformDispatcher.textScaleFactorTestValue = 1.3;
  addTearDown(tester.view.reset);
  addTearDown(
      tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  testWidgets('الرئيسية: لا تجاوز عند 360 بكسل وخط 130%',
      (WidgetTester tester) async {
    await _setSmallScreen(tester);
    await tester.pumpWidget(const SeegaGame());
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('العب ضد الكمبيوتر'), findsOneWidget);
    expect(find.text('لاعبان على جهاز واحد'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('الإعداد ضد الكمبيوتر: لا تجاوز',
      (WidgetTester tester) async {
    await _setSmallScreen(tester);
    await tester.pumpWidget(
      const MaterialApp(home: SetupScreen(vsComputer: true)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('اجلس للعب'), findsOneWidget);
    expect(find.text('يلا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('الإعداد لاعبان: لا تجاوز',
      (WidgetTester tester) async {
    await _setSmallScreen(tester);
    await tester.pumpWidget(
      const MaterialApp(home: SetupScreen(vsComputer: false)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('اجلس للعب'), findsOneWidget);
    expect(find.text('يلا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('اللعب في التوزيع: لا تجاوز',
      (WidgetTester tester) async {
    await _setSmallScreen(tester);
    final controller = TurnController(
      boardSize: 5,
      vsComputer: true,
      difficulty: Difficulty.easy,
      aiDelayMs: 0,
      placementDelayMs: 0,
      debugAiSeed: 1,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          config: const GameConfig(
            boardSize: 5,
            vsComputer: true,
            difficulty: Difficulty.easy,
            p1Pebble: 0,
            p2Pebble: 1,
          ),
          debugController: controller,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('ضع 3 أحجار'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('اللعب في الحركة: لا تجاوز',
      (WidgetTester tester) async {
    await _setSmallScreen(tester);
    final controller = TurnController(
      boardSize: 5,
      vsComputer: false,
    );
    addTearDown(controller.dispose);
    final engine = controller.engine;
    engine.board[1][1] = 1;
    engine.board[1][4] = 1;
    engine.board[1][2] = 2;
    engine.placingPhase = false;
    engine.currentPlayer = 1;
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          config: const GameConfig(
            boardSize: 5,
            vsComputer: false,
            p1Pebble: 0,
            p2Pebble: 1,
          ),
          debugController: controller,
        ),
      ),
    );
    controller.debugSyncAfterExternalSetup();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('الدور: اللاعب 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
