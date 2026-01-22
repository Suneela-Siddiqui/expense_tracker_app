import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/state/app_scope.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/models/expense.dart';

class AnalyticsScreen extends StatelessWidget {
  static const routeName = '/analytics';

  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final expenses = app.expenses;

    final totalSpent = _sum(expenses);

    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: Padding(
        padding: Ui.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Ui.s16),
            Text(
              "This month",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: Ui.s12),
            Text(
              "Total spent",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(
              _money(totalSpent),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: Ui.s24),
            const Text("Next: category breakdown + monthly trend chart ✅"),
          ],
        ),
      ),
    );
  }
}

/* helpers */
double _sum(List<Expense> expenses) {
  double total = 0;
  for (final e in expenses) {
    total += e.amount;
  }
  return total;
}

String _money(double amount) {
  final rounded = amount.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < rounded.length; i++) {
    final idxFromEnd = rounded.length - i;
    buf.write(rounded[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
  }
  return "PKR ${buf.toString()}";
}
