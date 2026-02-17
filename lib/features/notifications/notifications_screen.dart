import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/models/app_notification.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  static const routeName = '/notifications';
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  int tabIndex = 0; // 0=All, 1=Unread
  bool earlierExpanded = true;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    final all = appState.notifications;
    final unread = all.where((n) => !n.isRead).toList();
    final active = (tabIndex == 0) ? all : unread;

    final groups = _groupByDay(active);
    final earlier = groups["Earlier"] ?? const <AppNotification>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          TextButton(
            onPressed: all.isEmpty ? null : notifier.markAllRead,
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
          ),
          const SizedBox(width: Ui.s8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Ui.s16, 0, Ui.s16, Ui.s12),
            child: _FilterTabs(
              value: tabIndex,
              onChanged: (v) => setState(() => tabIndex = v),
              allCount: all.length,
              unreadCount: unread.length,
            ),
          ),
        ),
      ),

      body: active.isEmpty
          ? _PrettyEmptyState(
              title: tabIndex == 1 ? "No unread notifications" : "No notifications yet",
              subtitle: tabIndex == 1
                  ? "You’re all caught up."
                  : "When you add expenses or insights drop, you’ll see them here.",
              icon: Icons.notifications_none_rounded,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(Ui.s16, Ui.s12, Ui.s16, Ui.s24),
              children: [
                if ((groups["Today"] ?? const []).isNotEmpty) ...[
                  _AnimatedGroupHeader(title: "Today"),
                  const SizedBox(height: Ui.s10),
                  ...groups["Today"]!.map((n) => _SwipeableNotificationCard(
                        n: n,
                        onDelete: () => _deleteWithUndo(context, notifier, n),
                        onToggleRead: () => notifier.toggleNotificationRead(n.id),
                        onTap: () => notifier.toggleNotificationRead(n.id),
                      )),
                  const SizedBox(height: Ui.s6),
                ],

                if ((groups["Yesterday"] ?? const []).isNotEmpty) ...[
                  const SizedBox(height: Ui.s8),
                  _AnimatedGroupHeader(title: "Yesterday"),
                  const SizedBox(height: Ui.s10),
                  ...groups["Yesterday"]!.map((n) => _SwipeableNotificationCard(
                        n: n,
                        onDelete: () => _deleteWithUndo(context, notifier, n),
                        onToggleRead: () => notifier.toggleNotificationRead(n.id),
                        onTap: () => notifier.toggleNotificationRead(n.id),
                      )),
                  const SizedBox(height: Ui.s6),
                ],

                if (earlier.isNotEmpty) ...[
                  const SizedBox(height: Ui.s8),

                  // ✅ Collapsible “Earlier”
                  _CollapsibleHeader(
                    title: "Earlier",
                    count: earlier.length,
                    expanded: earlierExpanded,
                    onTap: () => setState(() => earlierExpanded = !earlierExpanded),
                  ),

                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 220),
                    crossFadeState: earlierExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: [
                        const SizedBox(height: Ui.s10),
                        ...earlier.map((n) => _SwipeableNotificationCard(
                              n: n,
                              onDelete: () => _deleteWithUndo(context, notifier, n),
                              onToggleRead: () => notifier.toggleNotificationRead(n.id),
                              onTap: () => notifier.toggleNotificationRead(n.id),
                            )),
                      ],
                    ),
                    secondChild: const SizedBox(height: 6),
                  ),
                ],
              ],
            ),
    );
  }

  void _deleteWithUndo(
    BuildContext context,
    dynamic notifier,
    AppNotification n,
  ) {
    notifier.removeNotification(n.id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Deleted notification"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () => notifier.addExistingNotification(n),
        ),
      ),
    );
  }
}

/* ------------------------------ Tabs ------------------------------ */

class _FilterTabs extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int allCount;
  final int unreadCount;

  const _FilterTabs({
    required this.value,
    required this.onChanged,
    required this.allCount,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    Widget tab(String label, int idx, int count) {
      final selected = value == idx;
      return Expanded(
        child: Material(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onChanged(idx),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: t.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: selected ? cs.onPrimaryContainer : cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? cs.onPrimaryContainer.withValues(alpha: 0.12)
                          : cs.outlineVariant.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      "$count",
                      style: t.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tab("All", 0, allCount),
        const SizedBox(width: Ui.s10),
        tab("Unread", 1, unreadCount),
      ],
    );
  }
}

/* ------------------------------ Grouping ------------------------------ */

Map<String, List<AppNotification>> _groupByDay(List<AppNotification> items) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final map = <String, List<AppNotification>>{
    "Today": [],
    "Yesterday": [],
    "Earlier": [],
  };

  for (final n in items) {
    final d = n.createdAt;
    final date = DateTime(d.year, d.month, d.day);

    if (date == today) {
      map["Today"]!.add(n);
    } else if (date == yesterday) {
      map["Yesterday"]!.add(n);
    } else {
      map["Earlier"]!.add(n);
    }
  }

  map.removeWhere((k, v) => v.isEmpty);
  return map;
}

