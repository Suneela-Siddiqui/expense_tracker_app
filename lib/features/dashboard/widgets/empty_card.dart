

import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';

class EmptyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyCard({super.key, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(Ui.r18),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

