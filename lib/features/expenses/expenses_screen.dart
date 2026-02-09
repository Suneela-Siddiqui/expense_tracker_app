import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/models/expense.dart';

class ExpensesScreen extends ConsumerWidget {
  static const routeName = '/expenses';
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    // newest first
    final expenses = [...appState.expenses]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Expenses"),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: "Search",
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _AllExpensesSearch(expenses, appState.currencyCode),
              );
            },
          ),
          const SizedBox(width: Ui.s8),
        ],
      ),
      body: expenses.isEmpty
          ? const _PrettyEmptyState(
              title: "No expenses yet",
              subtitle: "Add your first expense from the dashboard.",
              icon: Icons.receipt_long_rounded,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(Ui.s16, Ui.s12, Ui.s16, Ui.s24),
              itemCount: expenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: Ui.s12),
              itemBuilder: (_, i) {
                final e = expenses[i];

                return Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  background: const _DeleteSwipeBg(),
                  onDismissed: (_) {
                    notifier.removeExpense(e);

                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Deleted: ${e.title}"),
                        action: SnackBarAction(
                          label: "UNDO",
                          onPressed: () => notifier.addExpense(e),
                        ),
                      ),
                    );
                  },
                  child: _ExpenseCard(
                    title: e.title,
                    subtitle: "${_categoryLabel(e)} • ${_niceDate(e.date)}",
                    amount: _money(e.amount, currencyCode: appState.currencyCode),
                    icon: _categoryIcon(e),
                    iconBg: cs.primaryContainer.withValues(alpha: 0.55),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Tapped: ${e.title}")),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

/* ------------------------------ UI ------------------------------ */

class _ExpenseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color iconBg;
  final VoidCallback onTap;

  const _ExpenseCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(Ui.r22),
      child: InkWell(
        borderRadius: BorderRadius.circular(Ui.r22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Ui.s14),
          child: Row(
            children: [
              // ✅ Icon (back to premium layout)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(Ui.r18),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.45),
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: 22, color: cs.onPrimaryContainer),
              ),

              const SizedBox(width: Ui.s12),

              // ✅ Title + Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: Ui.s10),

              // ✅ Amount only (no duplicate hint chips)
              Text(
                amount,
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final VoidCallback onTap;

  const _SearchResultTile({
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

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(Ui.r16),
      child: InkWell(
        borderRadius: BorderRadius.circular(Ui.r16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Ui.s14, vertical: Ui.s12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(Ui.r14),
                ),
                child: Icon(icon, size: 20, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: Ui.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Ui.s10),
              Text(
                amount,
                style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteSwipeBg extends StatelessWidget {
  const _DeleteSwipeBg();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(Ui.r22),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: Ui.s18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.delete_rounded, color: cs.onError, size: 22),
          const SizedBox(width: 8),
          Text(
            "Delete",
            style: TextStyle(color: cs.onError, fontWeight: FontWeight.w900),
          )
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
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45), width: 1),
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
              Text(title, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
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

/* ------------------------------ Search ------------------------------ */

class _AllExpensesSearch extends SearchDelegate {
  final List<Expense> all;
  final String currencyCode;

  _AllExpensesSearch(this.all, this.currencyCode);

  @override
  String get searchFieldLabel => "Search expenses";

  @override
  TextStyle? get searchFieldStyle => const TextStyle(fontWeight: FontWeight.w800);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
      ];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(onPressed: () => close(context, null), icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) => _searchBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _searchBody(context);

  Widget _searchBody(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((e) => e.title.toLowerCase().contains(q)).toList();

    // ✅ Correct empty state
    if (filtered.isEmpty) {
      return const Center(child: Text("No results"));
    }

    // ✅ Search uses compact tile (DIFFERENT from All Expenses)
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Ui.s16, Ui.s12, Ui.s16, Ui.s24),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: Ui.s10),
      itemBuilder: (_, i) {
        final e = filtered[i];

        return _SearchResultTile(
          title: e.title,
          subtitle: "${_categoryLabel(e)} • ${_niceDate(e.date)}",
          amount: _money(e.amount, currencyCode: currencyCode),
          icon: _categoryIcon(e),
          onTap: () => close(context, null),
        );
      },
    );
  }
}

/* ------------------------------ helpers ------------------------------ */

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

String _categoryLabel(Expense e) {
  try {
    return (e.category as dynamic).name.toString();
  } catch (_) {
    return "category";
  }
}

IconData _categoryIcon(Expense e) {
  final name = _categoryLabel(e).toLowerCase();
  if (name.contains("food")) return Icons.restaurant_rounded;
  if (name.contains("travel")) return Icons.local_gas_station_rounded;
  if (name.contains("work")) return Icons.work_rounded;
  if (name.contains("leisure")) return Icons.sports_esports_rounded;
  return Icons.receipt_long_rounded;
}
