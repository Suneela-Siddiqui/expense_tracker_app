import 'package:flutter/material.dart';
import 'package:flutter_course_project/features/analytics/widgets/interactive_donut_category_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/features/analytics/widgets/analytics_helpers.dart';
import 'package:flutter_course_project/features/analytics/widgets/quick_stats_row.dart';

import 'package:flutter_course_project/features/dashboard/widgets/section_header.dart';
import 'package:flutter_course_project/features/analytics/analytics_screen.dart';

class DashboardStatsSection extends ConsumerWidget {
  const DashboardStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final appState = ref.watch(appStateProvider);

    final expenses = appState.expenses;
    if (expenses.isEmpty) return const SizedBox.shrink();

    final helper = AnalyticsHelper();
    final now = DateTime.now();

    // Stats (same logic as analytics)
    final todayTotal = helper.sum(helper.filterDay(expenses, now));
    final yesterdayTotal =
        helper.sum(helper.filterDay(expenses, now.subtract(const Duration(days: 1))));
    final monthExpenses = helper.filterMonth(expenses, now);
    final monthTotal = helper.sum(monthExpenses);
    final allTimeTotal = helper.sum(expenses);

    final byCategory = helper.groupByCategory(monthExpenses);

    return Padding(
      padding: Ui.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: "Stats",
            subtitle: "This month at a glance",
            action: "Details",
            onActionTap: () => Navigator.pushNamed(context, AnalyticsScreen.routeName),
          ),
          const SizedBox(height: Ui.s12),

          QuickStatsRow(
            currencyCode: appState.currencyCode,
            today: todayTotal,
            yesterday: yesterdayTotal,
            month: monthTotal,
            allTime: allTimeTotal,
          ),

          const SizedBox(height: Ui.s12),

          if (byCategory.isNotEmpty)
            InteractiveDonutCategoryChart(
              data: byCategory,
              total: monthTotal,
              currencyCode: appState.currencyCode,
            )
          else
            Text(
              "No spend recorded this month yet.",
              style: t.textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}
