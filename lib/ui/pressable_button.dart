// زر v3.0: 56px كحد أدنى، تدرج، يصغر 0.96 عند الضغط خلال 80ms
// ثم يرجع بنابض خلال 160ms، مع صوت نقرة واهتزاز خفيف.
// الوسم لا يلتف أبداً (FittedBox) حتى لو طال.
import 'package:flutter/material.dart';

import '../game/haptics.dart';
import '../game/sound_manager.dart';
import '../theme/sudanese_theme.dart';

enum ButtonVariant { primary, secondary, danger, ghost, icon }

class PressableButton extends StatefulWidget {
  final String? label;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final double? height;
  final double? width;
  final String? tooltip;
  final bool enabled;

  const PressableButton({
    super.key,
    this.label,
    this.subtitle,
    this.icon,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.height,
    this.width,
    this.tooltip,
    this.enabled = true,
  });

  factory PressableButton.icon(
    IconData icon, {
    Key? key,
    VoidCallback? onPressed,
    String? tooltip,
  }) =>
      PressableButton(
        key: key,
        icon: icon,
        label: null,
        onPressed: onPressed,
        variant: ButtonVariant.icon,
        width: SudaneseTheme.buttonHeight,
        height: SudaneseTheme.buttonHeight,
        tooltip: tooltip,
      );

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _active => widget.enabled && widget.onPressed != null;

  void _pressDown(TapDownDetails _) {
    if (!_active) return;
    _controller.animateTo(1.0, duration: const Duration(milliseconds: 80));
  }

  void _pressUp(TapUpDetails _) {
    if (!_active) return;
    _controller.animateTo(0.0);
    Haptics.light();
    SoundManager.instance.tap();
    widget.onPressed!();
  }

  void _pressCancel() {
    _controller.animateTo(0.0);
  }

  List<Color> get _gradient {
    return switch (widget.variant) {
      ButtonVariant.primary => SudaneseTheme.nileGradient,
      ButtonVariant.secondary => SudaneseTheme.palmGradient,
      ButtonVariant.danger => SudaneseTheme.redGradient,
      ButtonVariant.ghost => [
          SudaneseTheme.surface,
          SudaneseTheme.surface,
        ],
      ButtonVariant.icon => SudaneseTheme.nileGradient,
    };
  }

  Color get _textColor {
    if (widget.variant == ButtonVariant.ghost) {
      return SudaneseTheme.nile;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isIcon = widget.variant == ButtonVariant.icon;
    final height = widget.height ?? SudaneseTheme.buttonHeight;
    final label = widget.label;
    final child = Opacity(
      opacity: _active ? 1.0 : 0.45,
      child: Container(
        width: widget.width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradient,
          ),
          borderRadius: BorderRadius.circular(
            isIcon ? height / 2 : SudaneseTheme.radiusButton,
          ),
          border: widget.variant == ButtonVariant.ghost
              ? Border.all(color: SudaneseTheme.nile.withValues(alpha: 0.35))
              : null,
          boxShadow: widget.variant == ButtonVariant.ghost
              ? null
              : SudaneseTheme.softShadow(opacity: 0.18),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null)
              Icon(widget.icon, color: _textColor, size: 22),
            if (widget.icon != null && label != null)
              const SizedBox(width: 8),
            if (label != null)
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                          height: 1.2,
                        ),
                      ),
                      if (widget.subtitle != null)
                        Text(
                          widget.subtitle!,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _textColor.withValues(alpha: 0.85),
                            height: 1.3,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    final button = ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: _pressDown,
        onTapUp: _pressUp,
        onTapCancel: _pressCancel,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}
