// شاشة اللعب: التوزيع ثم الحركة، ضد الكمبيوتر أو لاعب ثانٍ.
// إصلاحات عن النسخة القديمة:
//  * الفائز يُحدد من engine.winner() مباشرة (لا من الدور الحالي بعد تبديله).
//  * لا Positioned بأرقام ثابتة — تخطيط متجاوب بالكامل.
//  * AudioPlayer يُغلق في dispose، وSplash يتحقق من mounted.
//  * قواعد v1.0 الأصلية محفوظة: توزيع 3 أحجار، الوسطى فاضية للتوزيع
//    وأول حركة إليها، أكل بالحصار بلا حماية للوسطى، فوز بصفر حجارة.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/seega_ai.dart';
import '../game/seega_engine.dart';
import '../game/sound_manager.dart';
import '../l10n/strings.dart';
import '../theme/sudanese_theme.dart';
import 'home_screen.dart';

class GameScreen extends StatefulWidget {
  final bool isArabic;
  final int gridSize;
  final bool vsComputer;
  final Difficulty difficulty;
  final String playerOneStone;
  final String playerTwoStone;

  const GameScreen({
    super.key,
    required this.isArabic,
    required this.gridSize,
    required this.vsComputer,
    required this.difficulty,
    required this.playerOneStone,
    required this.playerTwoStone,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SeegaEngine _engine;
  late SeegaAi _ai;
  final SoundManager _sound = SoundManager();

  int? _selectedRow;
  int? _selectedCol;
  List<SeegaMove> _validMoves = [];
  SeegaMove? _hintMove;
  SeegaMove? _lastMove;
  bool _aiThinking = false;
  bool _dialogShown = false;
  bool _soundOn = true;

  int _eatenByP1 = 0;
  int _eatenByP2 = 0;
  int _wins = 0, _losses = 0, _draws = 0;

  /// لقطات قبل كل حركة بشرية (للتراجع ضد الكمبيوتر فقط).
  final List<SeegaEngine> _history = [];

  /// تتبع تكرار الأوضاع وعدد الحركات بلا أكل — لمنع الدوران الأبدي:
  /// تكرار نفس الوضع 3 مرات أو 60 حركة بلا أكل = تعادل.
  final Map<String, int> _positions = {};
  int _movesSinceCapture = 0;

  Strings get s => Strings(widget.isArabic);

  @override
  void initState() {
    super.initState();
    _engine = SeegaEngine(size: widget.gridSize);
    _ai = SeegaAi(widget.difficulty);
    _sound.start();
  }

  @override
  void dispose() {
    _sound.dispose();
    super.dispose();
  }

  bool get _humanTurn =>
      !_engine.placingPhase &&
      (!widget.vsComputer || _engine.currentPlayer == 1);

  String _stoneAsset(int player) =>
      player == 1 ? widget.playerOneStone : widget.playerTwoStone;

  // ---------- التوزيع ----------

  Future<void> _aiPlaceLoop() async {
    while (mounted &&
        _engine.placingPhase &&
        widget.vsComputer &&
        _engine.currentPlayer == 2) {
      await Future.delayed(const Duration(milliseconds: 550));
      if (!mounted) return;
      final spot = _ai.choosePlacement(_engine);
      if (spot[0] < 0) return;
      setState(() {
        _engine.placeStone(spot[0], spot[1]);
      });
      _sound.place();
      HapticFeedback.lightImpact();
    }
    if (mounted && !_engine.placingPhase) {
      _sound.start();
      _showSnack(s.placementDone);
    }
  }

  // ---------- الحركة ----------

  void _onTileTap(int r, int c) {
    if (_dialogShown || _aiThinking) return;
    if (_engine.winner() != null) return;

    if (_engine.placingPhase) {
      if (widget.vsComputer && _engine.currentPlayer == 2) return;
      if (_engine.board[r][c] != 0 || _engine.isCenter(r, c)) {
        _sound.invalid();
        HapticFeedback.heavyImpact();
        return;
      }
      setState(() {
        _engine.placeStone(r, c);
      });
      _sound.place();
      HapticFeedback.lightImpact();
      if (!_engine.placingPhase) {
        _sound.start();
        _showSnack(s.placementDone);
      } else if (widget.vsComputer && _engine.currentPlayer == 2) {
        _aiPlaceLoop();
      }
      return;
    }

    // مرحلة الحركة.
    if (widget.vsComputer && _engine.currentPlayer == 2) return;
    final cell = _engine.board[r][c];
    if (_selectedRow == null) {
      if (cell == _engine.currentPlayer) {
        _select(r, c);
      }
      return;
    }
    if (_selectedRow == r && _selectedCol == c) {
      setState(() {
        _selectedRow = null;
        _selectedCol = null;
        _validMoves = [];
      });
      return;
    }
    final target = _validMoves.where(
        (m) => m.toRow == r && m.toCol == c);
    if (target.isNotEmpty) {
      _doMove(target.first, byHuman: true);
      return;
    }
    if (cell == _engine.currentPlayer) {
      _select(r, c);
      return;
    }
    setState(() {
      _selectedRow = null;
      _selectedCol = null;
      _validMoves = [];
    });
    _sound.invalid();
  }

  void _select(int r, int c) {
    _sound.select();
    setState(() {
      _selectedRow = r;
      _selectedCol = c;
      _validMoves = _engine
          .legalMoves(_engine.currentPlayer)
          .where((m) => m.fromRow == r && m.fromCol == c)
          .toList();
      _hintMove = null;
    });
  }

  void _doMove(SeegaMove move, {required bool byHuman}) {
    if (byHuman && widget.vsComputer) {
      _history.add(_engine.clone());
      if (_history.length > 40) _history.removeAt(0);
    }
    final mover = _engine.currentPlayer;
    final eaten = _engine.applyMove(move);
    if (eaten < 0) {
      _sound.invalid();
      return;
    }
    setState(() {
      _lastMove = move;
      _selectedRow = null;
      _selectedCol = null;
      _validMoves = [];
      _hintMove = null;
      if (mover == 1) {
        _eatenByP1 += eaten;
      } else {
        _eatenByP2 += eaten;
      }
    });
    if (eaten > 0) {
      _sound.eat();
      HapticFeedback.mediumImpact();
    } else {
      _sound.move();
      HapticFeedback.lightImpact();
    }
    // منع الدوران الأبدي: تكرار الوضع 3 مرات أو 60 حركة بلا أكل = تعادل.
    final key = _engine.positionKey();
    _positions[key] = (_positions[key] ?? 0) + 1;
    if (eaten > 0) {
      _movesSinceCapture = 0;
    } else {
      _movesSinceCapture++;
    }
    if (_positions[key]! >= 3 || _movesSinceCapture >= 60) {
      _showVictory(0);
      return;
    }
    _afterMove();
  }

  /// بعد كل حركة: فوز؟ تمرير دور (لاعب بلا حركة)؟ أم دور الكمبيوتر؟
  void _afterMove() {
    final w = _engine.winner();
    if (w != null) {
      _showVictory(w);
      return;
    }
    if (_engine.passIfStuck()) {
      _showSnack(s.passTurn);
      _sound.invalid();
    }
    if (widget.vsComputer && _engine.currentPlayer == 2) {
      _scheduleAiMove();
    }
  }

  void _scheduleAiMove() {
    setState(() => _aiThinking = true);
    Future.delayed(const Duration(milliseconds: 650), () async {
      if (!mounted) return;
      final move = _ai.chooseMove(_engine);
      if (!mounted) return;
      setState(() => _aiThinking = false);
      if (move == null) {
        // الكمبيوتر بلا حركة: مرّر الدور للاعب.
        if (_engine.passIfStuck()) _showSnack(s.passTurn);
        return;
      }
      _doMove(move, byHuman: false);
    });
  }

  void _undo() {
    if (!widget.vsComputer || _history.isEmpty) return;
    if (!_engine.placingPhase && _engine.currentPlayer != 1) return;
    if (_aiThinking || _dialogShown) return;
    setState(() {
      _engine = _history.removeLast();
      _selectedRow = null;
      _selectedCol = null;
      _validMoves = [];
      _hintMove = null;
      _lastMove = null;
      _positions.clear();
      _movesSinceCapture = 0;
      // إعادة حساب المأكول من اللوحة.
      _eatenByP1 = _engine.stonesPerPlayer - _engine.count(2);
      _eatenByP2 = _engine.stonesPerPlayer - _engine.count(1);
    });
    _sound.select();
  }

  void _showHint() {
    if (_engine.placingPhase || !_humanTurn || _aiThinking) return;
    final hint = SeegaAi(Difficulty.medium).hint(_engine);
    if (hint == null) return;
    setState(() => _hintMove = hint);
    _sound.select();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _hintMove == hint) {
        setState(() => _hintMove = null);
      }
    });
  }

  // ---------- الفوز ----------

  void _showVictory(int winner) {
    if (_dialogShown) return;
    _dialogShown = true;
    String title;
    String message;
    if (winner == 0) {
      _draws++;
      title = s.draw;
      message = s.draw;
      _sound.lose();
    } else if (widget.vsComputer) {
      if (winner == 1) {
        _wins++;
        title = s.victory;
        message = s.youWon;
        _sound.win();
      } else {
        _losses++;
        title = s.victory;
        message = s.computerWon;
        _sound.lose();
      }
    } else {
      title = s.victory;
      message = s.playerWon(winner == 1 ? s.player1 : s.player2);
      _sound.win();
    }
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18)),
            if (widget.vsComputer) ...[
              const SizedBox(height: 12),
              Text(
                '${s.wins}: $_wins   •   ${s.losses}: $_losses   •   ${s.draws}: $_draws',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context)
                .popUntil((route) => route.isFirst),
            child: Text(s.backHome),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    isArabic: widget.isArabic,
                    gridSize: widget.gridSize,
                    vsComputer: widget.vsComputer,
                    difficulty: widget.difficulty,
                    playerOneStone: widget.playerOneStone,
                    playerTwoStone: widget.playerTwoStone,
                  ),
                ),
              );
            },
            child: Text(s.playAgain),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> _confirmExit() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.confirmExit),
        content: Text(s.exitQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.yes),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  // ---------- الواجهة ----------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit()) {
          if (context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.appTitle),
          actions: [
            IconButton(
              icon: Icon(
                  _soundOn ? Icons.volume_up : Icons.volume_off),
              onPressed: () {
                setState(() {
                  _soundOn = !_soundOn;
                  _sound.enabled = _soundOn;
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            SudaneseTheme.nubianStrip(height: 8),
            _buildPlayerBar(
              player: 2,
              name: widget.vsComputer ? s.computer : s.player2,
              eaten: _eatenByP2,
              isTop: true,
            ),
            _buildTurnBanner(),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: _buildBoard(),
                  ),
                ),
              ),
            ),
            _buildPlayerBar(
              player: 1,
              name: widget.vsComputer ? s.you : s.player1,
              eaten: _eatenByP1,
              isTop: false,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: Row(
                children: [
                  if (widget.vsComputer) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _humanTurn ? _showHint : null,
                        icon: const Icon(Icons.lightbulb_outline),
                        label: Text(s.hint),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _history.isNotEmpty ? _undo : null,
                        icon: const Icon(Icons.undo),
                        label: Text(s.undo),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: Text(s.newGame),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SudaneseTheme.sudanRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerBar({
    required int player,
    required String name,
    required int eaten,
    required bool isTop,
  }) {
    final isTurn =
        !_engine.placingPhase && _engine.currentPlayer == player;
    final content = Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isTurn ? SudaneseTheme.goldLight : Colors.white,
        border: Border.all(
          color: isTurn ? SudaneseTheme.gold : Colors.grey.shade300,
          width: isTurn ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(_stoneAsset(player), width: 36, height: 36),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              name,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${s.captured}: $eaten  •  ${s.remaining}: ${_engine.count(player)}',
            style: const TextStyle(fontSize: 13),
          ),
          if (isTurn) ...[
            const SizedBox(width: 8),
            const Icon(Icons.circle,
                size: 10, color: SudaneseTheme.palm),
          ],
        ],
      ),
    );
    // في وضع لاعبين، اللاعب العلوي يجلس قبالة الشاشة.
    if (isTop && !widget.vsComputer) {
      return Transform.rotate(angle: 3.14159, child: content);
    }
    return content;
  }

  Widget _buildTurnBanner() {
    final String text;
    if (_engine.placingPhase) {
      if (widget.vsComputer && _engine.currentPlayer == 2) {
        text = s.computerPlacing;
      } else if (widget.vsComputer) {
        text = s.yourTurnPlace;
      } else {
        text =
            '${_engine.currentPlayer == 1 ? s.player1 : s.player2}: ${s.placeStones}';
      }
    } else if (_aiThinking) {
      text = s.computerThinking;
    } else if (_engine.currentPlayer == 1) {
      text = widget.vsComputer
          ? s.yourTurn
          : '${s.turn}: ${s.player1}';
    } else {
      text = widget.vsComputer
          ? s.computerThinking
          : '${s.turn}: ${s.player2}';
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        key: ValueKey(text),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_aiThinking)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            if (_aiThinking) const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: SudaneseTheme.clay),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard() {
    final size = widget.gridSize;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: size * size,
      itemBuilder: (context, index) {
        final r = index ~/ size;
        final c = index % size;
        final cell = _engine.board[r][c];
        final isSelected = _selectedRow == r && _selectedCol == c;
        final isValidTarget =
            _validMoves.any((m) => m.toRow == r && m.toCol == c);
        final isHint = _hintMove != null &&
            _hintMove!.fromRow == r &&
            _hintMove!.fromCol == c;
        final isHintTarget = _hintMove != null &&
            _hintMove!.toRow == r &&
            _hintMove!.toCol == c;
        final isLastMove = _lastMove != null &&
            ((_lastMove!.toRow == r && _lastMove!.toCol == c) ||
                (_lastMove!.fromRow == r && _lastMove!.fromCol == c));
        final isCenter = _engine.isCenter(r, c);

        Color tileColor;
        if (isSelected) {
          tileColor = SudaneseTheme.gold;
        } else if (isHint || isHintTarget) {
          tileColor = SudaneseTheme.palm.withValues(alpha: 0.55);
        } else if (isLastMove) {
          tileColor = SudaneseTheme.nile.withValues(alpha: 0.35);
        } else if (isCenter) {
          tileColor = SudaneseTheme.centerTile;
        } else if ((r + c) % 2 == 0) {
          tileColor = SudaneseTheme.tileLight;
        } else {
          tileColor = SudaneseTheme.tileDark;
        }

        return GestureDetector(
          onTap: () => _onTileTap(r, c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(8),
              border: isValidTarget
                  ? Border.all(
                      color: SudaneseTheme.palm, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: SudaneseTheme.gold.withValues(alpha: 0.7),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isCenter && cell == 0)
                  const Text('★',
                      style: TextStyle(
                          fontSize: 22,
                          color: SudaneseTheme.nile)),
                if (isValidTarget)
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: SudaneseTheme.palm,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (cell != 0)
                  AnimatedScale(
                    scale: isSelected ? 1.18 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(
                        _stoneAsset(cell),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
