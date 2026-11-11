// اختبارات TurnController v3.0:
//  * عطل التجمد في v2.0: انتهاء التوزيع والدور للكمبيوتر.
//  * قانون التمرير: لاعب بلا حركة يُمرَّر دوره.
import 'package:alseeja/game/seega_ai.dart';
import 'package:alseeja/game/turn_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// لوحة التجمد: بعد التوزيع تكون كل الخانات الأربع المجاورة للوسطى
/// للكمبيوتر (اللاعب 2)، فلا حركة للاعب 1، ويبدأ الكمبيوتر.
/// ترتيب التوزيع (كتل من 3 بالتناوب، كما يفعل المحرك) — 24 حجراً كاملة:
/// P1: (0,0)(0,1)(0,2) | P2: (1,2)(2,1)(2,3) | P1: (0,3)(0,4)(1,0) |
/// P2: (3,2)(3,1)(3,3) | P1: (1,1)(1,3)(1,4) | P2: (3,4)(4,0)(4,1) |
/// P1: (2,0)(2,4)(3,0) | P2: (4,2)(4,3)(4,4)
const List<List<int>> deadlockPlacements = [
  [0, 0], [0, 1], [0, 2],
  [1, 2], [2, 1], [2, 3],
  [0, 3], [0, 4], [1, 0],
  [3, 2], [3, 1], [3, 3],
  [1, 1], [1, 3], [1, 4],
  [3, 4], [4, 0], [4, 1],
  [2, 0], [2, 4], [3, 0],
  [4, 2], [4, 3], [4, 4],
];

void main() {
  test('التجمد: انتهاء التوزيع والدور للكمبيوتر لا يجمّد اللعبة',
      () async {
    final controller = TurnController(
      boardSize: 5,
      vsComputer: true,
      difficulty: Difficulty.easy,
      aiDelayMs: 0,
      placementDelayMs: 0,
      debugAiSeed: 1,
    );
    addTearDown(controller.dispose);

    // جهّز لوحة التجمد مباشرة عبر المحرك.
    for (final p in deadlockPlacements) {
      expect(controller.engine.placeStone(p[0], p[1]), isTrue);
    }
    expect(controller.engine.placingPhase, isFalse);
    expect(controller.engine.count(1), 12);
    expect(controller.engine.count(2), 12);
    // قانون v1.0 لأول متحرك: اللاعب 1 بلا حركة، فيبدأ اللاعب 2.
    expect(controller.engine.currentPlayer, 2);
    expect(controller.engine.hasLegalMoves(1), isFalse);
    expect(controller.engine.hasLegalMoves(2), isTrue);

    // زامن آلة الحالة (كما يفعل انتهاء التوزيع الطبيعي).
    controller.debugSyncAfterExternalSetup();
    expect(controller.phase, TurnPhase.awaitingAI);

    // الكمبيوتر يجب أن يتحرك عدة دورات متتالية دون تجمد.
    final seenMoves = <String>{};
    for (var i = 0; i < 5; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      // بعد مؤقت الذكاء: الحركة في مرحلة التحريك المتحرك.
      expect(controller.phase, TurnPhase.animating,
          reason: 'الدورة $i: الكمبيوتر لم يحرّك — اللعبة تجمدت');
      final move = controller.engine.lastMove;
      expect(move, isNotNull);
      seenMoves.add(move.toString());
      // محاكاة انتهاء حركة اللوحة.
      controller.finishAnimation();
      expect(
        controller.phase,
        anyOf(TurnPhase.awaitingHuman, TurnPhase.awaitingAI),
        reason: 'الدورة $i: آلة الحالة لم تستقر بعد الحركة',
      );
      if (controller.phase == TurnPhase.awaitingHuman) break;
    }
    expect(seenMoves.length, greaterThanOrEqualTo(1));
  });

  test('قانون التمرير: لاعب بلا حركة يُمرَّر دوره للخصم', () async {
    final controller = TurnController(
      boardSize: 5,
      vsComputer: false,
    );
    addTearDown(controller.dispose);

    // اللاعب 2 في (0,0) محصور بين حجري اللاعب 1 في (0,1) و(1,0).
    // اللاعب 1 لديه حجر في (2,2) يستطيع التحرك إلى (2,3).
    final engine = controller.engine;
    engine.board[0][0] = 2;
    engine.board[0][1] = 1;
    engine.board[1][0] = 1;
    engine.board[2][2] = 1;
    engine.placingPhase = false;
    engine.currentPlayer = 1;
    controller.debugSyncAfterExternalSetup();

    expect(controller.phase, TurnPhase.awaitingHuman);
    expect(engine.hasLegalMoves(2), isFalse);
    expect(engine.hasLegalMoves(1), isTrue);

    controller.tapTile(2, 2);
    expect(controller.selectedTile, [2, 2]);
    controller.tapTile(2, 3);
    expect(controller.phase, TurnPhase.animating);
    controller.finishAnimation();

    // الدور رجع للاعب 1 لأن اللاعب 2 بلا حركة.
    expect(engine.currentPlayer, 1);
    expect(controller.phase, TurnPhase.awaitingHuman);
    expect(controller.lastEvent, ControllerEvent.pass);
    expect(controller.passPlayer, 2);
  });

  test('التراجع ضد الكمبيوتر يعيد الدور للاعب البشري', () async {
    final controller = TurnController(
      boardSize: 5,
      vsComputer: true,
      difficulty: Difficulty.easy,
      aiDelayMs: 0,
      placementDelayMs: 0,
      debugAiSeed: 7,
    );
    addTearDown(controller.dispose);

    // لوحة حركة بسيطة: اللاعب 1 يحرّك ثم يتراجع.
    final engine = controller.engine;
    engine.board[2][1] = 1;
    engine.board[2][3] = 2;
    engine.board[0][0] = 1;
    engine.board[4][4] = 2;
    engine.placingPhase = false;
    engine.currentPlayer = 1;
    controller.debugSyncAfterExternalSetup();
    expect(controller.phase, TurnPhase.awaitingHuman);

    controller.tapTile(2, 1);
    controller.tapTile(2, 2);
    expect(controller.phase, TurnPhase.animating);
    controller.finishAnimation();
    // دور الكمبيوتر الآن: انتظر تحركه ثم أكمل حركته.
    await Future.delayed(const Duration(milliseconds: 30));
    expect(controller.phase, TurnPhase.animating);
    controller.finishAnimation();

    expect(controller.canUndo, isTrue);
    final undone = controller.undo();
    expect(undone, isTrue);
    expect(engine.currentPlayer, 1);
    expect(controller.phase, TurnPhase.awaitingHuman);
    // الحجر رجع مكانه.
    expect(engine.board[2][1], 1);
    expect(engine.board[2][2], 0);
  });
}
