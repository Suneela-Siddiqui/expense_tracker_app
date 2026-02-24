import 'package:flutter/material.dart';

class IconPillButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const IconPillButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.75),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: cs.secondary, // ✅ Deep Space structural
          ),
        ),
      ),
    );
  }
}