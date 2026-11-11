// وحدة تحكم اللعبة v3.0: آلة حالة واحدة تمتلك المحرك والذكاء الاصطناعي
// والتاريخ والسجل — وتصلح عطل التجمد في v2.0.
//
// المراحل: placing → animating → awaitingHuman | awaitingAI → gameOver
//
// إصلاح التجمد: عند انتهاء التوزيع يطبَّق قانون v1.0 لأول متحرك
// (المحرك نفسه يختار اللاعب الذي لديه حركة إلى جوار الوسطى) ثم —
// إن كان الدور للكمبيوتر — يُجدوَل تحركه فوراً بدل انتظار نقرة
// من اللاعب لن تأتي. في v2.0 لم يكن أحد يجدول تحرك الكمبيوتر
// عند انتهاء التوزيع وكان الدور له، فتجمّدت اللعبة على
// "الكمبيوتر بيفكّر…".
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'haptics.dart';
import 'seega_ai.dart';
import 'seega_engine.dart';
import 'sound_manager.dart';

enum TurnPhase { placing, animating, awaitingHuman, awaitingAI, gameOver }

enum ControllerEvent {
  placed,
  moved,
  invalid,
  pass,
  placementEnded,
  gameOver,
  undo,
  // اختيار/إلغاء اختيار حجر (لا حركة فيه، لكن الواجهة يجب أن
  // تعيد الرسم لتظهر الإطار الذهبي والوجهات).
  selected,
  // انتهت حركة الانزلاق واستقر الدور على اللاعب التالي.
  turnChanged,
}

/// لقطة كاملة لحالة اللعبة للتراجع (ضد الكمبيوتر فقط).
class _Snapshot {
  final List<List<int>> board;
  final int currentPlayer;
  final bool placingPhase;
  final int placedP1;
  final int placedP2;
  final int stonesLeftThisTurn;
  final SeegaMove? lastMove;
  final int moveCount;
  final Map<String, int> positionCounts;

  _Snapshot({
    required this.board,
    required this.currentPlayer,
    required this.placingPhase,
    required this.placedP1,
    required this.placedP2,
    required this.stonesLeftThisTurn,
    required this.lastMove,
    required this.moveCount,
    required this.positionCounts,
  });
}

class TurnController extends ChangeNotifier {
  final int boardSize;
  final bool vsComputer;
  final Difficulty difficulty;
  final int aiDelayMs;
  final int placementDelayMs;
  final int? debugAiSeed;

  SeegaEngine engine;
  SeegaAi _ai;

  TurnPhase phase = TurnPhase.placing;

  /// آخر حدث صدر (تراقبه الواجهة لتفعيل الحركات والأصوات).
  ControllerEvent? lastEvent;
  int eventNonce = 0;

  /// نتيجة آخر حركة مطبقة (لتحريك الحجر وأكل المأكولات في الواجهة).
  MoveResult? lastMoveResult;

  /// آخر خانة وُضع فيها حجر أثناء التوزيع [r, c].
  List<int>? lastPlaced;

  /// آخر خانة نقرها اللاعب وكانت غير قانونية [r, c] (لاهتزازها).
  List<int>? lastInvalidSquare;

  /// اللاعب الذي مُرِّر دوره (لرسالة عائمة).
  int? passPlayer;

  /// الفائز: 0 تعادل، 1 أو 2 فائز، null لم تنتهِ اللعبة.
  int? winner;
  String? drawReason;

  /// الحجر المحدد حالياً في مرحلة الحركة [r, c] أو null.
  List<int>? selectedTile;

  /// نتيجة الجلسة ضد الكمبيوتر.
  int sessionWins = 0;
  int sessionLosses = 0;
  int sessionDraws = 0;

  final List<_Snapshot> _history = [];
  final Map<String, int> _positionCounts = {};
  int _moveCount = 0;

  Timer? _aiTimer;
  bool _disposed = false;

  TurnController({
    required this.boardSize,
    required this.vsComputer,
    this.difficulty = Difficulty.medium,
    this.aiDelayMs = 650,
    this.placementDelayMs = 450,
    this.debugAiSeed,
  })  : engine = SeegaEngine(size: boardSize),
        _ai = SeegaAi(difficulty, seed: debugAiSeed) {
    _positionCounts[engine.positionKey()] = 1;
  }

