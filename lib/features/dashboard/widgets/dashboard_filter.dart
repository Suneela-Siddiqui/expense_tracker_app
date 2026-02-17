import 'package:flutter/material.dart';
import 'package:flutter_course_project/models/expense.dart';


enum DashboardDateFilter { thisMonth, last7Days, today, custom }
enum DashboardSort { newestFirst, oldestFirst, highestAmount, lowestAmount }

@immutable
class DashboardFilter {
  final DashboardDateFilter date;
  final DateTimeRange? customRange;

  /// ✅ uses your enum Category
  final Category? category;

  final double? minAmount;
  final double? maxAmount;

  final DashboardSort sort;

  const DashboardFilter({
    this.date = DashboardDateFilter.thisMonth,
    this.customRange,
    this.category,
    this.minAmount,
    this.maxAmount,
    this.sort = DashboardSort.newestFirst,
  });

  static const defaults = DashboardFilter();

  bool get hasActiveFilters =>
      date != DashboardDateFilter.thisMonth ||
      category != null ||
      minAmount != null ||
      maxAmount != null ||
      sort != DashboardSort.newestFirst;

  DashboardFilter copyWith({
    DashboardDateFilter? date,
    DateTimeRange? customRange,
    Category? category,
    double? minAmount,
    double? maxAmount,
    DashboardSort? sort,
  }) {
    return DashboardFilter(
      date: date ?? this.date,
      customRange: customRange ?? this.customRange,
      category: category ?? this.category,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      sort: sort ?? this.sort,
    );
  }
}

List<Expense> applyDashboardFilter(List<Expense> input, DashboardFilter f) {
  final now = DateTime.now();

  bool inRange(Expense e) {
    switch (f.date) {
      case DashboardDateFilter.thisMonth:
        return e.date.year == now.year && e.date.month == now.month;

      case DashboardDateFilter.last7Days:
        final from = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
        final to = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return !e.date.isBefore(from) && !e.date.isAfter(to);

      case DashboardDateFilter.today:
        return e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day;

      case DashboardDateFilter.custom:
        final r = f.customRange;
        if (r == null) return true;
        final start = DateTime(r.start.year, r.start.month, r.start.day);
        final end = DateTime(r.end.year, r.end.month, r.end.day, 23, 59, 59);
        return !e.date.isBefore(start) && !e.date.isAfter(end);
    }
  }

  Iterable<Expense> out = input.where(inRange);

  if (f.category != null) {
    out = out.where((e) => e.category == f.category);
  }

  if (f.minAmount != null) out = out.where((e) => e.amount >= f.minAmount!);
  if (f.maxAmount != null) out = out.where((e) => e.amount <= f.maxAmount!);

  final list = out.toList();

  switch (f.sort) {
    case DashboardSort.newestFirst:
      list.sort((a, b) => b.date.compareTo(a.date));
      break;
    case DashboardSort.oldestFirst:
      list.sort((a, b) => a.date.compareTo(b.date));
      break;
    case DashboardSort.highestAmount:
      list.sort((a, b) => b.amount.compareTo(a.amount));
      break;
    case DashboardSort.lowestAmount:
      list.sort((a, b) => a.amount.compareTo(b.amount));
      break;
  }

  return list;
}
