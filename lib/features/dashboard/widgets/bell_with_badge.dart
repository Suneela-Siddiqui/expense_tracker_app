import 'package:flutter/material.dart';
import 'package:flutter_course_project/features/dashboard/widgets/icon_pill_button.dart';

class BellWithBadge extends StatelessWidget {
  final int unread;
  final VoidCallback onTap;
  const BellWithBadge({super.key, required this.unread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconPillButton(icon: Icons.notifications_none_rounded, onTap: onTap),
        if (unread > 0)
          Positioned(
            right: 2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                unread > 99 ? "99+" : "$unread",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}