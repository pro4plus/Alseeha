// لوحة اللعب v3.0: إطار خشبي مائل، آبار محفورة، نجمة نوبية في الوسط،
// وكل حركات §7 (سقوط، انزلاق، أكل، اهتزاز، موجة، تلميح، أثر).
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/seega_engine.dart';
import '../game/turn_controller.dart';
import '../l10n/strings.dart';
import '../theme/sudanese_theme.dart';
import 'effects/particles.dart';
import 'effects/shockwave.dart';

/// إشارات حركات ترسلها الشاشة إلى اللوحة (أرقام متسلسلة).
class BoardFx {
  int placedNonce = 0;
  List<int>? placedSquare;
  int moveNonce = 0;
  MoveResult? move;
  int shakeNonce = 0;
  List<int>? shakeSquare;
  int waveNonce = 0;
  int hintNonce = 0;
  SeegaMove? hintMove;
}

class BoardView extends StatefulWidget {
  final SeegaEngine engine;
  final TurnController controller;
  final BoardFx fx;
  final String p1Asset;
  final String p2Asset;
  final Strings strings;
  final void Function(int row, int col) onTapTile;
  final VoidCallback onFxDone;

  const BoardView({
    super.key,
    required this.engine,
    required this.controller,
    required this.fx,
    required this.p1Asset,
    required this.p2Asset,
    required this.strings,
    required this.onTapTile,
    required this.onFxDone,
  });

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _captureController;
  late final AnimationController _placeController;
  late final AnimationController _shakeController;
  late final AnimationController _waveController;
  late final AnimationController _hintController;
  late final AnimationController _trailController;
  late final AnimationController _pulseController;
  late final AnimationController _glowController;
  late final AnimationController _breathController;

  int _seenPlaced = 0;
  int _seenMove = 0;
  int _seenShake = 0;
  int _seenWave = 0;
  int _seenHint = 0;

