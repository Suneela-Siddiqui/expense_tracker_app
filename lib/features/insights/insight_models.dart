enum InsightType { summary, trend, category, daySpike, suggestion }

class InsightItem {
  final InsightType type;
  final String title;
  final String message;
  final double? value;

  const InsightItem({
    required this.type,
    required this.title,
    required this.message,
    this.value,
  });
}
