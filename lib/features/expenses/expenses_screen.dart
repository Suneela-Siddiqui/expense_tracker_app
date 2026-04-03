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

/* ------------------------------ Press Animation Wrapper ------------------------------ */

class _PressScaleInk extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _PressScaleInk({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<_PressScaleInk> createState() => _PressScaleInkState();
}

class _PressScaleInkState extends State<_PressScaleInk> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: InkWell(
        borderRadius: widget.borderRadius,
        onTap: () {
          _setPressed(false);
          widget.onTap();
        },
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        child: widget.child,
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

    final radius = BorderRadius.circular(Ui.r22);

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: radius,
      child: _PressScaleInk(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Ui.s14),
          child: Row(
            children: [
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