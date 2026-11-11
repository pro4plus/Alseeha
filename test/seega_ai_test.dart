import 'package:alseeja/game/seega_ai.dart';
import 'package:alseeja/game/seega_engine.dart';
import 'package:flutter_test/flutter_test.dart';

SeegaEngine capturePosition() {
  final e = SeegaEngine(size: 5);
  e.placingPhase = false;
  e.board[1][1] = 2; // الكمبيوتر
  e.board[1][2] = 1; // خصم
  e.board[1][4] = 2; // الكمبيوتر — سيتحرك إلى (1,3) ويأكل
  e.board[3][3] = 1;
  e.board[4][4] = 1;
  e.currentPlayer = 2;
  return e;
}

void main() {
  test('السهل يعيد حركة قانونية', () {
    final e = capturePosition();
    final ai = SeegaAi(Difficulty.easy, seed: 42);
    final move = ai.chooseMove(e);
    expect(move, isNotNull);
    expect(e.legalMoves(2).contains(move), isTrue);
  });

  test('الصعب يلتقط الأكل المتاح فوراً', () {
    final e = capturePosition();
    final ai = SeegaAi(Difficulty.hard, seed: 1);
    final move = ai.chooseMove(e);
    expect(move, isNotNull);
    expect(move!.captures, greaterThan(0));
    expect(move.toRow, 1);
    expect(move.toCol, 3);
  });

  test('المتوسط يلتقط الأكل المتاح أيضاً', () {
    final e = capturePosition();
    final ai = SeegaAi(Difficulty.medium, seed: 1);
    final move = ai.chooseMove(e);
    expect(move, isNotNull);
    expect(move!.captures, greaterThan(0));
  });

  test('التوزيع يعيد خانة قانونية غير الوسطى', () {
    final e = SeegaEngine(size: 5);
    final ai = SeegaAi(Difficulty.hard, seed: 7);
    final spot = ai.choosePlacement(e);
    expect(e.inBounds(spot[0], spot[1]), isTrue);
    expect(e.isCenter(spot[0], spot[1]), isFalse);
    expect(e.board[spot[0]][spot[1]], 0);
  });

  test('الصعب بلا حركة يعيد null', () {
    final e = SeegaEngine(size: 5);
    e.placingPhase = false;
    e.board[0][0] = 2;
    e.board[0][1] = 1;
    e.board[1][0] = 1;
    e.currentPlayer = 2;
    final ai = SeegaAi(Difficulty.hard, seed: 1);
    expect(ai.chooseMove(e), isNull);
  });
}
