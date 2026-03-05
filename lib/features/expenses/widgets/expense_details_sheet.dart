import 'package:flutter/material.dart';
import 'package:flutter_course_project/features/expenses/edit_expense_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/features/dashboard/widgets/dashboard_helpers.dart';

class ExpenseDetailsSheet extends ConsumerWidget {
  final dynamic expense;
  final String currencyCode;

  const ExpenseDetailsSheet({
    super.key,
    required this.expense,
    required this.currencyCode,
  });

  String _safeCategoryLabel(dynamic e) {
    try {
      // Best case: your helper returns proper name
      final label = DashboardHelpers().categoryName(e);
      if (label.trim().isNotEmpty && label.toLowerCase() != "category") return label;
    } catch (_) {}

    try {
      // Enum.name
      final name = (e.category as dynamic).name.toString();
      if (name.trim().isNotEmpty) return name;
    } catch (_) {}

    // Fallback
    try {
      return e.category.toString().split('.').last;
    } catch (_) {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final title = expense.title.toString();
    final date = DashboardHelpers().niceDate(expense.date as DateTime);
    final amount = DashboardHelpers().money(expense.amount as double, currencyCode: currencyCode);
    final category = _safeCategoryLabel(expense);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Ui.r28)),
      ),
      padding: const EdgeInsets.fromLTRB(Ui.s18, Ui.s10, Ui.s18, Ui.s18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: cs.outlineVariant.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: Ui.s14),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: t.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.secondary, // Deep Space
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 6),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "$category • $date", // ✅ shows real category name
              style: t.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: Ui.s12),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: t.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.secondary,
                letterSpacing: -0.6,
              ),
            ),
          ),

          const SizedBox(height: Ui.s16),

          _InfoRow(
            leftLabel: "Category",
            leftValue: category,
            rightLabel: "Date",
            rightValue: date,
          ),

          const SizedBox(height: Ui.s18),

          Row(
            children: [
              Expanded(
                child: _PressButton(
                  onTap: () => Navigator.pop(context),
                  background: cs.surface,
                  borderColor: cs.outlineVariant.withValues(alpha: 0.9),
                  textColor: cs.primary, // Raspberry
                  label: "Close",
                ),
              ),
              const SizedBox(width: Ui.s12),
              Expanded(
                child: _PressButton(
                  onTap: () async {
                    // open edit screen
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditExpenseScreen(expense: expense),
                      ),
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context); // close sheet after edit
                  },
                  background: cs.primary, // Raspberry
                  borderColor: Colors.transparent,
                  textColor: cs.onPrimary,
                  label: "Edit",
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  const _InfoRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Ui.s14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(Ui.r22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _KV(label: leftLabel, value: leftValue),
          ),
          const SizedBox(width: Ui.s12),
          Expanded(
            child: _KV(label: rightLabel, value: rightValue, alignEnd: true),
          ),
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _KV({required this.label, required this.value, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: t.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.secondary,
          ),
        ),
      ],
    );
  }
}

/// Premium press animation button (scale + opacity)
class _PressButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color background;
  final Color borderColor;
  final Color textColor;
  final String label;

  const _PressButton({
    required this.onTap,
    required this.background,
    required this.borderColor,
    required this.textColor,
    required this.label,
  });

  @override
  State<_PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<_PressButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _down ? 0.98 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: _down ? 0.92 : 1.0,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.background,
              borderRadius: BorderRadius.circular(Ui.r22),
              border: Border.all(color: widget.borderColor, width: 1.2),
            ),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: widget.textColor,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}