import '../../models/expense.dart';
import 'insight_models.dart';

class InsightEngine {
  List<InsightItem> buildWeeklyInsights(List<Expense> all, DateTime now) {
    final thisWeek = _filterWeek(all, now, weekOffset: 0);
    final lastWeek = _filterWeek(all, now, weekOffset: 1);

    final thisTotal = _sum(thisWeek);
    final lastTotal = _sum(lastWeek);

    final insights = <InsightItem>[];

    // Summary
    insights.add(
      InsightItem(
        type: InsightType.summary,
        title: "This week total",
        message: "You spent ${thisTotal.toStringAsFixed(0)} this week.",
      ),
    );

    // Trend vs last week
    if (lastTotal > 0) {
      final change = (thisTotal - lastTotal) / lastTotal;
      final pct = (change * 100).round();
      final direction = pct >= 0 ? "more" : "less";
      insights.add(
        InsightItem(
          type: InsightType.trend,
          title: "Compared to last week",
          message: "You spent ${pct.abs()}% $direction than last week.",
          value: change,
        ),
      );
    } else {
      insights.add(
        const InsightItem(
          type: InsightType.trend,
          title: "Compared to last week",
          message: "Not enough last-week data to compare yet.",
        ),
      );
    }

    // Top category
    final topCat = _topCategory(thisWeek);
    if (topCat != null) {
      insights.add(
        InsightItem(
          type: InsightType.category,
          title: "Top category",
          message: "${_cap(topCat.$1.name)} is highest: ${topCat.$2.toStringAsFixed(0)}",
        ),
      );
    }

    // Spike day
    final spike = _topDay(thisWeek);
    if (spike != null) {
      insights.add(
        InsightItem(
          type: InsightType.daySpike,
          title: "Biggest day",
          message: "${spike.$1} was your highest spend day: ${spike.$2.toStringAsFixed(0)}",
        ),
      );
    }

    // Suggestion (simple)
    if (topCat != null && thisTotal > 0) {
      const dailyCut = 200.0;
      final monthlySave = dailyCut * 30;
      insights.add(
        InsightItem(
          type: InsightType.suggestion,
          title: "Small win suggestion",
          message:
              "If you reduce ${_cap(topCat.$1.name)} by ${dailyCut.toStringAsFixed(0)}/day, you can save ~${monthlySave.toStringAsFixed(0)}/month.",
        ),
      );
    }

    return insights;
  }

  // Monday start week window
  List<Expense> _filterWeek(List<Expense> all, DateTime now, {required int weekOffset}) {
    final today = DateTime(now.year, now.month, now.day);
    final startThisWeek = today.subtract(Duration(days: today.weekday - 1));
    final start = startThisWeek.subtract(Duration(days: 7 * weekOffset));
    final end = start.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
    return all.where((e) => !e.date.isBefore(start) && !e.date.isAfter(end)).toList();
  }

  double _sum(List<Expense> items) => items.fold(0.0, (p, e) => p + e.amount);

  (Category, double)? _topCategory(List<Expense> items) {
    if (items.isEmpty) return null;
    final map = <Category, double>{};
    for (final e in items) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return (sorted.first.key, sorted.first.value);
  }

  (String, double)? _topDay(List<Expense> items) {
    if (items.isEmpty) return null;
    final map = <int, double>{};
    for (final e in items) {
      map[e.date.weekday] = (map[e.date.weekday] ?? 0) + e.amount;
    }
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return (_weekday(sorted.first.key), sorted.first.value);
  }

  String _weekday(int w) {
    switch (w) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      default:
        return "Sunday";
    }
  }

  String _cap(String s) => s.isEmpty ? s : "${s[0].toUpperCase()}${s.substring(1)}";
}
