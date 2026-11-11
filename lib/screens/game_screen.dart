// شاشة اللعب v3.0: مبنية حول TurnController + BoardView.
// شريط علوي رفيع، بطاقتا لاعب، لافتة دور، لوحة، رصيف سفلي،
// قائمة إيقاف، وشاشة نتيجة كاملة مع قصاصات.
import 'dart:async';

import 'package:flutter/material.dart';

import '../game/seega_ai.dart';
import '../game/sound_manager.dart';
import '../game/turn_controller.dart';
import '../l10n/strings.dart';
import '../services/settings_store.dart';
import '../theme/sudanese_theme.dart';
import '../ui/board_view.dart';
import '../ui/effects/confetti.dart';
import '../ui/pressable_button.dart';
import '../ui/settings_sheet.dart';
import 'home_screen.dart';

class GameConfig {
  final int boardSize;
  final bool vsComputer;
  final Difficulty difficulty;
  final String p1Asset;
  final String p2Asset;

  const GameConfig({
    required this.boardSize,
    required this.vsComputer,
    this.difficulty = Difficulty.medium,
    required this.p1Asset,
    required this.p2Asset,
  });
}

class GameScreen extends StatefulWidget {
  final GameConfig config;

  /// وحدة تحكم جاهزة (للاختبارات فقط — لإعداد لوحة محددة).
  final TurnController? debugController;

  const GameScreen({super.key, required this.config, this.debugController});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late final TurnController _controller;
  final BoardFx _fx = BoardFx();
  int _seenNonce = 0;

  late final AnimationController _breath;
  String? _pill;
  Timer? _pillTimer;

  Strings get s => Strings(AppSettings.instance.isArabic);

  @override
  void initState() {
    super.initState();
    _controller = widget.debugController ??
        TurnController(
          boardSize: widget.config.boardSize,
          vsComputer: widget.config.vsComputer,
          difficulty: widget.config.difficulty,
        );
    _controller.addListener(_onControllerEvent);
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pillTimer?.cancel();
    _breath.dispose();
    _controller.removeListener(_onControllerEvent);
    if (widget.debugController == null) _controller.dispose();
    super.dispose();
  }

  void _onControllerEvent() {
    if (_controller.eventNonce == _seenNonce) return;
    _seenNonce = _controller.eventNonce;
    final event = _controller.lastEvent;
    if (!mounted) return;
    setState(() {
      switch (event) {
        case ControllerEvent.placed:
          _fx.placedNonce++;
          _fx.placedSquare = _controller.lastPlaced;
          break;
        case ControllerEvent.moved:
          _fx.moveNonce++;
          _fx.move = _controller.lastMoveResult;
          break;
        case ControllerEvent.invalid:
          _fx.shakeNonce++;
          _fx.shakeSquare = _controller.lastInvalidSquare;
          break;
        case ControllerEvent.placementEnded:
          _fx.waveNonce++;
          _showPill(s.letsPlay);
          break;
        case ControllerEvent.pass:
          _showPill(s.passTurn);
          break;
        case ControllerEvent.gameOver:
        case ControllerEvent.undo:
        case ControllerEvent.selected:
        case ControllerEvent.turnChanged:
        case null:
          break;
      }
    });
  }

