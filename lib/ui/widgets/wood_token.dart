// زر خشبي دائري (§5.3): قرص خشب بحافة قش وأيقونة كريمية
// منقوشة. للقائمة والصوت والإعدادات والرجوع والتلميح والتراجع.
import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';

class WoodToken extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  const WoodToken({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 52,
    this.tooltip,
  });

  @override
  State<WoodToken> createState() => _WoodTokenState();
}

class _WoodTokenState extends State<WoodToken> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) {
          setState(() => _down = false);
          widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _down = false),
        child: AnimatedScale(
          scale: _down ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 90),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SudaneseTheme.wood,
              border: Border.all(
                color: SudaneseTheme.straw,
                width: 2.5,
              ),
              boxShadow: SudaneseTheme.hardShadow(),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: SudaneseTheme.cream,
                size: widget.size * 0.48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
