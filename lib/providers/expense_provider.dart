import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/database.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _uuid = const Uuid();

  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  double get totalThisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _expenses
        .where((e) => e.date.isAfter(weekStart.subtract(const Duration(days: 1))))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  List<Expense> get recentExpenses => _expenses.take(5).toList();

  Map<String, double> get categoryTotalsThisMonth {
    final now = DateTime.now();
    final monthly = _expenses.where(
      (e) => e.date.year == now.year && e.date.month == now.month,
    );
    final Map<String, double> totals = {};
    for (final e in monthly) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  double spentForCategory(String category, String period) {
    final now = DateTime.now();
    final filtered = period == 'monthly'
        ? _expenses.where(
            (e) => e.category == category &&
                e.date.year == now.year &&
                e.date.month == now.month,
          )
        : _expenses.where((e) {
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            return e.category == category &&
                e.date.isAfter(weekStart.subtract(const Duration(days: 1)));
          });
    return filtered.fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    final rows = await _db.getExpenses();
    _expenses = rows.map(Expense.fromMap).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> add({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      category: category,
      date: date,
      note: note,
    );
    await _db.insertExpense(expense.toMap());
    _expenses.insert(0, expense);
    notifyListeners();
  }

  Future<void> update(Expense expense) async {
    await _db.updateExpense(expense.toMap());
    final idx = _expenses.indexWhere((e) => e.id == expense.id);
    if (idx != -1) _expenses[idx] = expense;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _db.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
