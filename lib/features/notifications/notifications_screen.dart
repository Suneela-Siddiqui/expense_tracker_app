import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/state/app_scope.dart';

class NotificationsScreen extends StatelessWidget {
  static const routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          TextButton(
            onPressed: app.markAllRead,
            child: const Text("Mark read"),
          ),
        ],
      ),
      body: app.notifications.isEmpty
          ? const Center(child: Text("No notifications yet"))
          : ListView.separated(
              itemCount: app.notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(app.notifications[i]),
              ),
            ),
    );
  }
}
