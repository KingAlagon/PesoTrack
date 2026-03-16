import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/database.dart';
import '../models/savings_goal.dart';

class SavingsProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _uuid = const Uuid();

  List<SavingsGoal> _goals = [];
  bool _isLoading = false;

  List<SavingsGoal> get goals => _goals;
  bool get isLoading => _isLoading;

  double get totalSaved => _goals.fold(0.0, (sum, g) => sum + g.currentAmount);
  double get totalTarget => _goals.fold(0.0, (sum, g) => sum + g.targetAmount);
  int get completedCount => _goals.where((g) => g.isCompleted).length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    final rows = await _db.getSavingsGoals();
    _goals = rows.map(SavingsGoal.fromMap).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> add({
    required String name,
    required double targetAmount,
    double currentAmount = 0,
    DateTime? deadline,
    required Color color,
  }) async {
    final goal = SavingsGoal(
      id: _uuid.v4(),
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
      color: color,
    );
    await _db.insertSavingsGoal(goal.toMap());
    _goals.add(goal);
    notifyListeners();
  }

  Future<void> update(SavingsGoal goal) async {
    await _db.updateSavingsGoal(goal.toMap());
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) _goals[idx] = goal;
    notifyListeners();
  }

  Future<void> addFunds(String id, double amount) async {
    final idx = _goals.indexWhere((g) => g.id == id);
    if (idx == -1) return;
    final updated = _goals[idx].copyWith(
      currentAmount: _goals[idx].currentAmount + amount,
    );
    await _db.updateSavingsGoal(updated.toMap());
    _goals[idx] = updated;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _db.deleteSavingsGoal(id);
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }
}
