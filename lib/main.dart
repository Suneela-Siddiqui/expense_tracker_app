import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_course_project/core/theme/app_theme.dart';
import 'package:flutter_course_project/features/dashboard/dashboard_screen.dart';
import 'package:flutter_course_project/features/analytics/analytics_screen.dart';
import 'package:flutter_course_project/features/notifications/notifications_screen.dart';

void main() {
  runApp(const ProviderScope(child: SpendWiseApp()));
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
      routes: {
        AnalyticsScreen.routeName: (_) => const AnalyticsScreen(),
        NotificationsScreen.routeName: (_) => const NotificationsScreen(),
      },
    );
  }
}
