import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';

class NotificationsScreen extends ConsumerWidget {
  static const routeName = '/notifications';
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

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
          ? _PrettyEmptyState(
              title: "No notifications yet",
              subtitle: "When you add expenses or insights drop, you’ll see them here.",
              icon: Icons.notifications_none_rounded,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(Ui.s16, Ui.s12, Ui.s16, Ui.s24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: Ui.s12),
              itemBuilder: (_, i) {
                final n = items[i];

                final isUnread = !n.isRead;
                final accent = isUnread ? cs.primary : cs.outlineVariant;

                return Material(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(Ui.r22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Ui.r22),
                    onTap: () => notifier.markNotificationRead(n.id),
                    child: Padding(
                      padding: const EdgeInsets.all(Ui.s14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Accent dot / icon box
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(Ui.r16),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Icon(
                              isUnread
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_none_rounded,
                              size: 22,
                              color: isUnread ? cs.primary : cs.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(width: Ui.s12),

                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.textTheme.titleSmall?.copyWith(
                                          fontWeight: isUnread ? FontWeight.w900 : FontWeight.w700,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                    if (isUnread) ...[
                                      const SizedBox(width: Ui.s10),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: cs.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                                const SizedBox(height: 6),

                                Text(
                                  _niceTime(n.createdAt),
                                  style: t.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/* ------------------------------ Empty state ------------------------------ */

class _PrettyEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PrettyEmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Ui.s24),
        child: Container(
          padding: const EdgeInsets.all(Ui.s18),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(Ui.r28),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(Ui.r22),
                ),
                child: Icon(icon, size: 30, color: cs.onPrimaryContainer),
              ),
              const SizedBox(height: Ui.s16),
              Text(
                title,
                style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ time helper ------------------------------ */

String _niceTime(DateTime d) {
  final now = DateTime.now();
  final diff = now.difference(d);

  if (diff.inMinutes < 1) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hr ago";
  return "${d.day}/${d.month}/${d.year}";
}
