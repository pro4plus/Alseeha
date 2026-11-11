// ذكاء الكمبيوتر — Dart نقي، بلا Flutter، حتى يُختبر مباشرة.
//
// المستويات الثلاثة:
//  * سهل: حركة عشوائية غالباً، يلتقط الأكل الواضح أحياناً فقط (30%)،
//    ويتجاهل أحياناً خطر أن يُؤكل حجره. مناسب للمبتدئين والأطفال.
//  * متوسط: جشع بعمق واحد + يتجنب تعليق حجره للأكل، ويفضل الأكل
//    والوسطى. يغلط أحياناً، لكنه يعاقب الأخطاء الواضحة.
//  * صعب: Minimax مع Alpha-Beta بعمق 4 على 5×5 وعمق 3 على 7×7،
//    مع ترتيب التحركات (الأكل أولاً) وتقييم يشمل المادة والحركة
//    والوسطى والتهديدات. لا عشوائية إلا لكسر التعادل بين الأفضل.
import 'dart:math';

import 'seega_engine.dart';

enum Difficulty { easy, medium, hard }

class SeegaAi {
  final Difficulty difficulty;
  final Random _random;

  SeegaAi(this.difficulty, {int? seed})
      : _random = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

  int get _depthForHard => 4;

  // ---------- التوزيع: أين يضع الكمبيوتر حجره؟ ----------
  // التوزيع الصحيح متشابك مع الخصم: بجانب حجارة الخصم (لفرص حصار قادمة)
  // وبجانب حجارة صديقة (للدعم)، وقرب الوسطى. التكتل في زاوية واحدة
  // خطأ فادح: بعد التوزيع تبقى خانة فارغة واحدة، فإذا كانت الخانة التي
  // يخليها أول متحرك محاطة بحجارته فقط، يُحصر الخصم بلا حركة وتتعطل اللعبة.
  List<int> choosePlacement(SeegaEngine engine) {
    final spots = engine.legalPlacements();
    if (spots.isEmpty) return const [-1, -1];
    final me = engine.currentPlayer;
    var bestScore = -1e9;
    var best = spots[0];
    for (final s in spots) {
      final r = s[0], c = s[1];
      var score = _random.nextDouble() * 2.0;
      // قرب الوسطى.
      final distCenter =
          (r - engine.center).abs() + (c - engine.center).abs();
      score += (engine.size - distCenter) * 1.5;
      var friends = 0, enemies = 0;
      for (final d in SeegaEngine.dirs) {
        final nr = r + d[0], nc = c + d[1];
        if (!engine.inBounds(nr, nc)) continue;
        if (engine.board[nr][nc] == me) friends++;
        if (engine.board[nr][nc] == 3 - me) enemies++;
      }
      // تشابك مع الخصم أولاً، ثم دعم صديق.
      score += enemies * 4.0;
      score += friends * 2.0;
      if (score > bestScore) {
        bestScore = score;
        best = s;
      }
    }
    return best;
  }

  // ---------- اختيار حركة ----------

  SeegaMove? chooseMove(SeegaEngine engine) {
    final moves = engine.legalMoves(engine.currentPlayer);
    if (moves.isEmpty) return null;
    switch (difficulty) {
      case Difficulty.easy:
        return _chooseEasy(moves);
      case Difficulty.medium:
        return _chooseGreedy(engine, moves);
      case Difficulty.hard:
        return _chooseMinimax(engine, moves);
    }
  }

  SeegaMove _chooseEasy(List<SeegaMove> moves) {
    final captures = moves.where((m) => m.captures > 0).toList();
    if (captures.isNotEmpty && _random.nextDouble() < 0.3) {
      return captures[_random.nextInt(captures.length)];
    }
    return moves[_random.nextInt(moves.length)];
  }

  /// هل الحركة [m] هي عكس آخر حركة مباشرة؟ (تذبذب ذهاباً وإياباً).
  bool _isReverse(SeegaEngine engine, SeegaMove m) {
    final last = engine.lastMove;
    if (last == null) return false;
    return m.fromRow == last.toRow &&
        m.fromCol == last.toCol &&
        m.toRow == last.fromRow &&
        m.toCol == last.fromCol;
  }

  SeegaMove _chooseGreedy(SeegaEngine engine, List<SeegaMove> moves) {
    final me = engine.currentPlayer;
    SeegaMove? best;
    var bestScore = -1e9;
    for (final m in moves) {
      final copy = engine.clone();
      copy.applyMove(m);
      // تقييم جشع: الأكل أولاً، ثم عدم تعليق الحجر، ثم الوسطى والحركة.
      var score = m.captures * 100.0;
      if (copy.isCenter(m.toRow, m.toCol)) score += 15;
      score += _random.nextDouble() * 3.0;
      // تجنب الرجوع فوراً لنفس المكان بلا أكل — يمنع التذبذب.
      if (_isReverse(engine, m) && m.captures == 0) score -= 15.0;
      // هل سيؤكل حجري في الرد؟ عقوبة كبيرة.
      final replyCaptures = _maxCaptureAgainst(copy, me);
      score -= replyCaptures * 90.0;
      score += (copy.count(me) - copy.count(3 - me)) * 10.0;
      if (score > bestScore) {
        bestScore = score;
        best = m;
      }
    }
    return best ?? moves.first;
  }

  /// أكبر أكل يمكن للخصم تحقيقه في رد واحد.
  int _maxCaptureAgainst(SeegaEngine engine, int me) {
    var maxCap = 0;
    for (final m in engine.legalMoves(3 - me)) {
      if (m.captures > maxCap) maxCap = m.captures;
    }
    return maxCap;
  }