  bool get isHumanTurn => phase == TurnPhase.awaitingHuman;
  bool get isAiThinking => phase == TurnPhase.awaitingAI;
  bool get isPlacing => phase == TurnPhase.placing;

  /// عدد الأحجار التي وضعها اللاعب الحالي في دور التوزيع الحالي (0..3).
  int get placedThisTurn =>
      engine.placingPhase ? 3 - engine.stonesLeftThisTurn : 0;

  /// مزامنة آلة الحالة بعد إعداد خارجي للوحة (للاختبارات فقط):
  /// تشغّل الاستقرار كما لو انتهى التوزيع للتو.
  void debugSyncAfterExternalSetup() {
    _settle();
    notifyListeners();
  }

  void _emit(ControllerEvent event) {
    lastEvent = event;
    eventNonce++;
  }

  // ---------------------------------------------------------- التوزيع

  /// يضع اللاعب البشري حجراً أثناء التوزيع. يعيد false إن لم يكن قانونياً.
  bool placeStone(int row, int col) {
    if (phase != TurnPhase.placing) return false;
    if (vsComputer && engine.currentPlayer != 1) return false;
    final ok = engine.placeStone(row, col);
    if (!ok) {
      lastInvalidSquare = [row, col];
      _emit(ControllerEvent.invalid);
      SoundManager.instance.invalid();
      Haptics.heavy();
      notifyListeners();
      return false;
    }
    lastPlaced = [row, col];
    _emit(ControllerEvent.placed);
    SoundManager.instance.place();
    Haptics.light();
    _afterPlacement();
    notifyListeners();
    return true;
  }

  void _afterPlacement() {
    if (engine.placingPhase) {
      _settle();
      return;
    }
    // انتهى التوزيع: قانون v1.0 لأول متحرك مطبَّق داخل المحرك.
    _emit(ControllerEvent.placementEnded);
    SoundManager.instance.turn();
    _settle();
  }

  // ----------------------------------------------------------- الحركة

  /// نقرة على خانة أثناء مرحلة الحركة (للاعب البشري فقط).
  void tapTile(int row, int col) {
    if (phase != TurnPhase.awaitingHuman) return;
    final me = engine.currentPlayer;
    final value = engine.board[row][col];
    if (selectedTile == null) {
      if (value == me) {
        selectedTile = [row, col];
        _emit(ControllerEvent.selected);
        SoundManager.instance.select();
        Haptics.select();
        notifyListeners();
      }
      return;
    }
    if (selectedTile![0] == row && selectedTile![1] == col) {
      selectedTile = null;
      _emit(ControllerEvent.selected);
      notifyListeners();
      return;
    }
    if (value == me) {
      selectedTile = [row, col];
      _emit(ControllerEvent.selected);
      SoundManager.instance.select();
      Haptics.select();
      notifyListeners();
      return;
    }
    // محاولة تحريك الحجر المحدد إلى الخانة.
    final move = SeegaMove(
      selectedTile![0],
      selectedTile![1],
      row,
      col,
    );
    final result = _applyMove(move);
    if (result == null) {
      lastInvalidSquare = [row, col];
      _emit(ControllerEvent.invalid);
      SoundManager.instance.invalid();
      Haptics.heavy();
      notifyListeners();
      return;
    }
    selectedTile = null;
    _emit(ControllerEvent.moved);
    SoundManager.instance.slide();
    notifyListeners();
  }

  /// يطبق حركة (بشري أو كمبيوتر) ويدخل مرحلة الحركة المتحركة.
  /// يعيد null إن كانت غير قانونية.
  MoveResult? _applyMove(SeegaMove move) {
    _pushHistory();
    final result = engine.applyMoveDetailed(move);
    if (result == null) {
      _history.removeLast();
      return null;
    }
    lastMoveResult = result;
    if (result.eaten > 0) {
      _moveCount = 0;
    } else {
      _moveCount++;
    }
    phase = TurnPhase.animating;
    return result;
  }

