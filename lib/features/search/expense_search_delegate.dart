import 'package:flutter/material.dart';
import '../../core/state/app_scope.dart';
import '../../models/expense.dart';

class ExpenseSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
      ];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(onPressed: () => close(context, null), icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) => _Results(query: query);

  @override
  Widget buildSuggestions(BuildContext context) => _Results(query: query);
}

class _Results extends StatelessWidget {
  final String query;
  const _Results({required this.query});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final q = query.trim().toLowerCase();

    final List<Expense> filtered = q.isEmpty
        ? app.expenses
        : app.expenses.where((e) => e.title.toLowerCase().contains(q)).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No results"));
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final e = filtered[i];
        return ListTile(
          title: Text(e.title),
          subtitle: Text("${e.category.name} • ${e.date.toString().split(' ').first}"),
          trailing: Text("PKR ${e.amount.toStringAsFixed(0)}"),
        );
      },
    );
  }
}
