// كوّة الخصم (§5.3 + لوحة التصميم): قوس داكن فيه الشخصية،
// وتحتها بطاقة قش بالاسم والمستوى. المختارة مضيئة بإطار
// ذهبي، والأخريات معتمة. عند الاختيار تومئ الشخصية برأسها.
import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';
import '../painters/elder.dart';

class OpponentNiche extends StatefulWidget {
  final ElderKind kind;
  final String name;
  final String level;
  final bool selected;
  final VoidCallback? onTap;

  const OpponentNiche({
    super.key,
    required this.kind,
    required this.name,
    required this.level,
    required this.selected,
    this.onTap,
  });

  @override
  State<OpponentNiche> createState() => _OpponentNicheState();
}

class _OpponentNicheState extends State<OpponentNiche>
    with SingleTickerProviderStateMixin {
  late final AnimationController _nod;

  @override
  void initState() {
    super.initState();
    _nod = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void didUpdateWidget(covariant OpponentNiche oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _nod.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _nod.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Opacity(
        opacity: widget.selected ? 1.0 : 0.72,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(70),
              bottom: Radius.circular(16),
            ),
            border: widget.selected
                ? Border.all(color: SudaneseTheme.sunGold, width: 3)
                : Border.all(color: Colors.transparent, width: 3),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: SudaneseTheme.sunGold.withValues(alpha: 0.45),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(67),
              bottom: Radius.circular(13),
            ),
            child: Container(
              color: widget.selected
                  ? const Color(0xFF5A3A22)
                  : const Color(0xFF3A2418),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: _nod,
                    builder: (context, child) {
                      final nod = _nod.value < 0.5
                          ? _nod.value * 2
                          : (1 - _nod.value) * 2;
                      return RepaintBoundary(
                        child: CustomPaint(
                          size: const Size(78, 100),
                          painter: ElderPainter(
                            kind: widget.kind,
                            tilt: nod * 0.12,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: double.infinity,
                    color: SudaneseTheme.straw.withValues(alpha: 0.9),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.name,
                            style: SudaneseTheme.heading.copyWith(
                              fontSize: 17,
                              color: SudaneseTheme.ink,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.level,
                            style: SudaneseTheme.caption.copyWith(
                              color: SudaneseTheme.ink
                                  .withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
