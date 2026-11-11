import 'package:alseeja/game/seega_engine.dart';
import 'package:flutter_test/flutter_test.dart';

SeegaEngine finishedEngine() {
  final e = SeegaEngine(size: 5);
  e.placingPhase = false;
  return e;
}

void main() {
  test('التوزيع: 3 أحجار في كل دور كما في الأصل، والوسطى محظورة', () {
    final e = SeegaEngine(size: 5);
    expect(e.placeStone(2, 2), isFalse); // الوسطى فاضية لأول حركة
    expect(e.placeStone(0, 0), isTrue);
    expect(e.placeStone(0, 1), isTrue);
    expect(e.currentPlayer, 1); // بعد حجرين فقط ما زال دور اللاعب 1
    expect(e.placeStone(0, 2), isTrue);
    expect(e.currentPlayer, 2); // تبدل بعد 3 أحجار
    expect(e.placeStone(0, 0), isFalse); // مشغولة
  });

  test('بعد اكتمال التوزيع تبدأ الحركة واللاعب الأول يتحرك', () {
    final e = SeegaEngine(size: 5);
    var placed = 0;
    outer:
    for (var r = 0; r < 5; r++) {
      for (var c = 0; c < 5; c++) {
        if (r == 2 && c == 2) continue;
        expect(e.placeStone(r, c), isTrue);
        placed++;
        if (placed == 24) break outer;
      }
    }
    expect(e.placingPhase, isFalse);
    expect(e.currentPlayer, 1);
    expect(e.count(1), 12);
    expect(e.count(2), 12);
  });

  test('الأكل بالحصار: حجر بين حجرين يؤكل', () {
    final e = finishedEngine();
    // لاعب 1 في (2,0) و(2,3)، خصم في (2,1)، وحجر متحرك في (2,4)
    // سيتحرك (2,4) -> (2,2) فيحصر (2,1)؟ لا — الحصار يحتاج حجراً على الجهتين.
    // الترتيب الصحيح: P1 في (1,1)، خصم في (1,2)، وحجر P1 في (1,4)
    // يتحرك (1,4) -> (1,3) فيحصر الخصم بين (1,3) و(1,1).
    e.board[1][1] = 1;
    e.board[1][2] = 2;
    e.board[1][4] = 1;
    e.currentPlayer = 1;
    final eaten = e.applyMove(const SeegaMove(1, 4, 1, 3));
    expect(eaten, 1);
    expect(e.board[1][2], 0);
    expect(e.count(2), 0);
  });

  test('الحجر في الوسطى يؤكل كغيره إذا حُصر (بلا حماية — كما في الأصل)', () {
    final e = finishedEngine();
    e.board[2][2] = 2; // خصم في الوسطى
    e.board[2][1] = 1;
    e.board[2][4] = 1;
    e.board[0][0] = 1; // حتى لا يكون الفوز بصفر مباشرة بعد الأكل
    e.currentPlayer = 1;
    // حرّك (2,4) -> (2,3): الخصم في الوسطى يصبح بين (2,3) و(2,1).
    final eaten = e.applyMove(const SeegaMove(2, 4, 2, 3));
    expect(eaten, 1);
    expect(e.board[2][2], 0);
  });

  test('الدخول بين حجرَي خصم آمن ولا يؤكلك', () {
    final e = finishedEngine();
    e.board[0][1] = 2;
    e.board[0][3] = 2;
    e.board[3][3] = 2;
    e.board[1][2] = 1;
    e.board[4][4] = 1;
    e.board[4][0] = 1;
    e.currentPlayer = 1;
    final eaten = e.applyMove(const SeegaMove(1, 2, 0, 2));
    expect(eaten, 0);
    expect(e.board[0][2], 1); // ما زال حياً
    expect(e.winner(), isNull);
  });

  test('الفوز عند أكل كل حجارة الخصم (صفر) — وحجر واحد لا يكفي', () {
    final e = finishedEngine();
    e.board[0][0] = 1;
    e.board[0][1] = 1;
    e.board[4][4] = 2;
    e.currentPlayer = 1;
    expect(e.winner(), isNull); // حجر واحد باقٍ للخصم = اللعبة مستمرة
    e.board[4][4] = 0;
    expect(e.winner(), 1); // صفر حجارة = فوز
  });

  test('من بلا حركة يُمرَّر دوره ولا يخسر فوراً', () {
    final e = finishedEngine();
    // لاعب 2 محصور تماماً في زاويتين بحجارة اللاعب 1 (حجران باقيان،
    // والفوز في الأصل بصفر فقط، فلا فوز هنا).
    e.board[0][0] = 2;
    e.board[0][1] = 1;
    e.board[1][0] = 1;
    e.board[4][0] = 2;
    e.board[4][1] = 1;
    e.board[3][0] = 1;
    e.board[4][4] = 1;
    e.currentPlayer = 2;
    expect(e.hasLegalMoves(2), isFalse);
    expect(e.winner(), isNull); // اللعبة مستمرة
    expect(e.passIfStuck(), isTrue);
    expect(e.currentPlayer, 1); // الدور رجع للاعب 1
  });

  test('انحصار اللاعبين معاً: صاحب الحجارة الأكثر يفوز', () {
    final e = finishedEngine();
    // لوحة ممتلئة تماماً (لا خانة فارغة = لا حركة لأحد):
    // نمط شطرنج يعطي اللاعب 1 ثلاثة عشر حجراً واللاعب 2 اثني عشر.
    for (var r = 0; r < 5; r++) {
      for (var c = 0; c < 5; c++) {
        e.board[r][c] = (r + c) % 2 == 0 ? 1 : 2;
      }
    }
    e.currentPlayer = 1;
    expect(e.hasLegalMoves(1), isFalse);
    expect(e.hasLegalMoves(2), isFalse);
    expect(e.winner(), 1); // 13 مقابل 12
  });

  test('حركة غير قانونية تُرفض', () {
    final e = finishedEngine();
    e.board[0][0] = 1;
    e.board[0][1] = 1;
    e.currentPlayer = 1;
    // قفزتان أو إلى خانة مشغولة مرفوضة.
    expect(e.applyMove(const SeegaMove(0, 0, 0, 2)), -1);
    expect(e.applyMove(const SeegaMove(0, 0, 0, 1)), -1);
    // قطرية مرفوضة.
    expect(e.applyMove(const SeegaMove(0, 0, 1, 1)), -1);
  });
}
