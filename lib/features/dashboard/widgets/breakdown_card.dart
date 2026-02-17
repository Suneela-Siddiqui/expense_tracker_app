import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/features/dashboard/widgets/mini_tag.dart';

class BreakdownCard extends StatelessWidget {
  final String total;
  final String today;
  final String yesterday;
  final List<String> topTags;

  const BreakdownCard({super.key, 
    required this.total,
    required this.today,
    required this.yesterday,
    required this.topTags,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Ui.r28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.92),
            cs.secondaryContainer.withValues(alpha: 0.62),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total spent",
              style: t.textTheme.bodySmall?.copyWith(
                color: cs.onPrimaryContainer.withValues(alpha: 0.72),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              total,
              style: t.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: Ui.s10),
            Wrap(
              spacing: Ui.s8,
              runSpacing: Ui.s8,
              children: [
                MiniTag(text: "Today • $today"),
                MiniTag(text: "Yesterday • $yesterday"),
              ],
            ),
            const Spacer(),
            Wrap(
              spacing: Ui.s8,
              runSpacing: Ui.s8,
              children: topTags.map((e) => MiniTag(text: e)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
