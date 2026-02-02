import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_course_project/models/expense.dart';
import 'dart:async';
import 'package:flutter_course_project/core/storage/expense_prefs_repository.dart';

class AppStateData {
  final List<Expense> expenses;
  final List<String> notifications;

  const AppStateData({
    this.expenses = const [],
    this.notifications = const [],
  });

  int get unreadCount => notifications.length;

  AppStateData copyWith({
    List<Expense>? expenses,
    List<String>? notifications,
  }) {
    return AppStateData(
      expenses: expenses ?? this.expenses,
      notifications: notifications ?? this.notifications,
    );
  }
}

final expensePrefsRepositoryProvider =
    Provider<ExpensePrefsRepository>((ref) {
  return ExpensePrefsRepository();
});

class AppStateNotifier extends Notifier<AppStateData> {
  @override
  AppStateData build() {
    _loadFromDisk();
    return const AppStateData();
  }

  Future<void> _loadFromDisk() async {
    final repo = ref.read(expensePrefsRepositoryProvider);
    final items = await repo.loadExpenses();
    state = state.copyWith(expenses: items);
    print("📦 Loaded ${items.length} expenses from disk");

  }

  void addExpense(Expense e) {
    state = state.copyWith(expenses: [e, ...state.expenses]);
    _persist();
  }

  void removeExpense(Expense e) {
    final updated =
        state.expenses.where((x) => x.id != e.id).toList();
    state = state.copyWith(expenses: updated);
    _persist();
  }

  void addNotification(String text) {
    state = state.copyWith(
      notifications: [text, ...state.notifications],
    );
  }

  void markAllRead() {
    state = state.copyWith(notifications: const []);
  }

  void _persist() {
    final repo = ref.read(expensePrefsRepositoryProvider);
    unawaited(repo.saveExpenses(state.expenses));
  }
}


final appStateProvider =
    NotifierProvider<AppStateNotifier, AppStateData>(AppStateNotifier.new);
