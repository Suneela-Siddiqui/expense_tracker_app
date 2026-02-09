import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_course_project/core/money/currency.dart';
import 'package:flutter_course_project/core/state/app_riverpod_state.dart';
import 'package:flutter_course_project/core/theme/ui_tokens.dart';
import 'package:flutter_course_project/models/expense.dart';

class NewExpenseBottomSheet extends ConsumerStatefulWidget {
  final void Function(Expense e) onAddExpense;

  const NewExpenseBottomSheet({
    super.key,
    required this.onAddExpense,
  });

  @override
  ConsumerState<NewExpenseBottomSheet> createState() => _NewExpenseBottomSheetState();
}

class _NewExpenseBottomSheetState extends ConsumerState<NewExpenseBottomSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  Category _selectedCategory = Category.leisure;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid title and amount")),
      );
      return;
    }

    final expense = Expense(
      title: title,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
    );

    widget.onAddExpense(expense);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    final currentCurrency = AppCurrency.fromCode(appState.currencyCode);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: Ui.s16,
          right: Ui.s16,
          top: Ui.s12,
          bottom: Ui.s16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: cs.outlineVariant.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: Ui.s12),

            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Add expense",
                    style: t.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                )
              ],
            ),

            const SizedBox(height: Ui.s8),

            // Currency selector (global setting)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Currency",
                style: t.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: Ui.s8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppCurrency.values.map((c) {
                final selected = c.code == currentCurrency.code;
                return ChoiceChip(
                  label: Text("${c.symbol} ${c.code}", style: const TextStyle(fontWeight: FontWeight.w800)),
                  selected: selected,
                  onSelected: (_) => notifier.setCurrency(c.code),
                );
              }).toList(),
            ),

            const SizedBox(height: Ui.s16),

            // Title
            TextField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: "Title",
                hintText: "e.g. Grocery, Fuel, Dinner",
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Ui.r18),
                  borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
                ),
              ),
            ),

            const SizedBox(height: Ui.s12),

            // Amount
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
              ],
              decoration: InputDecoration(
                labelText: "Amount",
                prefixText: "${currentCurrency.symbol} ",
                hintText: "0.00",
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Ui.r18),
                  borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
                ),
              ),
            ),

            const SizedBox(height: Ui.s12),

            // Date + Category row
            Row(
              children: [
                Expanded(
                  child: _pill(
                    context,
                    icon: Icons.calendar_month_rounded,
                    text: "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(now.year - 2),
                        lastDate: DateTime(now.year + 1),
                        initialDate: _selectedDate,
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                  ),
                ),
                const SizedBox(width: Ui.s12),
                Expanded(
                  child: DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    items: Category.values
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                    decoration: InputDecoration(
                      labelText: "Category",
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Ui.r18),
                        borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: Ui.s16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: Ui.s12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text("Add", style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: Ui.s8),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context,
      {required IconData icon, required String text, required VoidCallback onTap}) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(Ui.r18),
      child: InkWell(
        borderRadius: BorderRadius.circular(Ui.r18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900))),
            ],
          ),
        ),
      ),
    );
  }
}
