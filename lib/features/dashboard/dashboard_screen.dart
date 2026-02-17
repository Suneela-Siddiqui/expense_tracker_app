import 'package:flutter/material.dart';
import 'package:flutter_course_project/features/dashboard/widgets/bell_with_badge.dart';
import 'package:flutter_course_project/features/dashboard/widgets/breakdown_card.dart';
import 'package:flutter_course_project/features/dashboard/widgets/dashboard_filter.dart';
import 'package:flutter_course_project/features/dashboard/widgets/dashboard_filter_sheet.dart';
import 'package:flutter_course_project/features/dashboard/widgets/dashboard_stats_section.dart';
import 'package:flutter_course_project/features/dashboard/widgets/empty_card.dart';
import 'package:flutter_course_project/features/dashboard/widgets/dashboard_helpers.dart';
import 'package:flutter_course_project/features/dashboard/widgets/icon_pill_button.dart';
import 'package:flutter_course_project/features/dashboard/widgets/month_header.dart';
import 'package:flutter_course_project/features/dashboard/widgets/primary_fab.dart';
import 'package:flutter_course_project/features/dashboard/widgets/section_header.dart';
import 'package:flutter_course_project/features/dashboard/widgets/summary_card.dart';
import 'package:flutter_course_project/features/dashboard/widgets/transaction_tile.dart';
import 'package:flutter_course_project/features/expenses/expenses_screen.dart';
import 'package:flutter_course_project/features/insights/insights_screen.dart';
import 'package:flutter_course_project/features/search/expense_search_delegate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/features/analytics/analytics_screen.dart';
import 'package:flutter_course_project/features/expenses/widgets/new_expense_bottom_screen.dart';
import 'package:flutter_course_project/features/notifications/notifications_screen.dart';
import 'package:flutter_course_project/models/expense.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const double _monthlyBudget = 70000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    final allExpenses = appState.expenses;

    final helpers = DashboardHelpers();

    // newest first for dashboard preview list
    final sorted = [...allExpenses]..sort((a, b) => b.date.compareTo(a.date));
    final recent = sorted.take(3).toList();

    // ✅ breakdown + totals should match "This month overview"
    final now = DateTime.now();
    final monthExpenses = allExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();

    final totalSpentThisMonth = helpers.sum(monthExpenses);
    final double remaining =
        (_monthlyBudget - totalSpentThisMonth).clamp(0.0, double.infinity).toDouble();

    // optional quick context chips
    final todaySpent =helpers.sum(helpers.filterDay(allExpenses, DateTime.now()));
    final yesterdaySpent =
      helpers.sum(helpers.filterDay(allExpenses, DateTime.now().subtract(const Duration(days: 1))));

    final tags =helpers.topCategoryTags(monthExpenses, take: 3);

    final filter = appState.dashboardFilter;
    final filtered = applyDashboardFilter(allExpenses, filter);


    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: Ui.s16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SpendWise",
              style: t.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Your money, simplified",
              style: t.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconPillButton(
            icon: Icons.search_rounded,
            onTap: () {
              showSearch(
                context: context,
                delegate: ExpenseSearchDelegate(container: ref.container),
              );
            },
          ),

          const SizedBox(width: Ui.s8),

          // ✅ NEW: Insights button
          IconPillButton(
            icon: Icons.auto_awesome_rounded,
            onTap: () => Navigator.pushNamed(context, InsightsScreen.routeName),
          ),

          const SizedBox(width: Ui.s8),

          BellWithBadge(
            unread: appState.unreadCount,
            onTap: () => Navigator.pushNamed(
              context,
              NotificationsScreen.routeName,
            ),
          ),

          const SizedBox(width: Ui.s16),
        ],

      ),
      floatingActionButton: PrimaryFab(
        label: "Add expense",
        icon: Icons.add_rounded,
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) {
              return NewExpenseBottomSheet(
                onAddExpense: (Expense e) {
                  notifier.addExpense(e);
                  notifier.addNotification(
                    "Added: ${e.title} • ${DashboardHelpers().money(e.amount, currencyCode: appState.currencyCode)}",
                  );

                },
              );
            },
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          const SizedBox(height: Ui.s8),
          Padding(
            padding: Ui.page,
            child: MonthHeader(
            monthText: helpers.monthName(DateTime.now()),
            hasActiveFilters: filter.hasActiveFilters, // ✅ NEW
            onTapFilter: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) {
                  return DashboardFilterSheet(
                    initial: filter,
                    onApply: (f) => notifier.setDashboardFilter(f),
                    onClear: () => notifier.clearDashboardFilter(),
                  );
                },
              );
            },
          ),

          ),
          const SizedBox(height: Ui.s12),
          Padding(
            padding: Ui.page,
            child: Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: "Remaining",
                    value: helpers.money(remaining, currencyCode: appState.currencyCode),
                    icon: Icons.savings_rounded,
                    tint: cs.tertiaryContainer,
                  ),
                ),
                const SizedBox(width: Ui.s12),
                Expanded(
                  child: SummaryCard(
                    title: "This month",
                    value: helpers.money(totalSpentThisMonth, currencyCode: appState.currencyCode),
                    icon: Icons.payments_rounded,
                    tint: cs.primaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Ui.s16),
          Padding(
            padding: Ui.page,
            child: SectionHeader(
              title: "Spending breakdown",
              subtitle: "This month overview",
              action: "Details",
              onActionTap: () => Navigator.pushNamed(
                context,
                AnalyticsScreen.routeName,
              ),
            ),
          ),
          const SizedBox(height: Ui.s12),
          Padding(
            padding: Ui.page,
            child: BreakdownCard(
            total: helpers.money(totalSpentThisMonth, currencyCode: appState.currencyCode),
            today: helpers.money(todaySpent, currencyCode: appState.currencyCode),
            yesterday: helpers.money(yesterdaySpent, currencyCode: appState.currencyCode),
            topTags: tags.isEmpty ? const ["No data this month"] : tags,
          ),
          ),
          const SizedBox(height: Ui.s20),

          const DashboardStatsSection(),

          const SizedBox(height: Ui.s20),

          Padding(
            padding: Ui.page,
            child: SectionHeader(
              title: "Recent transactions",
              subtitle: "Latest activity",
              action: "See all",
              onActionTap: () => Navigator.pushNamed(context, ExpensesScreen.routeName),

            ),
          ),
          const SizedBox(height: Ui.s8),
          if (recent.isEmpty)
            Padding(
              padding: Ui.page,
              child: EmptyCard(
                title: "No expenses yet",
                subtitle: "Tap “Add expense” to start tracking.",
                icon: Icons.receipt_long_rounded,
              ),
            )
          else
            Column(
              children: recent.map((e) {
                return TransactionTile(
                  title: e.title,
                  subtitle: "${helpers.categoryName(e)} • ${helpers.niceDate(e.date)}",
                  amount: "- ${helpers.money(e.amount, currencyCode: appState.currencyCode)}",
                  icon: helpers.categoryIcon(e),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Tapped: ${e.title}")),
                    );
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: Ui.s24),
        ],
      ),
    );
  }
}