  void _showPill(String message) {
    _pillTimer?.cancel();
    _pill = message;
    _pillTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _pill = null);
    });
  }

  void _onTileTap(int r, int c) {
    if (_controller.isPlacing) {
      _controller.placeStone(r, c);
    } else {
      _controller.tapTile(r, c);
    }
  }

  void _onHint() {
    final move = _controller.hint();
    if (move != null) {
      setState(() {
        _fx.hintNonce++;
        _fx.hintMove = move;
      });
    }
  }

  Future<void> _confirmLeave() async {
    final leave = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmSheet(
        strings: s,
        title: s.exitQuestion,
        confirmLabel: s.yes,
        cancelLabel: s.no,
      ),
    );
    if (leave == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showPauseMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PauseMenuSheet(
        strings: s,
        onResume: () => Navigator.of(context).pop(),
        onRestart: () {
          Navigator.of(context).pop();
          _controller.restart();
          setState(() {
            _fx.move = null;
            _fx.hintMove = null;
          });
        },
        onSettings: () {
          Navigator.of(context).pop();
          SettingsSheet.show(context, s);
        },
        onHowToPlay: () {
          Navigator.of(context).pop();
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => HowToPlaySheet(strings: s),
          );
        },
        onLeave: () async {
          Navigator.of(context).pop();
          await _confirmLeave();
        },
      ),
    );
  }

  String _nameFor(int player) {
    if (!widget.config.vsComputer) {
      return player == 1 ? s.player1 : s.player2;
    }
    return player == 1 ? s.you : s.computer;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmLeave();
      },
      child: AnimatedBuilder(
        animation: AppSettings.instance,
        builder: (context, child) {
          final controller = _controller;
          final engine = controller.engine;
          final isLoss = controller.phase == TurnPhase.gameOver &&
              widget.config.vsComputer &&
              controller.winner == 2;
          final content = Scaffold(
            body: SudaneseTheme.gradientBackground(
              child: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _topBar(),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          child: _playerCard(
                            player: 2,
                            rotate: !widget.config.vsComputer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _turnBanner(),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: BoardView(
                                  engine: engine,
                                  controller: controller,
                                  fx: _fx,
                                  p1Asset: widget.config.p1Asset,
                                  p2Asset: widget.config.p2Asset,
                                  strings: s,
                                  onTapTile: _onTileTap,
                                  onFxDone: () =>
                                      controller.finishAnimation(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          child: _playerCard(player: 1),
                        ),
                        const SizedBox(height: 10),
                        _bottomDock(),
                        const SizedBox(height: 12),
                      ],
                    ),
                    // رسالة عائمة.
                    if (_pill != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: MediaQuery.of(context).size.height * 0.42,
                        child: Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.0),
                            duration:
                                const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            builder: (context, scale, child) =>
                                Transform.scale(
                              scale: scale,
                              child: child,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: SudaneseTheme.ink
                                    .withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: SudaneseTheme.softShadow(),
                              ),
                              child: Text(
                                _pill!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // شاشة النتيجة.
                    if (controller.phase == TurnPhase.gameOver)
                      _resultOverlay(),
                  ],
                ),
              ),
            ),
          );
          if (!isLoss) return content;
          // الخسارة: إشباع منخفض للوحة خلف النتيجة.
          return ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            child: content,
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------- الشريط العلوي

  Widget _topBar() {
    final settings = AppSettings.instance;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            onPressed: _showPauseMenu,
            icon: const Icon(Icons.pause,
                color: SudaneseTheme.ink),
            tooltip: s.pause,
          ),
          Expanded(
            child: Text(
              s.appTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: SudaneseTheme.ink,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              final on = !settings.soundOn;
              await settings.setSoundOn(on);
              if (on) SoundManager.instance.tap();
              setState(() {});
            },
            icon: Icon(
              settings.soundOn ? Icons.volume_up : Icons.volume_off,
              color: SudaneseTheme.ink,
            ),
            tooltip: settings.soundOn ? s.soundOn : s.soundOff,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- بطاقة اللاعب

  Widget _playerCard({required int player, bool rotate = false}) {
    final controller = _controller;
    final engine = controller.engine;
    final isActive = engine.currentPlayer == player &&
        controller.phase != TurnPhase.gameOver &&
        controller.phase != TurnPhase.animating;
    final asset =
        player == 1 ? widget.config.p1Asset : widget.config.p2Asset;
    final onBoard = engine.count(player);
    // أثناء التوزيع لا يوجد أكل بعد: «باقي» = ما تبقّى في يد اللاعب
    // ليضعه، و«أكلت» = صفر. بعد التوزيع «باقي» = أحجاره على اللوحة.
    final captured = engine.placingPhase
        ? 0
        : engine.stonesPerPlayer - engine.count(3 - player);
    final remainingToPlace = engine.placingPhase
        ? engine.remainingToPlace(player)
        : 0;
    final left = engine.placingPhase ? remainingToPlace : onBoard;

    final card = Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SudaneseTheme.surface,
        borderRadius:
            BorderRadius.circular(SudaneseTheme.radiusCard),
        border: isActive
            ? Border.all(color: SudaneseTheme.gold, width: 3)
            : Border.all(color: Colors.transparent, width: 3),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: SudaneseTheme.gold
                      .withValues(alpha: 0.3 + _breath.value * 0.3),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ]
            : SudaneseTheme.softShadow(opacity: 0.08),
      ),
      child: Row(
        children: [
          Image.asset(asset, width: 40, height: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _nameFor(player),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SudaneseTheme.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.circle,
                        size: 12, color: SudaneseTheme.nile),
                    const SizedBox(width: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(
                              scale: animation, child: child),
                      child: Text(
                        '${s.remaining}: $left',
                        key: ValueKey(left),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: SudaneseTheme.clay,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.local_dining,
                        size: 13, color: SudaneseTheme.sudanRed),
                    const SizedBox(width: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(
                              scale: animation, child: child),
                      child: Text(
                        '${s.captured}: $captured',
                        key: ValueKey(captured),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: SudaneseTheme.clay,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: SudaneseTheme.gold,
                borderRadius: BorderRadius.circular(20),
                boxShadow: SudaneseTheme.softShadow(opacity: 0.25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _breath,
                    builder: (context, child) => Opacity(
                      opacity: 0.55 + _breath.value * 0.45,
                      child: child,
                    ),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    s.turnBadge,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          if (engine.placingPhase && remainingToPlace > 0)
            SizedBox(
              width: 110,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 2,
                runSpacing: 2,
                children: List.generate(
                  remainingToPlace,
                  (_) => Image.asset(asset, width: 12, height: 12),
                ),
              ),
            ),
          if (isActive && controller.isAiThinking && player == 2)
            const _ThinkingDots(),
        ],
      ),
    );

    final dimmed = Opacity(
      opacity: isActive ? 1.0 : 0.55,
      child: card,
    );
    if (rotate) {
      return RotatedBox(quarterTurns: 2, child: dimmed);
    }
    return dimmed;
  }

  // ---------------------------------------------------------- لافتة الدور

  Widget _turnBanner() {
    final controller = _controller;
    final engine = controller.engine;
    final activeAsset = engine.currentPlayer == 1
        ? widget.config.p1Asset
        : widget.config.p2Asset;

    String text;
    if (controller.phase == TurnPhase.gameOver) {
      text = '';
    } else if (engine.placingPhase) {
      if (widget.config.vsComputer && engine.currentPlayer == 2) {
        text = s.computerPlacing;
      } else {
        text = s.yourTurnPlace;
      }
    } else if (controller.isAiThinking) {
      text = s.computerThinking;
    } else {
      text = widget.config.vsComputer
          ? s.yourTurn
          : '${_nameFor(engine.currentPlayer)} — ${s.turn}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: Container(
          key: ValueKey(
              '$text-${engine.currentPlayer}-${engine.placingPhase}'),
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: SudaneseTheme.gold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SudaneseTheme.gold, width: 2),
            boxShadow: SudaneseTheme.softShadow(opacity: 0.08),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(activeAsset, width: 30, height: 30),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: SudaneseTheme.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (controller.isAiThinking) ...[
                const SizedBox(width: 8),
                const _ThinkingDots(),
              ],
              if (engine.placingPhase) ...[
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final filled = i < controller.placedThisTurn;
                    return Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 2),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? SudaneseTheme.gold
                            : SudaneseTheme.sandDark,
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------- الرصيف السفلي

  Widget _bottomDock() {
    final controller = _controller;
    final canHint = controller.isHumanTurn && !controller.isPlacing;
    if (!widget.config.vsComputer) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dockButton(
            icon: Icons.menu,
            label: s.menu,
            onPressed: _showPauseMenu,
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _dockButton(
          icon: Icons.lightbulb_outline,
          label: s.hint,
          onPressed: canHint ? _onHint : null,
          pulse: canHint,
        ),
        _dockButton(
          icon: Icons.undo,
          label: s.undo,
          onPressed: controller.canUndo
              ? () => controller.undo()
              : null,
        ),
        _dockButton(
          icon: Icons.menu,
          label: s.menu,
          onPressed: _showPauseMenu,
        ),
      ],
    );
  }

  Widget _dockButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool pulse = false,
  }) {
    final button = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PressableButton.icon(icon, onPressed: onPressed),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onPressed == null
                ? SudaneseTheme.clay.withValues(alpha: 0.5)
                : SudaneseTheme.ink,
          ),
        ),
      ],
    );
    if (!pulse || onPressed == null) return button;
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        final scale = 1.0 + _breath.value * 0.06;
        return Transform.scale(scale: scale, child: child);
      },
      child: button,
    );
  }

  // ---------------------------------------------------------- شاشة النتيجة

  Widget _resultOverlay() {
    final controller = _controller;
    final engine = controller.engine;
    final winner = controller.winner ?? 0;
    final isDraw = winner == 0;
    final humanWon = widget.config.vsComputer
        ? winner == 1
        : winner != 0;
    final capturedByP1 =
        engine.stonesPerPlayer - engine.count(2);
    final capturedByP2 =
        engine.stonesPerPlayer - engine.count(1);

    String title;
    String subtitle;
    if (isDraw) {
      title = s.draw;
      subtitle = s.drawLine;
    } else if (widget.config.vsComputer) {
      if (winner == 1) {
        title = s.victory;
        subtitle = s.youWon;
      } else {
        title = s.computerWon;
        subtitle = s.tryAgainLine;
      }
    } else {
      title = s.playerWon(_nameFor(winner));
      subtitle = '';
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: Stack(
          children: [
            if (humanWon) const Confetti(),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: BoxDecoration(
                    color: SudaneseTheme.surface,
                    borderRadius: BorderRadius.circular(
                        SudaneseTheme.radiusDialog),
                    boxShadow:
                        SudaneseTheme.softShadow(opacity: 0.3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isDraw
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(widget.config.p1Asset,
                                    width: 56, height: 56),
                                const SizedBox(width: 10),
                                Image.asset(widget.config.p2Asset,
                                    width: 56, height: 56),
                              ],
                            )
                          : const Icon(
                              Icons.emoji_events,
                              size: 72,
                              color: SudaneseTheme.gold,
                            ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: SudaneseTheme.ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 15,
                            color: SudaneseTheme.clay,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                        children: [
                          _resultStat(
                              _nameFor(1), capturedByP1),
                          _resultStat(
                              _nameFor(2), capturedByP2),
                        ],
                      ),
                      if (widget.config.vsComputer) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            _sessionChip(
                                s.wins, controller.sessionWins),
                            const SizedBox(width: 8),
                            _sessionChip(s.losses,
                                controller.sessionLosses),
                            const SizedBox(width: 8),
                            _sessionChip(
                                s.draws, controller.sessionDraws),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: PressableButton(
                          label: s.playAgain,
                          icon: Icons.replay,
                          onPressed: () {
                            _controller.restart();
                            setState(() {
                              _fx.move = null;
                              _fx.hintMove = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: PressableButton(
                          label: s.home,
                          icon: Icons.home,
                          variant: ButtonVariant.ghost,
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              FadeSlidePageRoute(
                                  builder: (_) =>
                                      const HomeScreen()),
                              (route) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultStat(String name, int captured) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: SudaneseTheme.clay,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$captured',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: SudaneseTheme.ink,
          ),
        ),
        Text(
          s.captured,
          style: const TextStyle(
            fontSize: 12,
            color: SudaneseTheme.clay,
          ),
        ),
      ],
    );
  }

  Widget _sessionChip(String label, int value) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SudaneseTheme.sand,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: SudaneseTheme.ink,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------- نقاط التفكير (3 نقاط متحركة)

class _ThinkingDots extends StatefulWidget {
  const _ThinkingDots();

  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase =
                (_controller.value * 3 + i) % 3 / 3;
            final opacity =
                0.3 + 0.7 * (1 - (phase - 0.5).abs() * 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SudaneseTheme.nile
                    .withValues(alpha: opacity.clamp(0.2, 1.0)),
              ),
            );
          }),
        );
      },
    );
  }
}

