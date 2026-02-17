import 'package:flutter/material.dart';
import 'package:flutter_course_project/models/expense.dart';
import 'dashboard_filter.dart';

class DashboardFilterSheet extends StatefulWidget {
  final DashboardFilter initial;
  final void Function(DashboardFilter) onApply;
  final VoidCallback onClear;

  const DashboardFilterSheet({
    super.key,
    required this.initial,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<DashboardFilterSheet> createState() => _DashboardFilterSheetState();
}

class _DashboardFilterSheetState extends State<DashboardFilterSheet> {
  late DashboardDateFilter date;
  DateTimeRange? customRange;

  Category? category;

  final minCtrl = TextEditingController();
  final maxCtrl = TextEditingController();

  late DashboardSort sort;

  @override
  void initState() {
    super.initState();
    date = widget.initial.date;
    customRange = widget.initial.customRange;
    category = widget.initial.category;
    sort = widget.initial.sort;

    if (widget.initial.minAmount != null) {
      minCtrl.text = widget.initial.minAmount!.toStringAsFixed(0);
    }
    if (widget.initial.maxAmount != null) {
      maxCtrl.text = widget.initial.maxAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    minCtrl.dispose();
    maxCtrl.dispose();
    super.dispose();
  }

  double? _parse(String s) => double.tryParse(s.trim());

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: customRange,
    );
    if (picked != null) {
      setState(() {
        customRange = picked;
        date = DashboardDateFilter.custom;
      });
    }
  }

  String _categoryLabel(Category c) {
    // display-friendly
    switch (c) {
      case Category.food:
        return "Food";
      case Category.travel:
        return "Travel";
      case Category.leisure:
        return "Leisure";
      case Category.work:
        return "Work";
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Filters",
                    style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  child: const Text("Clear"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Align(alignment: Alignment.centerLeft, child: Text("Date", style: t.textTheme.titleSmall)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text("This month"),
                  selected: date == DashboardDateFilter.thisMonth,
                  onSelected: (_) => setState(() => date = DashboardDateFilter.thisMonth),
                ),
                ChoiceChip(
                  label: const Text("Last 7 days"),
                  selected: date == DashboardDateFilter.last7Days,
                  onSelected: (_) => setState(() => date = DashboardDateFilter.last7Days),
                ),
                ChoiceChip(
                  label: const Text("Today"),
                  selected: date == DashboardDateFilter.today,
                  onSelected: (_) => setState(() => date = DashboardDateFilter.today),
                ),
                ChoiceChip(
                  label: Text(
                    customRange == null
                        ? "Custom"
                        : "${customRange!.start.day}/${customRange!.start.month} - ${customRange!.end.day}/${customRange!.end.month}",
                  ),
                  selected: date == DashboardDateFilter.custom,
                  onSelected: (_) => _pickRange(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Align(alignment: Alignment.centerLeft, child: Text("Category", style: t.textTheme.titleSmall)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Category?>(
              value: category,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text("All categories")),
                ...Category.values.map(
                  (c) => DropdownMenuItem(value: c, child: Text(_categoryLabel(c))),
                ),
              ],
              onChanged: (v) => setState(() => category = v),
            ),

            const SizedBox(height: 16),

            Align(alignment: Alignment.centerLeft, child: Text("Amount", style: t.textTheme.titleSmall)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Min"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Max"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Align(alignment: Alignment.centerLeft, child: Text("Sort", style: t.textTheme.titleSmall)),
            const SizedBox(height: 8),
            DropdownButtonFormField<DashboardSort>(
              value: sort,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: DashboardSort.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => sort = v ?? DashboardSort.newestFirst),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {
                  final f = DashboardFilter(
                    date: date,
                    customRange: date == DashboardDateFilter.custom ? customRange : null,
                    category: category,
                    minAmount: minCtrl.text.trim().isEmpty ? null : _parse(minCtrl.text),
                    maxAmount: maxCtrl.text.trim().isEmpty ? null : _parse(maxCtrl.text),
                    sort: sort,
                  );
                  widget.onApply(f);
                  Navigator.pop(context);
                },
                child: const Text("Apply filters"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
