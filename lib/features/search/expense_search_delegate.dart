import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/models/expense.dart';

class ExpenseSearchDelegate extends SearchDelegate {
  final ProviderContainer container;

  ExpenseSearchDelegate({required this.container});

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    final appState = container.read(appStateProvider); // ✅ works anywhere
    final expenses = appState.expenses;

    final results = expenses.where((e) {
      final q = query.toLowerCase().trim();
      return e.title.toLowerCase().contains(q) ||
          e.category.name.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text("No results"));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final e = results[i];
        return ListTile(
          title: Text(e.title),
          subtitle: Text("${e.category.name} • ${e.formattedDate}"),
          trailing: Text(e.amount.toStringAsFixed(0)),
          onTap: () {
            // handle tap if you want
            close(context, e);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // same as buildResults, or show recent searches etc.
    return buildResults(context);
  }
}
