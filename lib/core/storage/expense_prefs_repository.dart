import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_course_project/models/expense.dart';

class ExpensePrefsRepository {
  static const _key = 'expenses_v1';
  static const _currencyKey = 'currency_v1';

  Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<String?> loadCurrencyCode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_currencyKey);
}

Future<void> saveCurrencyCode(String code) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_currencyKey, code);
}

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
