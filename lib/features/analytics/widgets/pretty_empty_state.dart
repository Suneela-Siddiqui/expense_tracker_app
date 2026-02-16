import 'package:flutter/material.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';

class PrettyEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const PrettyEmptyState({super.key, 
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
            color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(Ui.r28),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.6),
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


