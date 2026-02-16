import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/features/analytics/widgets/analytics_helpers.dart';
import 'package:flutter_course_project/features/analytics/widgets/mini_stat.dart';

class QuickStatsRow extends StatelessWidget {
  final String currencyCode;
  final double today;
  final double yesterday;
  final double month;
  final double allTime;

  const QuickStatsRow({super.key, 
    required this.currencyCode,
    required this.today,
    required this.yesterday,
    required this.month,
    required this.allTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: MiniStat(label: "Today", value: AnalyticsHelper().money(today, currencyCode: currencyCode))),
        const SizedBox(width: Ui.s10),
        Expanded(child: MiniStat(label: "Yesterday", value: AnalyticsHelper().money(yesterday, currencyCode: currencyCode))),
        const SizedBox(width: Ui.s10),
        Expanded(child: MiniStat(label: "Month", value: AnalyticsHelper().money(month, currencyCode: currencyCode))),
        const SizedBox(width: Ui.s10),
        Expanded(child: MiniStat(label: "All", value: AnalyticsHelper().money(allTime, currencyCode: currencyCode))),
      ],
    );
  }
}