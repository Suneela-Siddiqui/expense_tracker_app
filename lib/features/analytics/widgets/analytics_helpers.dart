import 'package:flutter/material.dart';
import 'package:flutter_course_project/models/expense.dart';

enum AnalyticsRange { today, week, month, all }

class DayTotal {
  final String label;
  final double amount;
  const DayTotal(this.label, this.amount);
}

class AnalyticsHelper {
  // ---------- labels ----------
  String rangeLabel(AnalyticsRange r) {
    switch (r) {
      case AnalyticsRange.today:
        return "Total spent (today)";
      case AnalyticsRange.week:
        return "Total spent (last 7 days)";
      case AnalyticsRange.month:
        return "Total spent (this month)";
      case AnalyticsRange.all:
        return "Total spent (all time)";
    }
  }

  String dailyTitle(AnalyticsRange r) {
    switch (r) {
      case AnalyticsRange.today:
        return "Today (by category)";
      case AnalyticsRange.week:
        return "Last 7 days";
      case AnalyticsRange.month:
        return "This month (recent days)";
      case AnalyticsRange.all:
        return "Daily totals";
    }
  }

  // ---------- range filtering ----------
  List<Expense> applyRange(List<Expense> expenses, AnalyticsRange r, DateTime now) {
    switch (r) {
      case AnalyticsRange.today:
        return filterDay(expenses, now);
      case AnalyticsRange.week:
        return filterLastDays(expenses, now, 7);
      case AnalyticsRange.month:
        return filterMonth(expenses, now);
      case AnalyticsRange.all:
        return expenses;
    }
  }

  // ---------- calculations ----------
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

  List<Expense> filterLastDays(List<Expense> expenses, DateTime now, int days) {
    final start =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
    return expenses.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(start);
    }).toList();
  }

  List<Expense> filterMonth(List<Expense> expenses, DateTime now) {
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
  }

  String dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);
    final diff = today.difference(date).inDays;

    if (diff == 0) return "Today";
    if (diff == 1) return "Yday";

    const wd = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return wd[d.weekday - 1];
  }

  List<DayTotal> dailyTotals(List<Expense> filtered, AnalyticsRange r, DateTime now) {
    if (filtered.isEmpty) return [];
    if (r == AnalyticsRange.today) return [];

    if (r == AnalyticsRange.week) {
      final list = <DayTotal>[];
      for (int i = 6; i >= 0; i--) {
        final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final amount = sum(filterDay(filtered, day));
        list.add(DayTotal(dayLabel(day), amount));
      }
      return list;
    }

    if (r == AnalyticsRange.month) {
      final list = <DayTotal>[];
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month, now.day);

      for (int i = 0; i < 10; i++) {
        final day = end.subtract(Duration(days: i));
        if (day.isBefore(start)) break;
        final amount = sum(filterDay(filtered, day));
        list.add(DayTotal(dayLabel(day), amount));
      }
      return list.reversed.toList();
    }

    // all-time fallback (last 7 days view)
    final list = <DayTotal>[];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final amount = sum(filterDay(filtered, day));
      list.add(DayTotal(dayLabel(day), amount));
    }
    return list;
  }

  Map<String, double> groupByCategory(List<Expense> expenses) {
    final map = <String, double>{};
    for (final e in expenses) {
      final key = categoryLabel(e);
      map[key] = (map[key] ?? 0) + e.amount;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries) e.key: e.value};
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

  String categoryLabel(Expense e) {
    final name = e.category.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  IconData iconFromCategoryName(String name) {
    final n = name.toLowerCase();
    if (n.contains("food")) return Icons.restaurant_rounded;
    if (n.contains("travel")) return Icons.local_gas_station_rounded;
    if (n.contains("work")) return Icons.work_rounded;
    if (n.contains("leisure")) return Icons.sports_esports_rounded;
    return Icons.receipt_long_rounded;
  }

  Color categoryColor(BuildContext context, String categoryLabel) {
    final cs = Theme.of(context).colorScheme;
    final name = categoryLabel.toLowerCase();

    if (name.contains('food')) return cs.tertiary;
    if (name.contains('travel')) return cs.primary;
    if (name.contains('work')) return cs.secondary;
    if (name.contains('leisure')) return cs.error;

    return cs.outline; // Other
  }

  Color onCategoryColor(BuildContext context, Color bg) {
    final cs = Theme.of(context).colorScheme;
    return bg.computeLuminance() > 0.5 ? cs.onSurface : Colors.white;
  }
}
