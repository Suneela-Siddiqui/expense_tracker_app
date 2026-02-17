import 'package:flutter/material.dart';

class MiniTag extends StatelessWidget {
  final String text;
  const MiniTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45), width: 1),
      ),
      child: Text(text, style: t.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900)),
    );
  }
}
