import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/models/expense.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  late final TextEditingController _title;
  late final TextEditingController _amount;

  late DateTime _date;
  late Category _category;

  @override
  void initState() {
    super.initState();

    _title = TextEditingController(text: widget.expense.title);
    _amount = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(0),
    );

    _date = widget.expense.date;
    _category = widget.expense.category;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  String _catLabel(Category c) {
    switch (c) {
      case Category.food:
        return 'Food';
      case Category.travel:
        return 'Travel';
      case Category.leisure:
        return 'Leisure';
      case Category.work:
        return 'Work';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _save() {
    final notifier = ref.read(appStateProvider.notifier);

    final title = _title.text.trim();
    final amountText = _amount.text.trim().replaceAll(',', '');
    final amount = double.tryParse(amountText);

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid title and amount.")),
      );
      return;
    }

    final old = widget.expense;

    final updated = Expense(
      id: old.id,
      title: title,
      amount: amount,
      date: _date,
      category: _category,
      currency: old.currency,
    );

    notifier.removeExpense(old);
    notifier.addExpense(updated);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final currency = widget.expense.currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Expense"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Ui.s16, Ui.s16, Ui.s16, Ui.s24),
        children: [
          _FieldLabel("Name"),
          TextField(
            controller: _title,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(hintText: "e.g. Grocery"),
          ),
          const SizedBox(height: Ui.s14),

          _FieldLabel("Amount"),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: "e.g. 4000",
              prefixText: '$currency ',
            ),
          ),
          const SizedBox(height: Ui.s14),

          _FieldLabel("Currency"),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Ui.s14,
              vertical: Ui.s14,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(Ui.r18),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.currency_exchange, color: cs.secondary),
                const SizedBox(width: Ui.s12),
                Expanded(
                  child: Text(
                    currency,
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  'Locked',
                  style: t.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Ui.s14),

          _FieldLabel("Date"),
          _PressTile(
            onTap: _pickDate,
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: cs.secondary),
                const SizedBox(width: Ui.s12),
                Expanded(
                  child: Text(
                    "${_date.day}/${_date.month}/${_date.year}",
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          ),
          const SizedBox(height: Ui.s14),

          _FieldLabel("Category"),
          DropdownButtonFormField<Category>(
            value: _category,
            items: Category.values
                .map(
                  (c) => DropdownMenuItem<Category>(
                    value: c,
                    child: Text(_catLabel(c)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => _category = v);
            },
            decoration: const InputDecoration(),
          ),

          const SizedBox(height: Ui.s18),

          _PressCta(
            label: "Save",
            onTap: _save,
          ),
        ],
      ),
    );
  }
}

/* ---------------- UI helpers ---------------- */

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: t.textTheme.bodySmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PressTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressTile({required this.child, required this.onTap});

  @override
  State<_PressTile> createState() => _PressTileState();
}

class _PressTileState extends State<_PressTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        scale: _down ? 0.985 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          opacity: _down ? 0.92 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Ui.s14,
              vertical: Ui.s14,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(Ui.r18),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _PressCta extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _PressCta({required this.label, required this.onTap});

  @override
  State<_PressCta> createState() => _PressCtaState();
}

class _PressCtaState extends State<_PressCta> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        scale: _down ? 0.985 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          opacity: _down ? 0.92 : 1.0,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(Ui.r22),
            ),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onPrimary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}