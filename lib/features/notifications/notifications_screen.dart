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

    final items = appState.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          TextButton(
            onPressed: items.isEmpty ? null : notifier.markAllRead,
            child: const Text("Mark all read"),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == "clear") {
                final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Clear all notifications?"),
                        content: const Text("This will remove your notification history."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (ok) notifier.clearAllNotifications();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "clear", child: Text("Clear all")),
            ],
          )
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text("No notifications yet"))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = items[i];

                return ListTile(
                  leading: Icon(
                    n.isRead ? Icons.notifications_none : Icons.notifications_active,
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(_niceTime(n.createdAt)),
                  trailing: n.isRead
                      ? null
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                  onTap: () {
                    notifier.markNotificationRead(n.id);
                    // Later we can navigate/deep-link here if you want
                  },
                );
              },
            ),
    );
  }
}

String _niceTime(DateTime d) {
  final now = DateTime.now();
  final diff = now.difference(d);

  if (diff.inMinutes < 1) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hr ago";
  return "${d.day}/${d.month}/${d.year}";
}
