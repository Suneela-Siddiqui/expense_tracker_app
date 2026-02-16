import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/features/dashboard/widgets/helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseSearchDelegate extends SearchDelegate {
  late final Helpers;
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
          subtitle: Text("${Helpers().categoryName(e)} • ${Helpers().niceDate(e.date)}"),
          trailing: Text(Helpers().money(e.amount, currencyCode: appState.currencyCode)),
        );
      },
    );
  }
}