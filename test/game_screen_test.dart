// اختبارات شاشة اللعب v3.0 (واجهة):
//  * عطل التجمد عبر الواجهة: بعد انتهاء التوزيع والدور للكمبيوتر،
//    يجب أن يتحرك الكمبيوتر وتظهر لافتة "دورك" (لا تجمد).
//  * شاشة النتيجة: أكل آخر حجر للخصم يعرض "مبروووك!" و"العب تاني".
import 'package:alseeja/game/seega_ai.dart';
import 'package:alseeja/game/turn_controller.dart';
import 'package:alseeja/screens/game_screen.dart';
import 'package:alseeja/ui/board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'turn_controller_test.dart' show deadlockPlacements;

const String p1Stone = 'assets/red_stone.png';
const String p2Stone = 'assets/blue_stone.png';

void main() {
  testWidgets('التجمد عبر الواجهة: الكمبيوتر يتحرك بعد التوزيع',
      (WidgetTester tester) async {
    final controller = TurnController(
      boardSize: 5,
      vsComputer: true,
      difficulty: Difficulty.easy,
      aiDelayMs: 0,
      placementDelayMs: 0,
      debugAiSeed: 1,
    );
    addTearDown(controller.dispose);

    for (final p in deadlockPlacements) {
      controller.engine.placeStone(p[0], p[1]);
    }
    expect(controller.engine.placingPhase, isFalse);
    expect(controller.engine.currentPlayer, 2);

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          config: const GameConfig(
            boardSize: 5,
            vsComputer: true,
            difficulty: Difficulty.easy,
            p1Asset: p1Stone,
            p2Asset: p2Stone,
          ),
          debugController: controller,
        ),
      ),
    );
    controller.debugSyncAfterExternalSetup();
    await tester.pump();

    // دع الذكاء يتحرك عدة دورات حتى يعود الدور للاعب البشري.
    var yourTurnShown = false;
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 400));
      if (find.text('دورك').evaluate().isNotEmpty) {
        yourTurnShown = true;
        break;
      }
    }
    expect(controller.engine.lastMove, isNotNull,
        reason: 'الكمبيوتر لم يحرّك إطلاقاً — اللعبة تجمدت');
    expect(yourTurnShown, isTrue,
        reason: 'لافتة "دورك" لم تظهر — الدور لم يعد للاعب البشري');
  });

  testWidgets('شاشة النتيجة: أكل آخر حجر يعرض الفوز',
      (WidgetTester tester) async {
    final controller = TurnController(
      boardSize: 5,
      vsComputer: false,
    );
    addTearDown(controller.dispose);

    // اللاعب 1 في (1,1) و(1,4)، واللاعب 2 بحجر وحيد في (1,2).
    // حركة (1,4) ← (1,3) تحصر (1,2) بين (1,1) و(1,3) فتأكله.
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
            p1Asset: p1Stone,
            p2Asset: p2Stone,
          ),
          debugController: controller,
        ),
      ),
    );
    controller.debugSyncAfterExternalSetup();
    await tester.pump();
    expect(find.text('اللاعب 1 — الدور'), findsOneWidget);

    // انقر الحجر ثم الوجهة عبر إحداثيات اللوحة.
    final boardRect = tester.getRect(find.byType(BoardView));
    final cell = (boardRect.width - 16) / 5;
    Offset centreOf(int r, int c) => boardRect.topLeft +
        Offset(8 + (c + 0.5) * cell, 8 + (r + 0.5) * cell);

    await tester.tapAt(centreOf(1, 4));
    await tester.pump();
    await tester.tapAt(centreOf(1, 3));
    await tester.pump();
    // انزلاق (240ms) + أكل (320ms) + استقرار.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('اللاعب 1 فاز!'), findsOneWidget);
    expect(find.text('العب تاني'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
  });
}