/* ------------------------------ Animated Headers ------------------------------ */

class _AnimatedGroupHeader extends StatelessWidget {
  final String title;
  const _AnimatedGroupHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      builder: (context, v, child) {
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - v)),
            child: child,
          ),
        );
      },
      child: Text(
        title,
        style: t.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: cs.onSurface,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _CollapsibleHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool expanded;
  final VoidCallback onTap;

  const _CollapsibleHeader({
    required this.title,
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(Ui.r18),
      child: InkWell(
        borderRadius: BorderRadius.circular(Ui.r18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Ui.s12, vertical: Ui.s10),
          child: Row(
            children: [
              Text(
                title,
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "$count",
                  style: t.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: expanded ? 0.5 : 0.0,
                child: Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ Swipeable Card ------------------------------ */

class _SwipeableNotificationCard extends StatelessWidget {
  final AppNotification n;
  final VoidCallback onDelete;
  final VoidCallback onToggleRead;
  final VoidCallback onTap;

  const _SwipeableNotificationCard({
    required this.n,
    required this.onDelete,
    required this.onToggleRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: Ui.s12),
      child: Dismissible(
        key: ValueKey(n.id),
        // ✅ both sides
        direction: DismissDirection.horizontal,

        // ✅ Right swipe = Delete
        background: const _DeleteSwipeBg(),

        // ✅ Left swipe = Toggle Read/Unread
        secondaryBackground: _ToggleReadSwipeBg(isUnread: !n.isRead),

        confirmDismiss: (dir) async {
          // Right -> delete
          if (dir == DismissDirection.startToEnd) {
            onDelete();
            return true;
          }
          // Left -> toggle read/unread (don’t dismiss)
          if (dir == DismissDirection.endToStart) {
            onToggleRead();
            return false;
          }
          return false;
        },

        child: _NotificationCard(
          title: n.title,
          timeText: _niceTime(n.createdAt),
          isUnread: !n.isRead,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _ToggleReadSwipeBg extends StatelessWidget {
  final bool isUnread;
  const _ToggleReadSwipeBg({required this.isUnread});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.tertiary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(Ui.r22),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: Ui.s18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(isUnread ? Icons.mark_email_read_rounded : Icons.mark_email_unread_rounded,
              color: cs.onTertiary, size: 22),
          const SizedBox(width: 8),
          Text(
            isUnread ? "Mark read" : "Mark unread",
            style: TextStyle(color: cs.onTertiary, fontWeight: FontWeight.w900),
          )
        ],
      ),
    );
  }
}

/* ------------------------------ Card ------------------------------ */

class _NotificationCard extends StatelessWidget {
  final String title;
  final String timeText;
  final bool isUnread;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.title,
    required this.timeText,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final accent = isUnread ? cs.primary : cs.outlineVariant;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(Ui.r22),
      child: InkWell(
        borderRadius: BorderRadius.circular(Ui.r22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Ui.s14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(Ui.r16),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
                ),
                child: Icon(
                  isUnread ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                  size: 22,
                  color: isUnread ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: Ui.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
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
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeText,
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
  }
}

/* ------------------------------ Swipe BG ------------------------------ */

class _DeleteSwipeBg extends StatelessWidget {
  const _DeleteSwipeBg();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(Ui.r22),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: Ui.s18),
      child: Row(
        children: [
          Icon(Icons.delete_rounded, color: cs.onError, size: 22),
          const SizedBox(width: 8),
          Text("Delete", style: TextStyle(color: cs.onError, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

/* ------------------------------ Empty ------------------------------ */

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
              Text(title, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
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

/* ------------------------------ Time ------------------------------ */

String _niceTime(DateTime d) {
  final now = DateTime.now();
  final diff = now.difference(d);

  if (diff.inMinutes < 1) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hr ago";
  return "${d.day}/${d.month}/${d.year}";
}