  SeegaMove _chooseMinimax(SeegaEngine engine, List<SeegaMove> moves) {
    final me = engine.currentPlayer;
    // ترتيب التحركات: الأكل أولاً ليشتغل التقليم بقوة.
    final ordered = [...moves]
      ..sort((a, b) => b.captures.compareTo(a.captures));
    final depth = engine.size == 5 ? _depthForHard : 3;
    SeegaMove? best;
    var bestScore = -1e9;
    for (final m in ordered) {
      final copy = engine.clone();
      copy.applyMove(m);
      var score =
          _minimax(copy, depth - 1, -1e9, 1e9, false, me) + m.captures * 2.0;
      // تجنب الرجوع فوراً لنفس المكان بلا أكل + كسر تعادل عشوائي صغير.
      if (_isReverse(engine, m) && m.captures == 0) score -= 15.0;
      score += _random.nextDouble() * 2.0;
      if (score > bestScore) {
        bestScore = score;
        best = m;
      }
    }
    return best ?? moves.first;
  }

  double _minimax(SeegaEngine engine, int depth, double alpha, double beta,
      bool maximizing, int me) {
    final w = engine.winner();
    if (w != null) {
      if (w == 0) return 0;
      return w == me ? 10000.0 + depth : -10000.0 - depth;
    }
    if (depth == 0) return _evaluate(engine, me);
    final player = maximizing ? me : 3 - me;
    final moves = engine.legalMoves(player);
    if (moves.isEmpty) {
      // اللاعب الحالي محصور: يُمرَّر الدور للخصم فيلعب مرة ثانية.
      final copy = engine.clone();
      copy.currentPlayer = 3 - player;
      return _minimax(copy, depth - 1, alpha, beta, !maximizing, me);
    }
    moves.sort((a, b) => b.captures.compareTo(a.captures));
    if (maximizing) {
      var value = -1e9;
      for (final m in moves) {
        final copy = engine.clone();
        copy.applyMove(m);
        value = max(
            value, _minimax(copy, depth - 1, alpha, beta, false, me));
        alpha = max(alpha, value);
        if (alpha >= beta) break;
      }
      return value;
    } else {
      var value = 1e9;
      for (final m in moves) {
        final copy = engine.clone();
        copy.applyMove(m);
        value =
            min(value, _minimax(copy, depth - 1, alpha, beta, true, me));
        beta = min(beta, value);
        if (alpha >= beta) break;
      }
      return value;
    }
  }

  /// تقييم الوضع من وجهة نظر [me]:
  /// مادة ×100، حركة ×4، وسطى ×12، حجارة مهددة بالأكل ×-25،
  /// قرب من الوسطى، وحجارة على الحواف أقل قيمة هجومية.
  double _evaluate(SeegaEngine engine, int me) {
    final opp = 3 - me;
    final myCount = engine.count(me);
    final oppCount = engine.count(opp);
    var score = (myCount - oppCount) * 100.0;

    final myMoves = engine.legalMoves(me).length;
    final oppMoves = engine.legalMoves(opp).length;
    score += (myMoves - oppMoves) * 4.0;

    // الوسطى: من عليها قريب من كل شيء ويسيطر على أول حركة (وليست أماناً
    // في قواعد v1.0 — الحجر فيها يؤكل كغيره).
    if (engine.board[engine.center][engine.center] == me) score += 12;
    if (engine.board[engine.center][engine.center] == opp) score -= 12;

    for (var r = 0; r < engine.size; r++) {
      for (var c = 0; c < engine.size; c++) {
        final v = engine.board[r][c];
        if (v == 0) continue;
        final sign = v == me ? 1.0 : -1.0;
        // قرب الوسطى جيد.
        final dist =
            (r - engine.center).abs() + (c - engine.center).abs();
        score += sign * (engine.size - dist) * 1.5;
        // حجر مهدد بالأكل (خصم يستطيع أكله بحركة واحدة) عقوبة.
        if (_isHanging(engine, r, c, v)) score -= sign * 25.0;
        // عدوانية: حجر ملاصق لخصم = فرصة حصار قادمة، لا تحرك بلا هدف.
        var adjacentEnemies = 0;
        for (final d in SeegaEngine.dirs) {
          final nr = r + d[0], nc = c + d[1];
          if (engine.inBounds(nr, nc) &&
              engine.board[nr][nc] != 0 &&
              engine.board[nr][nc] != v) {
            adjacentEnemies++;
          }
        }
        score += sign * adjacentEnemies * 2.0;
      }
    }
    return score;
  }

  /// هل يمكن للخصم أكل الحجر في (r,c) بحركة واحدة؟
  /// (بلا استثناء للوسطى: في قواعد v1.0 الحجر فيها يؤكل كغيره).
  bool _isHanging(SeegaEngine engine, int r, int c, int owner) {
    final opp = 3 - owner;
    for (final d in SeegaEngine.dirs) {
      final r1 = r + d[0], c1 = c + d[1];
      final r2 = r - d[0], c2 = c - d[1];
      // خصم على جهة + فراغ على الجهة الأخرى يمكن أن يأتي منه خصم.
      if (engine.inBounds(r1, c1) &&
          engine.board[r1][c1] == opp &&
          engine.inBounds(r2, c2) &&
          engine.board[r2][c2] == 0) {
        return true;
      }
      if (engine.inBounds(r2, c2) &&
          engine.board[r2][c2] == opp &&
          engine.inBounds(r1, c1) &&
          engine.board[r1][c1] == 0) {
        return true;
      }
    }
    return false;
  }

  /// تلميح للاعب البشري: أفضل حركة بمستوى متوسط (سريعة ومفيدة).
  SeegaMove? hint(SeegaEngine engine) {
    final moves = engine.legalMoves(engine.currentPlayer);
    if (moves.isEmpty) return null;
    return _chooseGreedy(engine, moves);
  }
}
