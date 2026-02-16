import 'package:flutter/material.dart';

class MonthHeader extends StatelessWidget {
  final String monthText;
  final VoidCallback onTapFilter;
  const MonthHeader({super.key, required this.monthText, required this.onTapFilter});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            monthText,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Material(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTapFilter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, size: 18, color: cs.onSurface),
                  const SizedBox(width: 6),
                  Text(
                    "Filters",
                    style: t.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}