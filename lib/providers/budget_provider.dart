import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/database.dart';
import '../models/budget.dart';

class BudgetProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _uuid = const Uuid();

  List<Budget> _budgets = [];
  bool _isLoading = false;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;

  Budget? budgetForCategory(String category) =>
      _budgets.where((b) => b.category == category).firstOrNull;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    final rows = await _db.getBudgets();
    _budgets = rows.map(Budget.fromMap).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> add({
    required String category,
    required double limitAmount,
    required String period,
  }) async {
    // Replace existing budget for same category
    final existing = budgetForCategory(category);
    if (existing != null) {
      final updated = existing.copyWith(limitAmount: limitAmount, period: period);
      await _db.updateBudget(updated.toMap());
      final idx = _budgets.indexWhere((b) => b.id == existing.id);
      _budgets[idx] = updated;
      notifyListeners();
      return;
    }
    final budget = Budget(
      id: _uuid.v4(),
      category: category,
      limitAmount: limitAmount,
      period: period,
    );
    await _db.insertBudget(budget.toMap());
    _budgets.add(budget);
    notifyListeners();
  }

  Future<void> update(Budget budget) async {
    await _db.updateBudget(budget.toMap());
    final idx = _budgets.indexWhere((b) => b.id == budget.id);
    if (idx != -1) _budgets[idx] = budget;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _db.deleteBudget(id);
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }
}
