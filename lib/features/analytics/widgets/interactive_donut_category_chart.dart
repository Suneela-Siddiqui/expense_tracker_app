import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/features/analytics/widgets/analytics_helpers.dart';

class InteractiveDonutCategoryChart extends StatefulWidget {
  final Map<String, double> data;
  final double total;
  final String currencyCode;

  const InteractiveDonutCategoryChart({
    super.key,
    required this.data,
    required this.total,
    required this.currencyCode,
  });

  @override
  State<InteractiveDonutCategoryChart> createState() =>
      _InteractiveDonutCategoryChartState();
}

class _InteractiveDonutCategoryChartState
    extends State<InteractiveDonutCategoryChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final entries = widget.data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Top 5 + Other
    final top = entries.take(5).toList();
    final otherSum = entries.skip(5).fold<double>(0, (p, e) => p + e.value);

    final finalEntries = <MapEntry<String, double>>[
      ...top,
      if (otherSum > 0) MapEntry("Other", otherSum),
    ];

    final safeTotal = widget.total <= 0 ? 1.0 : widget.total;

    final selected =
        (_touchedIndex != null &&
                _touchedIndex! >= 0 &&
                _touchedIndex! < finalEntries.length)
            ? finalEntries[_touchedIndex!]
            : (finalEntries.isNotEmpty ? finalEntries.first : null);

    final selectedPct =
        selected == null ? 0 : ((selected.value / safeTotal) * 100);

    // ✅ IMPORTANT: keep donut size reasonable for dashboard cards
    const donutSize = 150.0; // <- safe across devices
    const gap = Ui.s18;
    const minLegendWidth = 170.0; // <- ensures legend doesn't collide

    final sections = List.generate(finalEntries.length, (i) {
      final e = finalEntries[i];
      final isTouched = _touchedIndex == i;

      final pct = (e.value / safeTotal) * 100;
      final bg = AnalyticsHelper().categoryColor(context, e.key);
      final onBg = AnalyticsHelper().onCategoryColor(context, bg);

      return PieChartSectionData(
        color: bg,
        value: e.value,
        radius: isTouched ? 54 : 48,
        title: pct < 6 ? "" : "${pct.round()}%",
        titleStyle: TextStyle(
          fontWeight: FontWeight.w900,
          color: onBg,
          fontSize: isTouched ? 13 : 12,
        ),
      );
    });

    Widget donutChart() {
      return SizedBox(
        width: donutSize,
        height: donutSize,
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 52,
            sectionsSpace: 2,
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                if (!event.isInterestedForInteractions) return;
                final idx = response?.touchedSection?.touchedSectionIndex;
                setState(() => _touchedIndex = idx);
              },
            ),
          ),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        ),
      );
    }

    Widget legend() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: finalEntries.where((e) => e.value > 0).map((e) {
          final pct = ((e.value / safeTotal) * 100).round();
          final dot = AnalyticsHelper().categoryColor(context, e.key);

          return Padding(
            padding: const EdgeInsets.only(bottom: Ui.s10),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dot,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 44,
                  child: Text(
                    "$pct%",
                    textAlign: TextAlign.right,
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(Ui.s20, Ui.s20, Ui.s20, Ui.s18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // ✅ Correct responsiveness: decide based on REAL required width
              final requiredWidth = donutSize + gap + minLegendWidth;
              final stack = constraints.maxWidth < requiredWidth;

              if (stack) {
                return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Ui.s6), // ✅ pushes donut down a bit
                  Padding(
                    padding: const EdgeInsets.only(top: Ui.s6, bottom: Ui.s4),
                    child: Align(
                      alignment: Alignment.center,
                      child: donutChart(),
                    ),
                  ),
                  const SizedBox(height: Ui.s18), // ✅ more breathing room before legend
                  legend(),
                ],
              );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  donutChart(),
                  const SizedBox(width: gap),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: minLegendWidth),
                      child: legend(),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: Ui.s14),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: selected == null
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey(selected.key),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Ui.s10,
                      vertical: Ui.s8,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AnalyticsHelper()
                                .categoryColor(context, selected.key),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selected.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AnalyticsHelper().money(
                            selected.value,
                            currencyCode: widget.currencyCode,
                          ),
                          style: t.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "(${selectedPct.toStringAsFixed(1)}%)",
                          style: t.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
