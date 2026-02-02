import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_course_project/models/expense.dart';
import 'dart:async';
import 'package:flutter_course_project/core/storage/expense_prefs_repository.dart';
import 'package:flutter_course_project/models/app_notification.dart';

class AppStateData {
  final List<Expense> expenses;
  final List<AppNotification> notifications; 
  final String currencyCode;

  const AppStateData({
    this.expenses = const [],
    this.notifications = const [],
    this.currencyCode = 'PKR',
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length; 

  AppStateData copyWith({
    List<Expense>? expenses,
    List<AppNotification>? notifications,
    String? currencyCode,
  }) {
    return AppStateData(
      expenses: expenses ?? this.expenses,
      notifications: notifications ?? this.notifications,
      currencyCode: currencyCode ?? this.currencyCode,
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
  final code = await repo.loadCurrencyCode();

  state = state.copyWith(
    expenses: items,
    currencyCode: code ?? state.currencyCode,
  );
}

void setCurrency(String code) {
  if (code == state.currencyCode) return;

  state = state.copyWith(currencyCode: code);

  final repo = ref.read(expensePrefsRepositoryProvider);
  unawaited(repo.saveCurrencyCode(code));
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

 void addNotification(String title) {
  final n = AppNotification(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    title: title,
    createdAt: DateTime.now(),
    isRead: false,
  );

  state = state.copyWith(notifications: [n, ...state.notifications]);
}

void markNotificationRead(String id) {
  final updated = state.notifications
      .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
      .toList();

  state = state.copyWith(notifications: updated);
}

  void markAllRead() {
  final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
  state = state.copyWith(notifications: updated);
}

void clearAllNotifications() {
  state = state.copyWith(notifications: const []);
}

  void _persist() {
    final repo = ref.read(expensePrefsRepositoryProvider);
    unawaited(repo.saveExpenses(state.expenses));
  }
}


final appStateProvider =
    NotifierProvider<AppStateNotifier, AppStateData>(AppStateNotifier.new);
