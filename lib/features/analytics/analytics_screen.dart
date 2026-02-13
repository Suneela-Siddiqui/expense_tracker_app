import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/models/expense.dart';
import 'package:fl_chart/fl_chart.dart';

enum _AnalyticsRange { today, week, month, all }

class AnalyticsScreen extends ConsumerStatefulWidget {
  static const routeName = '/analytics';
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  _AnalyticsRange range = _AnalyticsRange.month;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final appState = ref.watch(appStateProvider);
    final allExpenses = appState.expenses;

     final currencyCode = appState.currencyCode;

    final now = DateTime.now();

    final todayTotal = _sum(_filterDay(allExpenses, now));
    final yesterdayTotal = _sum(_filterDay(allExpenses, now.subtract(const Duration(days: 1))));
    final monthTotal = _sum(_filterMonth(allExpenses, now));
    final allTimeTotal = _sum(allExpenses);

    final filtered = _applyRange(allExpenses, range, now);

    final total = _sum(filtered);
    final byCategory = _groupByCategory(filtered);
    final daily = _dailyTotals(filtered, range, now);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Spending breakdown"),
      ),
      body: allExpenses.isEmpty
          ? _PrettyEmptyState(
              title: "No expenses yet",
              subtitle: "Add your first expense from the dashboard.",
              icon: Icons.pie_chart_rounded,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(Ui.s16, Ui.s12, Ui.s16, Ui.s24),
              children: [
                _RangePicker(
                  value: range,
                  onChanged: (v) => setState(() => range = v),
                ),
                const SizedBox(height: Ui.s14),

                _HeroTotalCard(
                  label: _rangeLabel(range),
                  total: _money(total, currencyCode: appState.currencyCode),
                ),

                const SizedBox(height: Ui.s12),

                _QuickStatsRow(
                  currencyCode: appState.currencyCode,
                  today: todayTotal,
                  yesterday: yesterdayTotal,
                  month: monthTotal,
                  allTime: allTimeTotal,
                ),

                const SizedBox(height: Ui.s18),

                if (daily.isNotEmpty) ...[
                  Text(
                    _dailyTitle(range),
                    style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: Ui.s10),
                  ...daily.map((d) {
                    final pct = (total <= 0) ? 0.0 : (d.amount / total).clamp(0.0, 1.0);
                    return _BreakdownRow(
                      title: d.label,
                      amount: _money(d.amount, currencyCode: appState.currencyCode),
                      progress: pct,
                    );
                  }),
                  const SizedBox(height: Ui.s16),
                ],

                Text(
                  "By category",
                  style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: Ui.s10),
                if (daily.isNotEmpty) ...[
                  const SizedBox(height: Ui.s16),
                  _SpendBarChart(daily),
                  const SizedBox(height: Ui.s16),
                ],

                if (byCategory.isNotEmpty) ...[
                  const SizedBox(height: Ui.s16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _InteractiveDonutCategoryChart(
                      key: ValueKey(range),  
                      data: byCategory,
                      total: total,
                      currencyCode: currencyCode,
                    ),
                  ),
                ],


                if (byCategory.isEmpty)
                  _HintCard(
                    title: "No spend in this range",
                    subtitle: "Try another time range above.",
                    icon: Icons.info_outline_rounded,
                  )
                else
                  ...byCategory.entries.map((entry) {
                    final cat = entry.key;
                    final amount = entry.value;
                    final pct = total <= 0 ? 0 : ((amount / total) * 100).round();

                    return _CategoryRow(
                      title: cat,
                      amount: _money(amount, currencyCode: appState.currencyCode),
                      percentText: "$pct%",
                      icon: _iconFromCategoryName(cat),
                      progress: (total <= 0) ? 0 : (amount / total).clamp(0.0, 1.0),
                    );
                  }),
              ],
            ),
    );
  }
}

class _SpendBarChart extends StatelessWidget {
  final List<_DayTotal> daily;
  const _SpendBarChart(this.daily);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final maxY = daily.map((e) => e.amount).fold<double>(0, (p, v) => v > p ? v : p);

