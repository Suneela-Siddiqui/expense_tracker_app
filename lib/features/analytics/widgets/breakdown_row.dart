import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';

class BreakdownRow extends StatelessWidget {
  final String title;
  final String amount;
  final double progress;

  const BreakdownRow({super.key, required this.title, required this.amount, required this.progress});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: Ui.s10),
      padding: const EdgeInsets.all(Ui.s14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.isNaN ? 0 : progress,
                    minHeight: 8,
                    backgroundColor: cs.surface.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Ui.s12),
          Text(amount, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}