  MoveResult? _slidingMove;
  MoveResult? _capturingMove;
  List<int>? _placingSquare;
  List<int>? _shakingSquare;
  SeegaMove? _hintMove;
  bool _waveActive = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 240));
    _captureController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _placeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 240));
    _waveController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _hintController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));
    _trailController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat();
    _breathController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    for (final c in [
      _slideController,
      _captureController,
      _placeController,
      _shakeController,
      _waveController,
      _hintController,
      _trailController,
      _pulseController,
      _glowController,
      _breathController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.engine != widget.engine) {
      // إعادة لعب: صفّر حالة الحركات المحلية.
      _slidingMove = null;
      _capturingMove = null;
      _placingSquare = null;
      _shakingSquare = null;
      _hintMove = null;
      _waveActive = false;
    }
    final fx = widget.fx;
    if (fx.placedNonce != _seenPlaced) {
      _seenPlaced = fx.placedNonce;
      _placingSquare = fx.placedSquare;
      _placeController.forward(from: 0);
    }
    if (fx.moveNonce != _seenMove) {
      _seenMove = fx.moveNonce;
      _startMoveAnimation(fx.move);
    }
    if (fx.shakeNonce != _seenShake) {
      _seenShake = fx.shakeNonce;
      _shakingSquare = fx.shakeSquare;
      _shakeController.forward(from: 0);
    }
    if (fx.waveNonce != _seenWave) {
      _seenWave = fx.waveNonce;
      _waveActive = true;
      _waveController.forward(from: 0).then((_) {
        if (mounted) setState(() => _waveActive = false);
      });
    }
    if (fx.hintNonce != _seenHint) {
      _seenHint = fx.hintNonce;
      _hintMove = fx.hintMove;
      _hintController.forward(from: 0);
    }
  }

  Future<void> _startMoveAnimation(MoveResult? move) async {
    if (move == null) return;
    _slidingMove = move;
    _capturingMove = null;
    await _slideController.forward(from: 0);
    if (!mounted) return;
    setState(() => _slidingMove = null);
    _trailController.forward(from: 0);
    if (move.captured.isNotEmpty) {
      _capturingMove = move;
      await _captureController.forward(from: 0);
      if (!mounted) return;
      setState(() => _capturingMove = null);
    }
    widget.onFxDone();
  }

  String _assetFor(int player) =>
      player == 1 ? widget.p1Asset : widget.p2Asset;

  List<List<int>> _destinations() {
    final sel = widget.controller.selectedTile;
    if (sel == null) return [];
    final out = <List<int>>[];
    for (final d in SeegaEngine.dirs) {
      final r = sel[0] + d[0];
      final c = sel[1] + d[1];
      if (widget.engine.inBounds(r, c) &&
          widget.engine.board[r][c] == 0) {
        out.add([r, c]);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final size = engine.size;
    final centre = size ~/ 2;
    final isCentreEmpty = engine.board[centre][centre] == 0;
    final destinations = _destinations();

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardPx = math.min(
              constraints.maxWidth, constraints.maxHeight);
          final cell = boardPx / size;
          final sel = widget.controller.selectedTile;
          final lastMove = engine.lastMove;

          return SizedBox(
            width: boardPx,
            height: boardPx,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(SudaneseTheme.radiusBoard),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B5A2B), Color(0xFF6B4423)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.25),
                    blurRadius: 2,
                    offset: const Offset(0, -1),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF5A3320),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  // ---- الآبار ----
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: size,
                    ),
                    itemCount: size * size,
                    itemBuilder: (context, index) {
                      final r = index ~/ size;
                      final c = index % size;
                      final isCentre = r == centre && c == centre;
                      final isDest = destinations.any(
                          (d) => d[0] == r && d[1] == c);
                      final isLast = lastMove != null &&
                          ((lastMove.fromRow == r &&
                                  lastMove.fromCol == c) ||
                              (lastMove.toRow == r &&
                                  lastMove.toCol == c));
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onTapTile(r, c),
                        child: Semantics(
                          button: true,
                          label: _tileLabel(r, c),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.9,
                                colors: isCentre
                                    ? [
                                        SudaneseTheme.centerTile,
                                        const Color(0xFF9FD0D8),
                                      ]
                                    : (r + c) % 2 == 0
                                        ? [
                                            SudaneseTheme.tileLight,
                                            const Color(0xFFE2C79B),
                                          ]
                                        : [
                                            SudaneseTheme.tileDark,
                                            const Color(0xFFC9A672),
                                          ],
                              ),
                              border: isLast
                                  ? Border.all(
                                      color: SudaneseTheme.nile
                                          .withValues(alpha: 0.8),
                                      width: 2,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.25),
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isCentre && isCentreEmpty
                                ? AnimatedBuilder(
                                    animation: _glowController,
                                    builder: (context, child) {
                                      final t = _glowController.value;
                                      final glow =
                                          (math.sin(t * math.pi * 2) +
                                                  1) /
                                              2;
                                      return CustomPaint(
                                        painter: NubianStarPainter(
                                          color: SudaneseTheme.nile
                                              .withValues(alpha: 0.75),
                                          glow: 0.3 + glow * 0.7,
                                        ),
                                      );
                                    },
                                  )
                                : isDest
                                    ? AnimatedBuilder(
                                        animation: _pulseController,
                                        builder: (context, child) {
                                          final s = 0.9 +
                                              _pulseController.value *
                                                  0.2;
                                          return Center(
                                            child: Transform.scale(
                                              scale: s,
                                              child: Container(
                                                width: cell * 0.34,
                                                height: cell * 0.34,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: SudaneseTheme
                                                      .palm
                                                      .withValues(
                                                          alpha: 0.55),
                                                  border: Border.all(
                                                    color: SudaneseTheme
                                                        .palm,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : null,
                          ),
                        ),
                      );
                    },
                  ),
                  // ---- أثر الحركة الأخيرة (خط يتلاشى 1.2 ث) ----
                  if (lastMove != null)
                    AnimatedBuilder(
                      animation: _trailController,
                      builder: (context, child) {
                        final t = _trailController.value;
                        if (t >= 1 && _trailController.isCompleted) {
                          return const SizedBox.shrink();
                        }
                        return CustomPaint(
                          size: Size(boardPx - 16, boardPx - 16),
                          painter: _TrailPainter(
                            from: Offset(
                              (lastMove.fromCol + 0.5) * cell,
                              (lastMove.fromRow + 0.5) * cell,
                            ),
                            to: Offset(
                              (lastMove.toCol + 0.5) * cell,
                              (lastMove.toRow + 0.5) * cell,
                            ),
                            opacity: (1 - t) * 0.7,
                          ),
                        );
                      },
                    ),
                  // ---- الحجارة ----
                  ..._buildStones(size, cell, sel),
                  // ---- حجر الانزلاق (طبقة فوق الحجارة) ----
                  if (_slidingMove != null)
                    AnimatedBuilder(
                      animation: _slideController,
                      builder: (context, child) {
                        final t = Curves.easeInOutCubic.transform(
                            _slideController.value);
                        final m = _slidingMove!.move;
                        final from = Offset(
                            (m.fromCol + 0.5) * cell, (m.fromRow + 0.5) * cell);
                        final to = Offset(
                            (m.toCol + 0.5) * cell, (m.toRow + 0.5) * cell);
                        final pos = Offset.lerp(from, to, t)!;
                        final stonePx = cell * 0.82;
                        return Positioned(
                          left: pos.dx - stonePx / 2,
                          top: pos.dy - stonePx / 2,
                          child: Transform.scale(
                            scale: 1 + 0.08 * math.sin(t * math.pi),
                            child: _stoneImage(
                                _assetFor(_slidingMove!.mover), stonePx),
                          ),
                        );
                      },
                    ),
                  // ---- الحجارة المأكولة (تنكمش وتدور وتتلاشى) ----
                  if (_capturingMove != null)
                    AnimatedBuilder(
                      animation: _captureController,
                      builder: (context, child) {
                        final t = _captureController.value;
                        final captured = _capturingMove!.captured;
                        final stonePx = cell * 0.82;
                        final widgets = <Widget>[];
                        for (var i = 0; i < captured.length; i++) {
                          final sq = captured[i];
                          final interval = Interval(
                            (i * 0.07).clamp(0.0, 0.8),
                            1.0,
                            curve: Curves.easeIn,
                          );
                          final lt = interval.transform(t);
                          final scale = 1 - lt;
                          final opacity = 1 - lt;
                          final rotation = lt * 0.6;
                          final cx = (sq[1] + 0.5) * cell;
                          final cy = (sq[0] + 0.5) * cell;
                          widgets.add(Positioned(
                            left: cx - stonePx / 2,
                            top: cy - stonePx / 2,
                            child: Opacity(
                              opacity: opacity.clamp(0.0, 1.0),
                              child: Transform.rotate(
                                angle: rotation,
                                child: Transform.scale(
                                  scale: scale.clamp(0.0, 1.0),
                                  child: _stoneImage(
                                    _assetFor(
                                        3 - _capturingMove!.mover),
                                    stonePx,
                                  ),
                                ),
                              ),
                            ),
                          ));
                          widgets.add(Positioned.fill(
                            child: ParticleBurst(
                              origin: Offset(cx, cy),
                              size: cell,
                              color: SudaneseTheme.gold,
                              count: 7,
                            ),
                          ));
                          widgets.add(Positioned.fill(
                            child: Shockwave(
                              origin: Offset(cx, cy),
                              maxRadius: cell * 0.9,
                            ),
                          ));
                        }
                        // شارة x2 / x3 للأكل المتعدد + اهتزاز دقيق.
                        if (captured.length > 1) {
                          final m = _capturingMove!.move;
                          final dx = math.sin(t * math.pi * 4) * 2 * (1 - t);
                          widgets.add(Positioned(
                            left: (m.toCol + 0.5) * cell - 14 + dx,
                            top: (m.toRow + 0.5) * cell - cell * 0.55,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: SudaneseTheme.gold,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                                boxShadow:
                                    SudaneseTheme.softShadow(opacity: 0.3),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'x${captured.length}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ));
                        }
                        return Stack(children: widgets);
                      },
                    ),
                  // ---- سهم التلميح (3 ثوانٍ) ----
                  if (_hintMove != null && _hintController.isAnimating)
                    AnimatedBuilder(
                      animation: _hintController,
                      builder: (context, child) {
                        final pulse = 0.6 +
                            0.4 *
                                math.sin(
                                    _hintController.value * math.pi * 6);
                        return CustomPaint(
                          size: Size(boardPx - 16, boardPx - 16),
                          painter: _HintPainter(
                            from: Offset(
                              (_hintMove!.fromCol + 0.5) * cell,
                              (_hintMove!.fromRow + 0.5) * cell,
                            ),
                            to: Offset(
                              (_hintMove!.toCol + 0.5) * cell,
                              (_hintMove!.toRow + 0.5) * cell,
                            ),
                            alpha: pulse,
                          ),
                        );
                      },
                    ),
                  // ---- موجة نهاية التوزيع (500ms من الوسط) ----
                  if (_waveActive)
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        final t = Curves.easeOutCubic.transform(
                            _waveController.value);
                        final centrePx = boardPx / 2 - 8;
                        return CustomPaint(
                          size: Size(boardPx - 16, boardPx - 16),
                          painter: _WavePainter(
                            centre: Offset(centrePx, centrePx),
                            radius: t * boardPx * 0.7,
                            alpha: (1 - t) * 0.6,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildStones(int size, double cell, List<int>? sel) {
    final engine = widget.engine;
    final widgets = <Widget>[];
    final stonePx = cell * 0.82;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final value = engine.board[r][c];
        if (value == 0) continue;
        // الحجر المنزلق يُخفى من مكانه الأصلي أثناء الانزلاق.
        if (_slidingMove != null &&
            _slidingMove!.move.toRow == r &&
            _slidingMove!.move.toCol == c) {
          continue;
        }
        // الحجارة المأكولة تُخفى أثناء حركة الأكل (تُرسم في الطبقة).
        if (_capturingMove != null &&
            _capturingMove!.captured
                .any((sq) => sq[0] == r && sq[1] == c)) {
          continue;
        }
        final isSelected =
            sel != null && sel[0] == r && sel[1] == c;
        final isPlacing = _placingSquare != null &&
            _placingSquare![0] == r &&
            _placingSquare![1] == c;
        final isShaking = _shakingSquare != null &&
            _shakingSquare![0] == r &&
            _shakingSquare![1] == c;
        final cx = (c + 0.5) * cell;
        final cy = (r + 0.5) * cell;

        Widget stone = _stoneImage(_assetFor(value), stonePx);

        if (isSelected) {
          stone = AnimatedBuilder(
            animation: _breathController,
            builder: (context, child) {
              final breath = 0.5 + _breathController.value * 0.5;
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: SudaneseTheme.gold
                          .withValues(alpha: 0.35 + breath * 0.4),
                      blurRadius: 14,
                      spreadRadius: 3,
                    ),
                  ],
                  border: Border.all(
                    color: SudaneseTheme.gold,
                    width: 2.5,
                  ),
                ),
                child: child,
              );
            },
            child: stone,
          );
        }

        stone = AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: stone,
        );

        if (isPlacing) {
          stone = AnimatedBuilder(
            animation: _placeController,
            builder: (context, child) {
              final t = Curves.easeOutCubic.transform(
                  _placeController.value);
              final drop = (1 - t) * -cell * 0.6;
              final squash = t < 0.85 ? 1.0 : 1.0 - (t - 0.85) * 0.6;
              return SizedBox(
                width: stonePx,
                height: stonePx,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // حلقة غبار تتسع وتتلاشى عند سقوط الحجر.
                    Opacity(
                      opacity: (1 - t) * 0.6,
                      child: Container(
                        width: stonePx * (0.8 + t * 0.7),
                        height: stonePx * (0.8 + t * 0.7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: SudaneseTheme.gold
                                .withValues(alpha: 0.8),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, drop),
                      child: Transform.scale(
                        scaleY: squash,
                        scaleX: 1 + (1 - squash) * 0.5,
                        child: child,
                      ),
                    ),
                  ],
                ),
              );
            },
            child: stone,
          );
        }

        if (isShaking) {
          stone = AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final t = _shakeController.value;
              final dx =
                  math.sin(t * math.pi * 4) * 4 * (1 - t);
              return Transform.translate(
                offset: Offset(dx, 0),
                child: Opacity(
                  opacity: 1 - t * 0.2,
                  child: child,
                ),
              );
            },
            child: stone,
          );
        }

        widgets.add(Positioned(
          left: cx - stonePx / 2,
          top: cy - stonePx / 2,
          child: stone,
        ));
      }
    }
    return widgets;
  }

  Widget _stoneImage(String asset, double px) {
    return SizedBox(
      width: px,
      height: px,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ظل تلامس أسفل الحجر.
          Positioned(
            bottom: 0,
            child: Container(
              width: px * 0.7,
              height: px * 0.18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          Image.asset(asset, width: px * 0.94, height: px * 0.94),
        ],
      ),
    );
  }

  String _tileLabel(int r, int c) {
    final s = widget.strings;
    final value = widget.engine.board[r][c];
    final centre = widget.engine.size ~/ 2;
    final parts = <String>[s.tileLabel(r, c)];
    if (r == centre && c == centre) parts.add(s.tileCentre);
    if (value == 0) {
      parts.add(s.tileEmpty);
    } else if (value == widget.engine.currentPlayer &&
        widget.controller.isHumanTurn) {
      parts.add(s.tileYourStone);
    } else {
      parts.add(s.tileOpponentStone);
    }
    return parts.join('، ');
  }
}

class _TrailPainter extends CustomPainter {
  final Offset from, to;
  final double opacity;

  _TrailPainter(
      {required this.from, required this.to, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SudaneseTheme.nile.withValues(alpha: opacity)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

class _HintPainter extends CustomPainter {
  final Offset from, to;
  final double alpha;

  _HintPainter(
      {required this.from, required this.to, required this.alpha});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SudaneseTheme.gold.withValues(alpha: alpha)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    // رأس السهم.
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const head = 12.0;
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - head * math.cos(angle - 0.5),
          to.dy - head * math.sin(angle - 0.5))
      ..lineTo(to.dx - head * math.cos(angle + 0.5),
          to.dy - head * math.sin(angle + 0.5))
      ..close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _HintPainter oldDelegate) =>
      oldDelegate.alpha != alpha;
}

class _WavePainter extends CustomPainter {
  final Offset centre;
  final double radius;
  final double alpha;

  _WavePainter(
      {required this.centre, required this.radius, required this.alpha});

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0) return;
    final paint = Paint()
      ..color = SudaneseTheme.gold.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(centre, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.radius != radius;
}
