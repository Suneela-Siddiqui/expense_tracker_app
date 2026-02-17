import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/app_riverpod_state.dart';
import 'insight_engine.dart';
import 'insight_models.dart';

final weeklyInsightsProvider = Provider<List<InsightItem>>((ref) {
  final app = ref.watch(appStateProvider);
  return InsightEngine().buildWeeklyInsights(app.expenses, DateTime.now());
});
