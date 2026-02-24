import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  /// Pass:
  /// - cs.primary (raspberry) for “This month”
  /// - cs.secondary (deep space) for “Remaining”
  final Color tint;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Ui.s14),
      decoration: BoxDecoration(
        // ✅ premium neutral surface
        color: cs.surfaceContainerHighest.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.75),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ✅ brand accent strip (small + classy)
          Container(
            width: 6,
            height: 44,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: Ui.s12),

          // ✅ icon chip (subtle tint)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(Ui.r14),
              border: Border.all(
                color: tint.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: cs.secondary, // ✅ Deep Space structural
            ),
          ),

          const SizedBox(width: Ui.s12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                      color: cs.secondary, // ✅ Deep Space
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}