  /// تستدعيها الواجهة بعد انتهاء حركة الانزلاق والأكل:
  /// تشغّل أصوات الهبوط/الأكل، تفحص التعادل، ثم تستقر على الدور التالي.
  void finishAnimation() {
    if (phase != TurnPhase.animating) return;
    final result = lastMoveResult;
    if (result != null) {
      SoundManager.instance.land();
      if (result.eaten == 1) {
        SoundManager.instance.capture();
        Haptics.medium();
      } else if (result.eaten > 1) {
        SoundManager.instance.capture(multi: true);
        Haptics.multiCapture();
      }
    }
    _checkDraw();
    if (winner == null) {
      final before = eventNonce;
      _settle();
      // استقرار الدور بعد الحركة يغيّر اللاعب النشط، فيجب أن
      // تعيد الواجهة الرسم (اللافتة وشارة «الدور») — إلا إذا كان
      // الاستقرار نفسه قد أصدر حدثاً أوضح (تمرير أو نهاية لعبة).
      if (eventNonce == before) {
        _emit(ControllerEvent.turnChanged);
      }
    }
    notifyListeners();
  }

  void _checkDraw() {
    // 60 حركة بلا أكل → تعادل.
    if (_moveCount >= 60) {
      _endGame(winner: 0, reason: 'draw60');
      return;
    }
    // تكرار نفس الوضع 3 مرات → تعادل.
    final key = engine.positionKey();
    final count = (_positionCounts[key] ?? 0) + 1;
    _positionCounts[key] = count;
    if (count >= 3) {
      _endGame(winner: 0, reason: 'drawRepeat');
    }
  }

  // ------------------------------------------------------------ الذكاء

  void _scheduleAiPlacement() {
    _aiTimer?.cancel();
    _aiTimer = Timer(Duration(milliseconds: placementDelayMs), () {
      if (_disposed) return;
      if (phase != TurnPhase.placing) return;
      if (engine.currentPlayer != 2) return;
      final placement = _ai.choosePlacement(engine);
      if (placement[0] < 0) return;
      final ok = engine.placeStone(placement[0], placement[1]);
      if (!ok) return;
      lastPlaced = placement;
      _emit(ControllerEvent.placed);
      SoundManager.instance.place();
      _afterPlacement();
      notifyListeners();
    });
  }

  void _scheduleAiMove() {
    _aiTimer?.cancel();
    _aiTimer = Timer(Duration(milliseconds: aiDelayMs), () {
      if (_disposed) return;
      if (phase != TurnPhase.awaitingAI) return;
      final move = _ai.chooseMove(engine);
      if (move == null) {
        // لا حركة للكمبيوتر: يُمرَّر الدور.
        _settle();
        notifyListeners();
        return;
      }
      final result = _applyMove(move);
      if (result == null) {
        _settle();
        notifyListeners();
        return;
      }
      _emit(ControllerEvent.moved);
      SoundManager.instance.slide();
      notifyListeners();
    });
  }

  // ------------------------------------------------------------ الاستقرار

  /// بعد كل تغيير حالة: فائز؟ توزيع؟ حركة؟ مرّر الدور إن لزم،
  /// وجدول الكمبيوتر إن كان دوره.
  void _settle() {
    if (winner != null) return;
    final w = engine.winner();
    if (w != null) {
      _endGame(winner: w);
      return;
    }
    if (engine.placingPhase) {
      phase = TurnPhase.placing;
      if (vsComputer && engine.currentPlayer == 2) {
        _scheduleAiPlacement();
      }
      return;
    }
    // مرحلة الحركة: إن كان اللاعب الحالي بلا حركة يُمرَّر دوره.
    if (engine.passIfStuck()) {
      passPlayer = 3 - engine.currentPlayer;
      _emit(ControllerEvent.pass);
      SoundManager.instance.turn();
      final w2 = engine.winner();
      if (w2 != null) {
        _endGame(winner: w2);
        return;
      }
    }
    if (vsComputer && engine.currentPlayer == 2) {
      phase = TurnPhase.awaitingAI;
      _scheduleAiMove();
    } else {
      phase = TurnPhase.awaitingHuman;
      if (lastEvent == ControllerEvent.moved ||
          lastEvent == ControllerEvent.pass) {
        SoundManager.instance.turn();
      }
    }
  }

