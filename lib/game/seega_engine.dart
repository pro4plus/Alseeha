// محرك لعبة السيجا — كود Dart نقي بدون أي اعتماد على Flutter،
// حتى يمكن اختباره مباشرة بـ `dart test` / `flutter test`.
//
// قواعد اللعبة الأصلية من النسخة الأولى (v1.0) — محفوظة كما هي
// تماماً بأمر المستخدم، بلا أي تغيير:
//  * لوحة 5×5 (12 حجر لكل لاعب) أو 7×7 (24 حجر لكل لاعب)، الخانة الوسطى
//    تبقى فارغة أثناء التوزيع، لأن أول حركة في اللعبة تكون إليها.
//  * التوزيع: كل لاعب يضع 3 أحجار في كل دور، في أي خانة فارغة ما عدا
//    الوسطى، حتى تكتمل كل الحجارة. بعدها يبدأ بالحركة اللاعب الأول
//    إذا كان عنده حركة، وإلا اللاعب الثاني (كما في v1.0 تماماً).
//  * الحركة: خطوة واحدة أفقية أو عمودية إلى خانة فارغة (الوسطى مسموحة).
//  * الأكل (custodial capture): إذا حرّكت حجراً فأصبح حجر خصم محصوراً بين
//    حجرك المتحرك وحجر آخر لك في خط مستقيم أفقي أو عمودي، يُؤكل ويُرفع.
//    الدخول بين حجرَي خصم لا يؤكلك. ولا حماية خاصة للوسطى: الحجر فيها
//    يؤكل كأي حجر آخر إذا حُصر — كما في v1.0.
//  * الفوز: من يترك خصمه بلا أي حجر (صفر). وإذا كان اللاعب التالي بلا
//    حركة، يمرَّر الدور لخصمه (كما في v1.0). انحصار اللاعبين معاً
//    نادر، فيفوز صاحب الحجارة الأكثر، والتساوي تعادل.

/// حجر اللاعب الأول = 1، اللاعب الثاني = 2، فارغ = 0.
class SeegaMove {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;

  /// عدد الحجارة التي سيأكلها هذا التحرك (تُحسب وقت التطبيق).
  final int captures;

  const SeegaMove(this.fromRow, this.fromCol, this.toRow, this.toCol,
      {this.captures = 0});

  SeegaMove withCaptures(int n) =>
      SeegaMove(fromRow, fromCol, toRow, toCol, captures: n);

  @override
  String toString() => '($fromRow,$fromCol)->($toRow,$toCol) x$captures';

  @override
  bool operator ==(Object other) =>
      other is SeegaMove &&
      fromRow == other.fromRow &&
      fromCol == other.fromCol &&
      toRow == other.toRow &&
      toCol == other.toCol;

  @override
  int get hashCode => Object.hash(fromRow, fromCol, toRow, toCol);
}

/// نتيجة حركة مطبقة: الحركة نفسها + قائمة الخانات المأكولة + عددها.
/// (v3.0: إضافة فقط لتمكين حركات اللوحة — لا تغيير في أي قاعدة.)
class MoveResult {
  final SeegaMove move;
  final int mover;
  final List<List<int>> captured;
  int get eaten => captured.length;
  const MoveResult({
    required this.move,
    required this.mover,
    required this.captured,
  });
}

class SeegaEngine {
  final int size;
  final int stonesPerPlayer;

  /// board[r][c]: 0 فارغ، 1 لاعب أول، 2 لاعب ثانٍ.
  final List<List<int>> board;

  bool placingPhase;
  int currentPlayer; // 1 أو 2
  int placedP1;
  int placedP2;

  /// آخر حركة طبقت (لأغراض الذكاء فقط — لتجنب التذبذب ذهاباً وإياباً).
  SeegaMove? lastMove;

  /// كم حجراً تبقى للاعب الحالي في دور التوزيع الحالي (3 كل مرة — كما في v1.0).
  int stonesLeftThisTurn;

  SeegaEngine({required this.size})
      : stonesPerPlayer = size == 5 ? 12 : 24,
        board = List.generate(size, (_) => List.filled(size, 0)),
        placingPhase = true,
        currentPlayer = 1,
        placedP1 = 0,
        placedP2 = 0,
        stonesLeftThisTurn = 3;