// ---------------------------------------------------------- قائمة الإيقاف

class _PauseMenuSheet extends StatelessWidget {
  final Strings strings;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final VoidCallback onHowToPlay;
  final VoidCallback onLeave;

  const _PauseMenuSheet({
    required this.strings,
    required this.onResume,
    required this.onRestart,
    required this.onSettings,
    required this.onHowToPlay,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final s = strings;
    return Container(
      decoration: const BoxDecoration(
        color: SudaneseTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SudaneseTheme.sandDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.pause,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: SudaneseTheme.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PressableButton(
            label: s.resume,
            icon: Icons.play_arrow,
            onPressed: onResume,
          ),
          const SizedBox(height: 10),
          PressableButton(
            label: s.restart,
            icon: Icons.replay,
            variant: ButtonVariant.ghost,
            onPressed: onRestart,
          ),
          const SizedBox(height: 10),
          PressableButton(
            label: s.settings,
            icon: Icons.settings,
            variant: ButtonVariant.ghost,
            onPressed: onSettings,
          ),
          const SizedBox(height: 10),
          PressableButton(
            label: s.howToPlay,
            icon: Icons.help_outline,
            variant: ButtonVariant.ghost,
            onPressed: onHowToPlay,
          ),
          const SizedBox(height: 10),
          PressableButton(
            label: s.leaveGame,
            icon: Icons.exit_to_app,
            variant: ButtonVariant.danger,
            onPressed: onLeave,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- ورقة تأكيد مشتركة

class _ConfirmSheet extends StatelessWidget {
  final Strings strings;
  final String title;
  final String confirmLabel;
  final String cancelLabel;

  const _ConfirmSheet({
    required this.strings,
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SudaneseTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: SudaneseTheme.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PressableButton(
                  label: confirmLabel,
                  variant: ButtonVariant.danger,
                  onPressed: () =>
                      Navigator.of(context).pop(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PressableButton(
                  label: cancelLabel,
                  variant: ButtonVariant.ghost,
                  onPressed: () =>
                      Navigator.of(context).pop(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
