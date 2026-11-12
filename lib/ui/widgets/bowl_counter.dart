// عدّاد الصحن (§5.3 + لوحة التصميم): صحن طيني فيه حصوات
// بلون الحجارة الموجودة فيه فعلاً، وتحته التسمية والعدد
// (أكلت N / باقي M).
import 'package:flutter/material.dart';

import '../../theme/sudanese_theme.dart';
import '../painters/bowl.dart';

class BowlCounter extends StatelessWidget {
  final PebbleDef pebble;
  final int count;
  final String label;

  const BowlCounter({
    super.key,
    required this.pebble,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              size: const Size(64, 50),
              painter: BowlPainter(pebble: pebble, count: count),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$label $count',
              style: SudaneseTheme.bodyBold.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
