import 'package:flutter/foundation.dart';
import '../../models/expense.dart';

class AppState extends ChangeNotifier {
  final List<Expense> _expenses = [];

  // Simple notifications
  final List<String> _notifications = [];
  int _unread = 0;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<String> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unread;

  void addExpense(Expense e) {
    _expenses.insert(0, e); // newest first
    notifyListeners();
  }

  void removeExpense(Expense e) {
    _expenses.remove(e);
    notifyListeners();
  }

  void addNotification(String text) {
    _notifications.insert(0, text);
    _unread++;
    notifyListeners();
  }

  void markAllRead() {
    _unread = 0;
    notifyListeners();
  }
}
