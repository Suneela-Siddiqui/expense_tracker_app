import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/theme/app_theme.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/features/analytics/analytics_screen.dart';
import 'package:flutter_course_project/features/dashboard/widgets/bell_with_badge.dart';
import 'package:flutter_course_project/features/dashboard/widgets/breakdown_card.dart';
import 'package:flutter_course_project/features/dashboard/widgets/dashboard_filter_sheet.dart';
import 'package:flutter_course_project/features/dashboard/widgets/dashboard_helpers.dart';
import 'package:flutter_course_project/features/dashboard/widgets/dashboard_stats_section.dart';
import 'package:flutter_course_project/features/dashboard/widgets/empty_card.dart';
import 'package:flutter_course_project/features/dashboard/widgets/icon_pill_button.dart';
import 'package:flutter_course_project/features/dashboard/widgets/month_header.dart';
import 'package:flutter_course_project/features/dashboard/widgets/primary_fab.dart';
import 'package:flutter_course_project/features/dashboard/widgets/section_header.dart';
import 'package:flutter_course_project/features/dashboard/widgets/summary_card.dart';
import 'package:flutter_course_project/features/dashboard/widgets/transaction_tile.dart';
import 'package:flutter_course_project/features/expenses/expenses_screen.dart';
import 'package:flutter_course_project/features/expenses/widgets/expense_details_sheet.dart';
import 'package:flutter_course_project/features/expenses/widgets/new_expense_bottom_screen.dart';
import 'package:flutter_course_project/features/insights/insights_screen.dart';
import 'package:flutter_course_project/features/notifications/notifications_screen.dart';
import 'package:flutter_course_project/features/search/expense_search_delegate.dart';
import 'package:flutter_course_project/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const List<String> _supportedCurrencies = <String>[
    'PKR',
    'USD',
    'EUR',
    'AED',
    'GBP',
    'SAR',
  ];

  Future<void> _showBudgetDialog(
    BuildContext context,
    WidgetRef ref, {
    double? currentBudget,
    required String currencyCode,
    String? helperMessage,
  }) async {
    final controller = TextEditingController(
      text: currentBudget != null ? currentBudget.toStringAsFixed(0) : '',
    );

    String selectedCurrency = _supportedCurrencies.contains(currencyCode)
        ? currencyCode
        : _supportedCurrencies.first;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Set monthly budget'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (helperMessage != null) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        helperMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                  DropdownButtonFormField<String>(
                    value: selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: _supportedCurrencies
                        .map(
                          (code) => DropdownMenuItem<String>(
                            value: code,
                            child: Text(code),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setLocalState(() {
                        selectedCurrency = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Budget amount',
                      hintText: 'Enter monthly budget',
                      prefixText: '$selectedCurrency ',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                FilledButton(
                    onPressed: () {
                    final value = double.tryParse(controller.text.trim());

                    if (value == null || value <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid budget amount'),
                        ),
                      );
                      return;
                    }

                    final notifier = ref.read(appStateProvider.notifier);
                    notifier.setCurrency(selectedCurrency);
                    notifier.setMonthlyBudget(value);

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Budget saved successfully in $selectedCurrency',
                        ),
                      ),
                    ); 
                  },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _requireBudgetBeforeContinue(
    BuildContext context,
    WidgetRef ref,
    AppStateData appState,
  ) async {
    final hasBudget = appState.monthlyBudget != null;
    if (hasBudget) return true;

    await _showBudgetDialog(
      context,
      ref,
      currentBudget: null,
      currencyCode: appState.currencyCode,
      helperMessage: 'First set your budget to continue.',
    );

    final updatedState = ref.read(appStateProvider);
    return updatedState.monthlyBudget != null;
  }

  Widget _buildBudgetSetupState(
    BuildContext context,
    WidgetRef ref,
    String currencyCode,
  ) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final controller = TextEditingController();

    String selectedCurrency = _supportedCurrencies.contains(currencyCode)
        ? currencyCode
        : _supportedCurrencies.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        const SizedBox(height: Ui.s8),
        StatefulBuilder(
          builder: (context, setLocalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.35),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: cs.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 78,
                    width: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary.withOpacity(0.10),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 38,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Set your monthly budget',
                    textAlign: TextAlign.center,
                    style: t.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.deepSpace,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Start by entering the amount you want to spend this month. Choose your currency once, and the app will use the same one for expenses.',
                    textAlign: TextAlign.center,
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  decoration: InputDecoration(
                    labelText: 'Currency',
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: cs.primary, width: 1.4),
                    ),
                  ),
                  items: _supportedCurrencies
                      .map(
                        (code) => DropdownMenuItem<String>(
                          value: code,
                          child: Text(code),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setLocalState(() {
                      selectedCurrency = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter monthly budget',
                    prefixText: '$selectedCurrency ',
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: cs.primary, width: 1.4),
                    ),
                  ),
                ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final value = double.tryParse(controller.text.trim());

                        if (value == null || value <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please enter a valid budget amount'),
                            ),
                          );
                          return;
                        }

                        final notifier = ref.read(appStateProvider.notifier);
                        notifier.setCurrency(selectedCurrency);
                        notifier.setMonthlyBudget(value);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Budget saved successfully in $selectedCurrency',
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Save budget'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'You need to set a budget before tracking your spending.',
                    textAlign: TextAlign.center,
                    style: t.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    final allExpenses = appState.expenses;
    final helpers = DashboardHelpers();

    final double? monthlyBudget = appState.monthlyBudget;
    final hasBudget = monthlyBudget != null;

    final sorted = [...allExpenses]..sort((a, b) => b.date.compareTo(a.date));
    final recent = sorted.take(3).toList();

    final now = DateTime.now();
    final monthExpenses = allExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();

    final totalSpentThisMonth = helpers.sum(monthExpenses);
    final double remaining = hasBudget
        ? ((monthlyBudget! - totalSpentThisMonth)
                .clamp(0.0, double.infinity))
            .toDouble()
        : 0.0;

    final todaySpent =
        helpers.sum(helpers.filterDay(allExpenses, DateTime.now()));
    final yesterdaySpent = helpers.sum(
      helpers.filterDay(
        allExpenses,
        DateTime.now().subtract(const Duration(days: 1)),
      ),
    );

    final tags = helpers.topCategoryTags(monthExpenses, take: 3);
    final filter = appState.dashboardFilter;

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
                color: AppTheme.deepSpace,
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
          if (hasBudget) ...[
            IconPillButton(
              icon: Icons.edit_rounded,
              onTap: () {
                _showBudgetDialog(
                  context,
                  ref,
                  currentBudget: monthlyBudget,
                  currencyCode: appState.currencyCode,
                );
              },
            ),
            const SizedBox(width: Ui.s8),
          ],
          IconPillButton(
            icon: Icons.search_rounded,
            onTap: () async {
              final canContinue =
                  await _requireBudgetBeforeContinue(context, ref, appState);
              if (!canContinue || !context.mounted) return;

              final currentState = ref.read(appStateProvider);

              final picked = await showSearch<dynamic>(
                context: context,
                delegate: ExpenseSearchDelegate(),
              );

              if (picked == null) return;
              if (!context.mounted) return;

              showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ExpenseDetailsSheet(
                  expense: picked,
                  currencyCode: currentState.currencyCode,
                ),
              );
            },
          ),
          const SizedBox(width: Ui.s8),
          IconPillButton(
            icon: Icons.auto_awesome_rounded,
            onTap: () async {
              final canContinue =
                  await _requireBudgetBeforeContinue(context, ref, appState);
              if (!canContinue || !context.mounted) return;

              Navigator.pushNamed(context, InsightsScreen.routeName);
            },
          ),
          const SizedBox(width: Ui.s8),
          BellWithBadge(
            unread: appState.unreadCount,
            onTap: () async {
              final canContinue =
                  await _requireBudgetBeforeContinue(context, ref, appState);
              if (!canContinue || !context.mounted) return;

              Navigator.pushNamed(context, NotificationsScreen.routeName);
            },
          ),
          const SizedBox(width: Ui.s16),
        ],
      ),
      floatingActionButton: PrimaryFab(
        label: "Add expense",
        icon: Icons.add_rounded,
        onTap: () async {
          final canContinue =
              await _requireBudgetBeforeContinue(context, ref, appState);
          if (!canContinue || !context.mounted) return;

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
      body: hasBudget
          ? ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                const SizedBox(height: Ui.s8),
                Padding(
                  padding: Ui.page,
                  child: MonthHeader(
                    monthText: helpers.monthName(DateTime.now()),
                    hasActiveFilters: filter.hasActiveFilters,
                    onTapFilter: () async {
                      final canContinue = await _requireBudgetBeforeContinue(
                        context,
                        ref,
                        appState,
                      );
                      if (!canContinue || !context.mounted) return;

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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Ui.s16,
                      vertical: Ui.s14,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          color: cs.primary,
                        ),
                        const SizedBox(width: Ui.s10),
                        Expanded(
                          child: Text(
                            "Budget: ${helpers.money(monthlyBudget, currencyCode: appState.currencyCode)}",
                            style: t.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _showBudgetDialog(
                              context,
                              ref,
                              currentBudget: monthlyBudget,
                              currencyCode: appState.currencyCode,
                            );
                          },
                          child: const Text("Edit"),
                        ),
                      ],
                    ),
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
                          value: helpers.money(
                            remaining,
                            currencyCode: appState.currencyCode,
                          ),
                          icon: Icons.savings_rounded,
                          tint: cs.secondary,
                        ),
                      ),
                      const SizedBox(width: Ui.s12),
                      Expanded(
                        child: SummaryCard(
                          title: "This month",
                          value: helpers.money(
                            totalSpentThisMonth,
                            currencyCode: appState.currencyCode,
                          ),
                          icon: Icons.payments_rounded,
                          tint: cs.primary,
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
                    onActionTap: () async {
                      final canContinue = await _requireBudgetBeforeContinue(
                        context,
                        ref,
                        appState,
                      );
                      if (!canContinue || !context.mounted) return;

                      Navigator.pushNamed(context, AnalyticsScreen.routeName);
                    },
                  ),
                ),
                const SizedBox(height: Ui.s12),
                Padding(
                  padding: Ui.page,
                  child: BreakdownCard(
                    total: helpers.money(
                      totalSpentThisMonth,
                      currencyCode: appState.currencyCode,
                    ),
                    today: helpers.money(
                      todaySpent,
                      currencyCode: appState.currencyCode,
                    ),
                    yesterday: helpers.money(
                      yesterdaySpent,
                      currencyCode: appState.currencyCode,
                    ),
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
                    onActionTap: () async {
                      final canContinue = await _requireBudgetBeforeContinue(
                        context,
                        ref,
                        appState,
                      );
                      if (!canContinue || !context.mounted) return;

                      Navigator.pushNamed(context, ExpensesScreen.routeName);
                    },
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
                        subtitle:
                            "${helpers.categoryName(e)} • ${helpers.niceDate(e.date)}",
                        amount:
                            "- ${helpers.money(e.amount, currencyCode: appState.currencyCode)}",
                        icon: helpers.categoryIcon(e),
                        onTap: () async {
                          final canContinue =
                              await _requireBudgetBeforeContinue(
                            context,
                            ref,
                            appState,
                          );
                          if (!canContinue || !context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Tapped: ${e.title}")),
                          );
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: Ui.s24),
              ],
            )
          : _buildBudgetSetupState(
              context,
              ref,
              appState.currencyCode,
            ),
    );
  }
}