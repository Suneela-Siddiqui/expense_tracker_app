import 'package:flutter/material.dart';
import 'package:flutter_course_project/models/expense.dart';

class DashboardHelpers {
  double sum(List<Expense> expenses) {
  double total = 0;
  for (final e in expenses) total += e.amount;
  return total;
}

List<Expense> filterDay(List<Expense> expenses, DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  return expenses.where((e) {
    final ed = DateTime(e.date.year, e.date.month, e.date.day);
    return ed == d;
  }).toList();
}

String money(double amount, {required String currencyCode}) {
  final rounded = amount.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < rounded.length; i++) {
    final idxFromEnd = rounded.length - i;
    buf.write(rounded[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
  }
  return "$currencyCode ${buf.toString()}";
}


String niceDate(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(d.year, d.month, d.day);
  final diff = today.difference(date).inDays;

  if (diff == 0) return "Today";
  if (diff == 1) return "Yesterday";
  return "${d.day}/${d.month}/${d.year}";
}

String monthName(DateTime d) {
  const months = [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];
  return months[d.month - 1];
}

String categoryName(Expense e) {
  try {
    return (e.category as dynamic).name.toString();
  } catch (_) {
    return "Category";
  }
}

IconData categoryIcon(Expense e) {
  final name = categoryName(e).toLowerCase();
  if (name.contains("food")) return Icons.restaurant_rounded;
  if (name.contains("travel")) return Icons.local_gas_station_rounded;
  if (name.contains("work")) return Icons.work_rounded;
  if (name.contains("leisure")) return Icons.sports_esports_rounded;
  return Icons.receipt_long_rounded;
}

List<String> topCategoryTags(List<Expense> expenses, {int take = 3}) {
  if (expenses.isEmpty) return [];
  final total = sum(expenses);
  if (total <= 0) return [];

  final map = <String, double>{};
  for (final e in expenses) {
    final key = categoryName(e);
    map[key] = (map[key] ?? 0) + e.amount;
  }

  final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return entries.take(take).map((e) {
    final pct = ((e.value / total) * 100).round();
    return "${e.key} $pct%";
  }).toList();
}

}