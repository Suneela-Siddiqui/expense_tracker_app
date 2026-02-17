import 'package:flutter/material.dart';

class MonthHeader extends StatelessWidget {
  final String monthText;
  final VoidCallback onTapFilter;

  /// ✅ NEW
  final bool hasActiveFilters;

  const MonthHeader({
    super.key,
    required this.monthText,
    required this.onTapFilter,
    this.hasActiveFilters = false,
  });

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
          color: hasActiveFilters
              ? cs.primaryContainer
              : cs.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTapFilter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: hasActiveFilters
                        ? cs.onPrimaryContainer
                        : cs.onSurface,
                  ),
                  const SizedBox(width: 6),

                  Text(
                    hasActiveFilters ? "Filtered" : "Filters",
                    style: t.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: hasActiveFilters
                          ? cs.onPrimaryContainer
                          : null,
                    ),
                  ),

                  if (hasActiveFilters) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