  void _endGame({required int winner, String? reason}) {
    this.winner = winner;
    drawReason = reason;
    phase = TurnPhase.gameOver;
    _emit(ControllerEvent.gameOver);
    if (!vsComputer) {
      if (winner == 0) {
        SoundManager.instance.draw();
      } else {
        SoundManager.instance.win();
      }
      return;
    }
    if (winner == 1) {
      sessionWins++;
      SoundManager.instance.win();
      Haptics.win();
    } else if (winner == 2) {
      sessionLosses++;
      SoundManager.instance.lose();
    } else {
      sessionDraws++;
      SoundManager.instance.draw();
    }
  }

  // ------------------------------------------------------------ التلميح والتراجع

  /// تلميح: أفضل حركة حسب مستوى الكمبيوتر (للاعب البشري فقط).
  SeegaMove? hint() {
    if (phase != TurnPhase.awaitingHuman) return null;
    final move = _ai.hint(engine);
    if (move != null) SoundManager.instance.hint();
    return move;
  }

  bool get canUndo =>
      vsComputer && _history.isNotEmpty && phase != TurnPhase.animating;

  /// تراجع: يعيد اللعبة إلى ما قبل آخر حركة للاعب البشري
  /// (يتراجع عن حركة الكمبيوتر معها إن وُجدت).
  bool undo() {
    if (!canUndo) return false;
    _aiTimer?.cancel();
    var popped = 0;
    while (_history.isNotEmpty && popped < 2) {
      final snap = _history.removeLast();
      _restore(snap);
      popped++;
      if (engine.currentPlayer == 1 && !engine.placingPhase) break;
      if (engine.placingPhase) break;
    }
    selectedTile = null;
    lastMoveResult = null;
    winner = null;
    drawReason = null;
    phase = engine.placingPhase
        ? TurnPhase.placing
        : TurnPhase.awaitingHuman;
    _emit(ControllerEvent.undo);
    SoundManager.instance.undo();
    notifyListeners();
    return true;
  }

  void _pushHistory() {
    if (_history.length >= 40) _history.removeAt(0);
    _history.add(_Snapshot(
      board: engine.board.map((r) => List<int>.of(r)).toList(),
      currentPlayer: engine.currentPlayer,
      placingPhase: engine.placingPhase,
      placedP1: engine.placedP1,
      placedP2: engine.placedP2,
      stonesLeftThisTurn: engine.stonesLeftThisTurn,
      lastMove: engine.lastMove,
      moveCount: _moveCount,
      positionCounts: Map<String, int>.of(_positionCounts),
    ));
  }

  void _restore(_Snapshot snap) {
    for (var r = 0; r < engine.size; r++) {
      for (var c = 0; c < engine.size; c++) {
        engine.board[r][c] = snap.board[r][c];
      }
    }
    engine.currentPlayer = snap.currentPlayer;
    engine.placingPhase = snap.placingPhase;
    engine.placedP1 = snap.placedP1;
    engine.placedP2 = snap.placedP2;
    engine.stonesLeftThisTurn = snap.stonesLeftThisTurn;
    engine.lastMove = snap.lastMove;
    _moveCount = snap.moveCount;
    _positionCounts
      ..clear()
      ..addAll(snap.positionCounts);
  }

  // ------------------------------------------------------------ إعادة اللعب

  void restart() {
    _aiTimer?.cancel();
    engine = SeegaEngine(size: boardSize);
    _ai = SeegaAi(difficulty, seed: debugAiSeed);
    _history.clear();
    _positionCounts
      ..clear()
      ..[engine.positionKey()] = 1;
    _moveCount = 0;
    lastMoveResult = null;
    lastPlaced = null;
    passPlayer = null;
    winner = null;
    drawReason = null;
    selectedTile = null;
    phase = TurnPhase.placing;
    _emit(ControllerEvent.placed);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _aiTimer?.cancel();
    super.dispose();
  }
}
