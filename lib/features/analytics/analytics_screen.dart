import 'package:flutter/material.dart';
import 'package:flutter_course_project/features/analytics/widgets/analytics_helpers.dart';
import 'package:flutter_course_project/features/analytics/widgets/breakdown_row.dart';
import 'package:flutter_course_project/features/analytics/widgets/category_row.dart';
import 'package:flutter_course_project/features/analytics/widgets/hero_total_card.dart';
import 'package:flutter_course_project/features/analytics/widgets/hint_card.dart';
import 'package:flutter_course_project/features/analytics/widgets/interactive_donut_category_chart.dart';
import 'package:flutter_course_project/features/analytics/widgets/pretty_empty_state.dart';
import 'package:flutter_course_project/features/analytics/widgets/quick_stats_row.dart';
import 'package:flutter_course_project/features/analytics/widgets/range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  static const routeName = '/analytics';
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsRange range = AnalyticsRange.month;

final helper = AnalyticsHelper();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final appState = ref.watch(appStateProvider);
    final allExpenses = appState.expenses;

     final currencyCode = appState.currencyCode;

    final now = DateTime.now();

      final todayTotal = helper.sum(helper.filterDay(allExpenses, now));
      final yesterdayTotal = helper.sum(helper.filterDay(allExpenses, now.subtract(const Duration(days: 1))));
      final monthTotal = helper.sum(helper.filterMonth(allExpenses, now));
      final allTimeTotal = helper.sum(allExpenses);

      final filtered = helper.applyRange(allExpenses, range, now);

      final total = helper.sum(filtered);
      final byCategory = helper.groupByCategory(filtered);
      final daily = helper.dailyTotals(filtered, range, now); // ✅ FIXED

    return Scaffold(
      appBar: AppBar(
        title: const Text("Spending breakdown"),
      ),
      body: allExpenses.isEmpty
          ? PrettyEmptyState(
              title: "No expenses yet",
              subtitle: "Add your first expense from the dashboard.",
              icon: Icons.pie_chart_rounded,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(Ui.s16, Ui.s12, Ui.s16, Ui.s24),
              children: [
                RangePicker(
                  value: range,
                  onChanged: (v) => setState(() => range = v),
                ),
                const SizedBox(height: Ui.s14),

                HeroTotalCard(
                  label: AnalyticsHelper().rangeLabel(range),
                  total: AnalyticsHelper().money(total, currencyCode: appState.currencyCode),
                ),

                const SizedBox(height: Ui.s12),

                QuickStatsRow(
                  currencyCode: appState.currencyCode,
                  today: todayTotal,
                  yesterday: yesterdayTotal,
                  month: monthTotal,
                  allTime: allTimeTotal,
                ),

                const SizedBox(height: Ui.s18),

                if (daily.isNotEmpty) ...[
                  Text(
                    AnalyticsHelper().dailyTitle(range),
                    style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: Ui.s10),
                  ...daily.map((d) {
                    final pct = (total <= 0) ? 0.0 : (d.amount / total).clamp(0.0, 1.0);
                    return BreakdownRow(
                      title: d.label,
                      amount: AnalyticsHelper().money(d.amount, currencyCode: appState.currencyCode),
                      progress: pct,
                    );
                  }),
                  const SizedBox(height: Ui.s16),
                ],

                if (daily.isNotEmpty) ...[
                  Text(
                    "Daily spend",
                    style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: Ui.s10),
                  _SpendBarChart(daily, currencyCode: currencyCode),
                  const SizedBox(height: Ui.s16),
                ],

                Text(
                  "By category",
                  style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                

                if (byCategory.isNotEmpty) ...[
                  const SizedBox(height: Ui.s16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: InteractiveDonutCategoryChart(
                      key: ValueKey(range),  
                      data: byCategory,
                      total: total,
                      currencyCode: currencyCode,
                    ),
                  ),
                ],


                if (byCategory.isEmpty)
                  HintCard(
                    title: "No spend in this range",
                    subtitle: "Try another time range above.",
                    icon: Icons.info_outline_rounded,
                  )
                else
                  ...byCategory.entries.map((entry) {
                    final cat = entry.key;
                    final amount = entry.value;
                    final pct = total <= 0 ? 0 : ((amount / total) * 100).round();

                    return CategoryRow(
                      title: cat,
                      amount: AnalyticsHelper().money(amount, currencyCode: appState.currencyCode),
                      percentText: "$pct%",
                      icon: AnalyticsHelper().iconFromCategoryName(cat),
                      progress: (total <= 0) ? 0 : (amount / total).clamp(0.0, 1.0),
                    );
                  }),
              ],
            ),
    );
  }
}

class _SpendBarChart extends StatelessWidget {
  final List<DayTotal> daily;
    final String currencyCode;
  
  const _SpendBarChart(this.daily, {required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final maxY = daily.map((e) => e.amount).fold<double>(0, (p, v) => v > p ? v : p);

    return Container(
      padding: const EdgeInsets.all(Ui.s14),
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
             barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final label = daily[group.x].label;
                  final value = rod.toY;

                  return BarTooltipItem(
                    "$label\n${AnalyticsHelper().money(value, currencyCode: currencyCode)}",
                    TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
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
                        daily[i].label,
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
                    borderRadius: BorderRadius.circular(8),
                    color: cs.primary, // ✅ strong visible
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: (maxY <= 0) ? 1 : (maxY * 1.2),
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                    ),
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
