import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_course_project/core/state/app_riverpod_state.dart';

class NotificationsScreen extends ConsumerWidget {
  static const routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          TextButton(
            onPressed: notifier.markAllRead,
            child: const Text("Mark read"),
          ),
        ],
      ),
      body: appState.notifications.isEmpty
          ? const Center(child: Text("No notifications yet"))
          : ListView.separated(
              itemCount: appState.notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(appState.notifications[i]),
              ),
            ),
    );
  }
}
