import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/features/analytics/widgets/analytics_helpers.dart';

class QuickStatsRow extends StatelessWidget {
  final String currencyCode;
  final double today;
  final double yesterday;
  final double month;
  final double allTime;

  const QuickStatsRow({
    super.key,
    required this.currencyCode,
    required this.today,
    required this.yesterday,
    required this.month,
    required this.allTime,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return SizedBox(
      height: 72, 
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          _StatChip(
            title: "Today",
            value: AnalyticsHelper().money(today, currencyCode: currencyCode),
          ),
          const SizedBox(width: Ui.s12),
          _StatChip(
            title: "Yesterday",
            value: AnalyticsHelper().money(yesterday, currencyCode: currencyCode),
          ),
          const SizedBox(width: Ui.s12),
          _StatChip(
            title: "Month",
            value: AnalyticsHelper().money(month, currencyCode: currencyCode),
          ),
          const SizedBox(width: Ui.s12),
          _StatChip(
            title: "All",
            value: AnalyticsHelper().money(allTime, currencyCode: currencyCode),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String title;
  final String value;

  const _StatChip({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      width: 105,              // 🔥 smaller width (was 120)
      padding: const EdgeInsets.symmetric(
        horizontal: Ui.s10,    // 🔥 tighter horizontal
        vertical: Ui.s10,      // 🔥 tighter vertical
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(Ui.r16), // slightly smaller radius
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.labelMedium?.copyWith(  // 🔥 smaller text
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),  // 🔥 reduced spacing
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.titleSmall?.copyWith(   // slightly smaller value
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