  SeegaEngine._copy(SeegaEngine other)
      : size = other.size,
        stonesPerPlayer = other.stonesPerPlayer,
        board = [for (final row in other.board) [...row]],
        placingPhase = other.placingPhase,
        currentPlayer = other.currentPlayer,
        placedP1 = other.placedP1,
        placedP2 = other.placedP2,
        lastMove = other.lastMove,
        stonesLeftThisTurn = other.stonesLeftThisTurn;

  SeegaEngine clone() => SeegaEngine._copy(this);

  int get center => size ~/ 2;
  bool isCenter(int r, int c) => r == center && c == center;

  bool inBounds(int r, int c) => r >= 0 && r < size && c >= 0 && c < size;

  int count(int player) {
    var n = 0;
    for (final row in board) {
      for (final v in row) {
        if (v == player) n++;
      }
    }
    return n;
  }

  int placedOf(int player) => player == 1 ? placedP1 : placedP2;

  int remainingToPlace(int player) => stonesPerPlayer - placedOf(player);

  // ---------- التوزيع ----------

  List<List<int>> legalPlacements() {
    final out = <List<int>>[];
    if (!placingPhase) return out;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c] == 0 && !isCenter(r, c)) out.add([r, c]);
      }
    }
    return out;
  }

  /// يضع حجر اللاعب الحالي في (r,c). يعيد false إذا كانت الخانة غير قانونية.
  bool placeStone(int r, int c) {
    if (!placingPhase) return false;
    if (!inBounds(r, c) || board[r][c] != 0 || isCenter(r, c)) return false;
    if (remainingToPlace(currentPlayer) <= 0) return false;
    board[r][c] = currentPlayer;
    if (currentPlayer == 1) {
      placedP1++;
    } else {
      placedP2++;
    }
    stonesLeftThisTurn--;
    if (stonesLeftThisTurn == 0) {
      if (placedP1 >= stonesPerPlayer && placedP2 >= stonesPerPlayer) {
        placingPhase = false;
        // كما في v1.0 تماماً: يبدأ اللاعب الأول إذا كان عنده حركة،
        // وإلا اللاعب الثاني.
        if (hasLegalMoves(1)) {
          currentPlayer = 1;
        } else if (hasLegalMoves(2)) {
          currentPlayer = 2;
        }
        stonesLeftThisTurn = 0;
      } else {
        currentPlayer = 3 - currentPlayer;
        stonesLeftThisTurn = 3;
      }
    }
    return true;
  }

  // ---------- الحركة ----------

  static const dirs = [
    [0, 1],
    [0, -1],
    [1, 0],
    [-1, 0],
  ];

  /// كم حجر خصم سيُؤكل لو تحرك حجر [player] إلى (toR,toC)
  /// مع افتراض أن الحركة نفسها قانونية.
  int capturesForMove(int player, int toR, int toC) {
    final opponent = 3 - player;
    var n = 0;
    for (final d in dirs) {
      final r1 = toR + d[0], c1 = toC + d[1];
      final r2 = toR + 2 * d[0], c2 = toC + 2 * d[1];
      if (!inBounds(r1, c1) || !inBounds(r2, c2)) continue;
      // بلا حماية للوسطى: الحجر فيها يؤكل كأي حجر آخر (كما في v1.0).
      if (board[r1][c1] == opponent && board[r2][c2] == player) n++;
    }
    return n;
  }

  List<SeegaMove> legalMoves(int player) {
    final out = <SeegaMove>[];
    if (placingPhase) return out;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c] != player) continue;
        for (final d in dirs) {
          final nr = r + d[0], nc = c + d[1];
          if (!inBounds(nr, nc) || board[nr][nc] != 0) continue;
          final cap = capturesForMove(player, nr, nc);
          out.add(SeegaMove(r, c, nr, nc, captures: cap));
        }
      }
    }
    return out;
  }

  bool hasLegalMoves(int player) => legalMoves(player).isNotEmpty;

  /// يطبق التحرك ويعيد عدد الحجارة المأكولة. يعيد -1 إذا كان غير قانوني.
  int applyMove(SeegaMove move) {
    if (placingPhase) return -1;
    final player = board[move.fromRow][move.fromCol];
    if (player == 0) return -1;
    if (player != currentPlayer) return -1;
    if ((move.fromRow - move.toRow).abs() +
            (move.fromCol - move.toCol).abs() !=
        1) {
      return -1;
    }
    if (!inBounds(move.toRow, move.toCol) ||
        board[move.toRow][move.toCol] != 0) {
      return -1;
    }
    board[move.fromRow][move.fromCol] = 0;
    board[move.toRow][move.toCol] = player;
    lastMove = move;

    // الأكل من كل الاتجاهات الأربعة.
    final opponent = 3 - player;
    var eaten = 0;
    for (final d in dirs) {
      final r1 = move.toRow + d[0], c1 = move.toCol + d[1];
      final r2 = move.toRow + 2 * d[0], c2 = move.toCol + 2 * d[1];
      if (!inBounds(r1, c1) || !inBounds(r2, c2)) continue;
      if (board[r1][c1] == opponent && board[r2][c2] == player) {
        board[r1][c1] = 0;
        eaten++;
      }
    }
    currentPlayer = 3 - currentPlayer;
    return eaten;
  }

  /// يطبق التحرك مثل applyMove تماماً، لكنه يعيد أيضاً قائمة الخانات
  /// المأكولة ومسار الحركة لتمكين الحركات في الواجهة.
  /// يعيد null إذا كانت الحركة غير قانونية.
  MoveResult? applyMoveDetailed(SeegaMove move) {
    if (placingPhase) return null;
    final player = board[move.fromRow][move.fromCol];
    if (player == 0 || player != currentPlayer) return null;
    if ((move.fromRow - move.toRow).abs() +
            (move.fromCol - move.toCol).abs() !=
        1) {
      return null;
    }
    if (!inBounds(move.toRow, move.toCol) ||
        board[move.toRow][move.toCol] != 0) {
      return null;
    }
    // احسب الخانات المأكولة قبل التطبيق (نفس منطق applyMove).
    final opponent = 3 - player;
    final captured = <List<int>>[];
    for (final d in dirs) {
      final r1 = move.toRow + d[0], c1 = move.toCol + d[1];
      final r2 = move.toRow + 2 * d[0], c2 = move.toCol + 2 * d[1];
      if (!inBounds(r1, c1) || !inBounds(r2, c2)) continue;
      if (board[r1][c1] == opponent && board[r2][c2] == player) {
        captured.add([r1, c1]);
      }
    }
    final eaten = applyMove(move);
    if (eaten < 0) return null;
    assert(eaten == captured.length);
    return MoveResult(move: move, mover: player, captured: captured);
  }

  /// مفتاح نصي للوضع الحالي (اللوحة + الدور) لتتبع التكرار:
  /// تكرار نفس الوضع 3 مرات = تعادل (قاعدة شطرنجية لمنع الدوران الأبدي).
  String positionKey() {
    final sb = StringBuffer()..write(currentPlayer)..write('|');
    for (final row in board) {
      for (final v in row) {
        sb.write(v);
      }
    }
    return sb.toString();
  }

  // ---------- التمرير والفوز ----------

  /// إذا كان اللاعب الحالي بلا أي حركة قانونية بينما خصمه يستطيع الحركة،
  /// يُمرَّر الدور للخصم (يلعب مرة ثانية) — كما في v1.0 تماماً: بعد
  /// كل حركة، إذا كان اللاعب التالي بلا حركة، يرجع الدور للاعب الذي حرّك.
  /// يعيد true إذا تم التمرير.
  bool passIfStuck() {
    if (placingPhase) return false;
    if (hasLegalMoves(currentPlayer)) return false;
    if (!hasLegalMoves(3 - currentPlayer)) return false;
    currentPlayer = 3 - currentPlayer;
    return true;
  }

  /// يعيد 1 أو 2 عند فوز أحدهما، و0 عند التعادل، وnull إذا استمرت اللعبة.
  /// الفوز كما في v1.0: ترك الخصم بلا أي حجر (صفر). انحصار اللاعبين معاً
  /// نادر، فيفوز صاحب الحجارة الأكثر (والتساوي تعادل).
  int? winner() {
    if (placingPhase) return null;
    final c1 = count(1);
    final c2 = count(2);
    if (c1 == 0 && c2 == 0) return 0; // حالة نادرة
    if (c1 == 0) return 2;
    if (c2 == 0) return 1;
    final p1Moves = hasLegalMoves(1);
    final p2Moves = hasLegalMoves(2);
    if (!p1Moves && !p2Moves) {
      if (c1 == c2) return 0;
      return c1 > c2 ? 1 : 2;
    }
    return null;
  }
}
