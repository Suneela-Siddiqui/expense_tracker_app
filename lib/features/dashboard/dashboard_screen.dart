import 'package:flutter/material.dart';
import 'package:flutter_course_project/features/expenses/expenses_screen.dart';
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

    final expenses = appState.expenses;

    final totalSpent = _sum(expenses);
    final double remaining =
        (_monthlyBudget - totalSpent).clamp(0.0, double.infinity).toDouble();

    final recent = expenses.take(3).toList();
    final tags = _topCategoryTags(expenses, take: 3);

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
          _IconPillButton(
            icon: Icons.search_rounded,
            onTap: () {
              showSearch(
                context: context,
                delegate: ExpenseSearchDelegate(),
              );
            },
          ),
          const SizedBox(width: Ui.s8),
          _BellWithBadge(
            unread: appState.unreadCount,
            onTap: () => Navigator.pushNamed(
              context,
              NotificationsScreen.routeName,
            ),
          ),
          const SizedBox(width: Ui.s16),
        ],
      ),
      floatingActionButton: _PrimaryFab(
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
                    "Added: ${e.title} • ${_money(e.amount, currencyCode: appState.currencyCode)}",
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
            child: _MonthHeader(
              monthText: _monthName(DateTime.now()),
              onTapFilter: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Filters coming next ✅")),
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
                  child: _SummaryCard(
                    title: "Remaining",
                    value: _money(remaining, currencyCode: appState.currencyCode),
                    icon: Icons.savings_rounded,
                    tint: cs.tertiaryContainer,
                  ),
                ),
                const SizedBox(width: Ui.s12),
                Expanded(
                  child: _SummaryCard(
                    title: "This month",
                    value: _money(totalSpent, currencyCode: appState.currencyCode),
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
            child: _SectionHeader(
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
            child: _BreakdownCard(
              total: _money(totalSpent, currencyCode: appState.currencyCode),
              topTags: tags.isEmpty ? const ["No data yet"] : tags,
            ),
          ),
          const SizedBox(height: Ui.s20),
          Padding(
            padding: Ui.page,
            child: _SectionHeader(
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
              child: _EmptyCard(
                title: "No expenses yet",
                subtitle: "Tap “Add expense” to start tracking.",
                icon: Icons.receipt_long_rounded,
              ),
            )
          else
            Column(
              children: recent.map((e) {
                return _TransactionTile(
                  title: e.title,
                  subtitle: "${_categoryName(e)} • ${_niceDate(e.date)}",
                  amount: "- ${_money(e.amount, currencyCode: appState.currencyCode)}",
                  icon: _categoryIcon(e),
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

/* ------------------------------ Search ------------------------------ */

class ExpenseSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            onPressed: () => query = '',
            icon: const Icon(Icons.clear),
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) => _SearchResults(query: query);

  @override
  Widget buildSuggestions(BuildContext context) => _SearchResults(query: query);
}

class _SearchResults extends ConsumerWidget {
  final String query;
  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final expenses = appState.expenses;

    final q = query.trim().toLowerCase();

    final filtered = q.isEmpty
        ? expenses
        : expenses.where((e) => e.title.toLowerCase().contains(q)).toList();

    if (filtered.isEmpty) return const Center(child: Text("No results"));

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final e = filtered[i];
        return ListTile(
          title: Text(e.title),
          subtitle: Text("${_categoryName(e)} • ${_niceDate(e.date)}"),
          trailing: Text(_money(e.amount, currencyCode: appState.currencyCode)),
        );
      },
    );
  }
}

/* ------------------------------ UI components ------------------------------ */

class _BellWithBadge extends StatelessWidget {
  final int unread;
  final VoidCallback onTap;
  const _BellWithBadge({required this.unread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _IconPillButton(icon: Icons.notifications_none_rounded, onTap: onTap),
        if (unread > 0)
          Positioned(
            right: 2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                unread > 99 ? "99+" : "$unread",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _IconPillButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconPillButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _PrimaryFab extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryFab({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      onPressed: onTap,
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final String monthText;
  final VoidCallback onTapFilter;
  const _MonthHeader({required this.monthText, required this.onTapFilter});

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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onActionTap;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(subtitle, style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
        TextButton(
          onPressed: onActionTap,
          child: Text(action, style: const TextStyle(fontWeight: FontWeight.w900)),
        )
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color tint;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(Ui.r14),
            ),
            child: Icon(icon, size: 22),
          ),
          const SizedBox(width: Ui.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final String total;
  final List<String> topTags;

  const _BreakdownCard({required this.total, required this.topTags});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Ui.r28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.92),
            cs.secondaryContainer.withValues(alpha: 0.62),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total spent",
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
            const Spacer(),
            Wrap(
              spacing: Ui.s8,
              runSpacing: Ui.s8,
              children: topTags.map((e) => _MiniTag(text: e)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String text;
  const _MiniTag({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45), width: 1),
      ),
      child: Text(text, style: t.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900)),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final VoidCallback onTap;

  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Ui.s16, vertical: Ui.s8),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(Ui.r22),
        child: InkWell(
          borderRadius: BorderRadius.circular(Ui.r22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(Ui.r18),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45), width: 1),
                  ),
                  child: Icon(icon, size: 22),
                ),
                const SizedBox(width: Ui.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Text(amount, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(Ui.r18),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ helpers ------------------------------ */

double _sum(List<Expense> expenses) {
  double total = 0;
  for (final e in expenses) total += e.amount;
  return total;
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


String _niceDate(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(d.year, d.month, d.day);
  final diff = today.difference(date).inDays;

  if (diff == 0) return "Today";
  if (diff == 1) return "Yesterday";
  return "${d.day}/${d.month}/${d.year}";
}

String _monthName(DateTime d) {
  const months = [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];
  return months[d.month - 1];
}

String _categoryName(Expense e) {
  try {
    return (e.category as dynamic).name.toString();
  } catch (_) {
    return "Category";
  }
}

IconData _categoryIcon(Expense e) {
  final name = _categoryName(e).toLowerCase();
  if (name.contains("food")) return Icons.restaurant_rounded;
  if (name.contains("travel")) return Icons.local_gas_station_rounded;
  if (name.contains("work")) return Icons.work_rounded;
  if (name.contains("leisure")) return Icons.sports_esports_rounded;
  return Icons.receipt_long_rounded;
}

List<String> _topCategoryTags(List<Expense> expenses, {int take = 3}) {
  if (expenses.isEmpty) return [];
  final total = _sum(expenses);
  if (total <= 0) return [];

  final map = <String, double>{};
  for (final e in expenses) {
    final key = _categoryName(e);
    map[key] = (map[key] ?? 0) + e.amount;
  }

  final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return entries.take(take).map((e) {
    final pct = ((e.value / total) * 100).round();
    return "${e.key} $pct%";
  }).toList();
}