    return Container(
      padding: const EdgeInsets.all(Ui.s16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            maxY: (maxY <= 0) ? 1 : (maxY * 1.2),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= daily.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        daily[i].label.length > 5 ? daily[i].label.substring(0, 5) : daily[i].label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(daily.length, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: daily[i].amount,
                    width: 14,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}


class _DonutCategoryChart extends StatelessWidget {
  final Map<String, double> data;
  final double total;

  const _DonutCategoryChart({
    required this.data,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // keep chart readable: top 5 + "Other"
    final top = entries.take(5).toList();
    final otherSum = entries.skip(5).fold<double>(0, (p, e) => p + e.value);

    final finalEntries = [
      ...top,
      if (otherSum > 0) MapEntry("Other", otherSum),
    ];

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < finalEntries.length; i++) {
      final e = finalEntries[i];
      final pct = total <= 0 ? 0 : (e.value / total);
      sections.add(
        PieChartSectionData(
          value: e.value,
          radius: 48,
          title: pct <= 0 ? "" : "${(pct * 100).round()}%",
          titleStyle: TextStyle(
            fontWeight: FontWeight.w900,
            color: cs.onPrimary,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(Ui.s16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 46, // donut hole
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(width: Ui.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: finalEntries.map((e) {
                final pct = total <= 0 ? 0 : ((e.value / total) * 100).round();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "$pct%",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveDonutCategoryChart extends StatefulWidget {

  final Map<String, double> data;
  final double total;
  final String currencyCode;

  const _InteractiveDonutCategoryChart({
    super.key, 
    required this.data,
    required this.total,
    required this.currencyCode,
  });

  @override
  State<_InteractiveDonutCategoryChart> createState() =>
      _InteractiveDonutCategoryChartState();
}

class _InteractiveDonutCategoryChartState
    extends State<_InteractiveDonutCategoryChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final entries = widget.data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // keep it readable: top 5 + Other
    final top = entries.take(5).toList();
    final otherSum = entries.skip(5).fold<double>(0, (p, e) => p + e.value);

    final finalEntries = <MapEntry<String, double>>[
      ...top,
      if (otherSum > 0) MapEntry("Other", otherSum),
    ];

    final total = widget.total <= 0 ? 1.0 : widget.total;

    final selected =
        (_touchedIndex != null && _touchedIndex! >= 0 && _touchedIndex! < finalEntries.length)
            ? finalEntries[_touchedIndex!]
            : (finalEntries.isNotEmpty ? finalEntries.first : null);

    final selectedPct = selected == null ? 0 : ((selected.value / total) * 100);

    final sections = List.generate(finalEntries.length, (i) {
      final e = finalEntries[i];
      final isTouched = _touchedIndex == i;
      final pct = (e.value / total) * 100;

      final bg = _categoryColor(context, e.key);
      final onBg = _onCategoryColor(context, bg);

      return PieChartSectionData(
        color: bg,
        value: e.value,
        radius: isTouched ? 56 : 48,
        title: pct < 6 ? "" : "${pct.round()}%",
        titleStyle: TextStyle(
          fontWeight: FontWeight.w900,
          color: onBg,
          fontSize: isTouched ? 13 : 12,
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.all(Ui.s16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 50,
                    sectionsSpace: 3,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (!event.isInterestedForInteractions) return;

                        final idx = response?.touchedSection?.touchedSectionIndex;
                        setState(() {
                          _touchedIndex = idx;
                        });
                      },
                    ),
                  ),
                  // Smooth animation:
                  swapAnimationDuration: const Duration(milliseconds: 350),
                  swapAnimationCurve: Curves.easeOutCubic,
                ),
              ),
              const SizedBox(width: Ui.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: finalEntries.map((e) {
                    final pct = ((e.value / total) * 100).round();
                    final dot = _categoryColor(context, e.key);

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
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "$pct%",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: Ui.s12),

          // Selected slice info (animated)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: selected == null
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey(selected.key),
                    padding: const EdgeInsets.symmetric(horizontal: Ui.s12, vertical: Ui.s10),
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _categoryColor(context, selected.key),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selected.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _money(selected.value, currencyCode: widget.currencyCode),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "(${selectedPct.toStringAsFixed(1)}%)",
                          style: TextStyle(
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


/* ------------------------------ UI ------------------------------ */

class _RangePicker extends StatelessWidget {
  final _AnalyticsRange value;
  final ValueChanged<_AnalyticsRange> onChanged;

  const _RangePicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget chip(String text, _AnalyticsRange v) {
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
        chip("Today", _AnalyticsRange.today),
        const SizedBox(width: Ui.s10),
        chip("Week", _AnalyticsRange.week),
        const SizedBox(width: Ui.s10),
        chip("Month", _AnalyticsRange.month),
        const SizedBox(width: Ui.s10),
        chip("All", _AnalyticsRange.all),
      ],
    );
  }
}

class _HeroTotalCard extends StatelessWidget {
  final String label;
  final String total;

  const _HeroTotalCard({required this.label, required this.total});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Ui.s16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.92),
            cs.secondaryContainer.withValues(alpha: 0.62),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
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
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final String currencyCode;
  final double today;
  final double yesterday;
  final double month;
  final double allTime;

  const _QuickStatsRow({
    required this.currencyCode,
    required this.today,
    required this.yesterday,
    required this.month,
    required this.allTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MiniStat(label: "Today", value: _money(today, currencyCode: currencyCode))),
        const SizedBox(width: Ui.s10),
        Expanded(child: _MiniStat(label: "Yesterday", value: _money(yesterday, currencyCode: currencyCode))),
        const SizedBox(width: Ui.s10),
        Expanded(child: _MiniStat(label: "Month", value: _money(month, currencyCode: currencyCode))),
        const SizedBox(width: Ui.s10),
        Expanded(child: _MiniStat(label: "All", value: _money(allTime, currencyCode: currencyCode))),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: t.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String title;
  final String amount;
  final double progress;

  const _BreakdownRow({required this.title, required this.amount, required this.progress});

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

class _CategoryRow extends StatelessWidget {
  final String title;
  final String amount;
  final String percentText;
  final IconData icon;
  final double progress;

  const _CategoryRow({
    required this.title,
    required this.amount,
    required this.percentText,
    required this.icon,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: Ui.s12),
      padding: const EdgeInsets.all(Ui.s14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(Ui.r18),
            ),
            child: Icon(icon, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: Ui.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(
                percentText,
                style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HintCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Ui.s16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(Ui.r18),
            ),
            child: Icon(icon, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: Ui.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrettyEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PrettyEmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Ui.s24),
        child: Container(
          padding: const EdgeInsets.all(Ui.s18),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(Ui.r28),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(Ui.r22),
                ),
                child: Icon(icon, size: 30, color: cs.onPrimaryContainer),
              ),
              const SizedBox(height: Ui.s16),
              Text(
                title,
                style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ helpers ------------------------------ */

String _rangeLabel(_AnalyticsRange r) {
  switch (r) {
    case _AnalyticsRange.today:
      return "Total spent (today)";
    case _AnalyticsRange.week:
      return "Total spent (last 7 days)";
    case _AnalyticsRange.month:
      return "Total spent (this month)";
    case _AnalyticsRange.all:
      return "Total spent (all time)";
  }
}

String _dailyTitle(_AnalyticsRange r) {
  switch (r) {
    case _AnalyticsRange.today:
      return "Today (by category)";
    case _AnalyticsRange.week:
      return "Last 7 days";
    case _AnalyticsRange.month:
      return "This month (recent days)";
    case _AnalyticsRange.all:
      return "Daily totals";
  }
}

List<Expense> _applyRange(List<Expense> expenses, _AnalyticsRange r, DateTime now) {
  switch (r) {
    case _AnalyticsRange.today:
      return _filterDay(expenses, now);
    case _AnalyticsRange.week:
      return _filterLastDays(expenses, now, 7);
    case _AnalyticsRange.month:
      return _filterMonth(expenses, now);
    case _AnalyticsRange.all:
      return expenses;
  }
}

double _sum(List<Expense> expenses) {
  double total = 0;
  for (final e in expenses) total += e.amount;
  return total;
}

List<Expense> _filterDay(List<Expense> expenses, DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  return expenses.where((e) {
    final ed = DateTime(e.date.year, e.date.month, e.date.day);
    return ed == d;
  }).toList();
}

List<Expense> _filterLastDays(List<Expense> expenses, DateTime now, int days) {
  final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
  return expenses.where((e) {
    final d = DateTime(e.date.year, e.date.month, e.date.day);
    return !d.isBefore(start);
  }).toList();
}

List<Expense> _filterMonth(List<Expense> expenses, DateTime now) {
  return expenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();
}

class _DayTotal {
  final String label;
  final double amount;
  _DayTotal(this.label, this.amount);
}

List<_DayTotal> _dailyTotals(List<Expense> filtered, _AnalyticsRange r, DateTime now) {
  if (filtered.isEmpty) return [];
  if (r == _AnalyticsRange.today) return [];

  if (r == _AnalyticsRange.week) {
    final list = <_DayTotal>[];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final amount = _sum(_filterDay(filtered, day));
      list.add(_DayTotal(_dayLabel(day), amount));
    }
    return list;
  }

  if (r == _AnalyticsRange.month) {
    final list = <_DayTotal>[];
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 10; i++) {
      final day = end.subtract(Duration(days: i));
      if (day.isBefore(start)) break;
      final amount = _sum(_filterDay(filtered, day));
      list.add(_DayTotal(_dayLabel(day), amount));
    }
    return list.reversed.toList();
  }

  final list = <_DayTotal>[];
  for (int i = 6; i >= 0; i--) {
    final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final amount = _sum(_filterDay(filtered, day));
    list.add(_DayTotal(_dayLabel(day), amount));
  }
  return list;
}

String _dayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(d.year, d.month, d.day);
  final diff = today.difference(date).inDays;

  if (diff == 0) return "Today";
  if (diff == 1) return "Yesterday";
  return "${d.day}/${d.month}";
}

Map<String, double> _groupByCategory(List<Expense> expenses) {
  final map = <String, double>{};
  for (final e in expenses) {
    final key = _categoryLabel(e);
    map[key] = (map[key] ?? 0) + e.amount;
  }
  final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return {for (final e in entries) e.key: e.value};
}

String _money(double amount, {required String currencyCode}) {
  final rounded = amount.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < rounded.length; i++) {
    final idxFromEnd = rounded.length - i;
    buf.write(rounded[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
  }
  return "$currencyCode ${buf.toString()}";
}

String _categoryLabel(Expense e) {
  try {
    return (e.category as dynamic).name.toString();
  } catch (_) {
    return "Category";
  }
}

IconData _iconFromCategoryName(String name) {
  final n = name.toLowerCase();
  if (n.contains("food")) return Icons.restaurant_rounded;
  if (n.contains("travel")) return Icons.local_gas_station_rounded;
  if (n.contains("work")) return Icons.work_rounded;
  if (n.contains("leisure")) return Icons.sports_esports_rounded;
  return Icons.receipt_long_rounded;
}

Color _categoryColor(BuildContext context, String categoryLabel) {
  final cs = Theme.of(context).colorScheme;
  final name = categoryLabel.toLowerCase();

  if (name.contains('food')) return cs.tertiary;
  if (name.contains('travel')) return cs.primary;
  if (name.contains('work')) return cs.secondary;
  if (name.contains('leisure')) return cs.error;

  return cs.outline; // fallback / Other
}

Color _onCategoryColor(BuildContext context, Color bg) {
  final cs = Theme.of(context).colorScheme;
  // Simple readable contrast choice using luminance:
  return bg.computeLuminance() > 0.5 ? cs.onSurface : Colors.white;
}
