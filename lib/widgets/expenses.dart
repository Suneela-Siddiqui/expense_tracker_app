import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_course_project/models/expense.dart';
import 'package:flutter_course_project/widgets/chart/chart.dart';
import 'package:flutter_course_project/widgets/expenses_list/expenses_list.dart';
import 'package:flutter_course_project/widgets/new_expense.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<Expense> _registeredExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('expenses') ?? [];
    final loadedExpenses = saved
        .map((e) => Expense.fromJson(jsonDecode(e)))
        .toList();

    setState(() {
      _registeredExpenses = loadedExpenses;
    });
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
    _registeredExpenses.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('expenses', encoded);
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
    _saveExpenses();
  }

  void _removeExpense(Expense expense) {
    setState(() {
      _registeredExpenses.remove(expense);
    });
    _saveExpenses();
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) => NewExpense(onAddExpense: _addExpense),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text('No expenses found. Start adding some!'),
    );

    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: width < 600
          ? Column(
        children: [
          Chart(expenses: _registeredExpenses),
          Expanded(child: mainContent),
        ],
      )
          : Row(
        children: [
          Expanded(child: Chart(expenses: _registeredExpenses)),
          Expanded(child: mainContent),
        ],
      ),
    );
  }
}

