import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/features/dashboard/widgets/dashboard_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseSearchDelegate extends SearchDelegate {
  ExpenseSearchDelegate();

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    final cs = base.colorScheme;

    return base.copyWith(
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: cs.secondary, // Deep Space
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        hintStyle: base.textTheme.bodyLarge?.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: 0.85),
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.80), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.80), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cs.primary.withValues(alpha: 0.65), width: 1.4), // Raspberry focus
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: cs.primary,
        selectionColor: cs.primary.withValues(alpha: 0.18),
        selectionHandleColor: cs.primary,
      ),
      iconTheme: base.iconTheme.copyWith(color: cs.secondary),
    );
  }

  @override
  String? get searchFieldLabel => "Search expenses";

  @override
  TextStyle? get searchFieldStyle => const TextStyle(fontWeight: FontWeight.w700);

  @override
  List<Widget>? buildActions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          tooltip: "Clear",
          icon: Icon(Icons.close_rounded, color: cs.secondary),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: () => close(context, null),
      tooltip: "Back",
      icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.secondary),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _SearchResults(
      query: query,
      onPick: (expense) => close(context, expense),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SearchResults(
      query: query,
      onPick: (expense) => close(context, expense),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  final void Function(dynamic expense) onPick;

  const _SearchResults({
    required this.query,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final appState = ref.watch(appStateProvider);
    final expenses = appState.expenses;

    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? expenses
        : expenses.where((e) => e.title.toLowerCase().contains(q)).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          "No results",
          style: t.textTheme.bodyLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final e = filtered[i];

        final title = e.title;
        // ✅ as you asked: no category here — only date
        final subtitle = DashboardHelpers().niceDate(e.date);
        final amount =
            DashboardHelpers().money(e.amount, currencyCode: appState.currencyCode);

        return _Pressable(
          onTap: () => onPick(e),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.80),
                width: 1,
              ),
            ),
            child: Row(
              children: [
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
                          color: cs.secondary, // Deep Space structure
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  amount,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                    color: cs.secondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Small “premium” press animation: scale + slight opacity.
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _Pressable({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  void _setDown(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setDown(true),
      onTapUp: (_) => _setDown(false),
      onTapCancel: () => _setDown(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        scale: _down ? 0.98 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 110),
          opacity: _down ? 0.92 : 1.0,
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}