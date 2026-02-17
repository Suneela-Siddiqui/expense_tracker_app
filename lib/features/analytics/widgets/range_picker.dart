import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/features/analytics/widgets/analytics_helpers.dart';

class RangePicker extends StatelessWidget {
  final AnalyticsRange value;
  final ValueChanged<AnalyticsRange> onChanged;

  const RangePicker({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget chip(String text, AnalyticsRange v) {
      final selected = value == v;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onChanged(v),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? cs.primary.withValues(alpha: 0.12)
                  : cs.surfaceContainerHighest.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? cs.primary.withValues(alpha: 0.35)
                    : cs.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: selected ? cs.primary : cs.onSurface,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip("Today", AnalyticsRange.today),
        const SizedBox(width: Ui.s10),
        chip("Week", AnalyticsRange.week),
        const SizedBox(width: Ui.s10),
        chip("Month", AnalyticsRange.month),
        const SizedBox(width: Ui.s10),
        chip("All", AnalyticsRange.all),
      ],
    );
  }
}