import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/database.dart';
import '../models/piggy_bank.dart';

class PiggyBankProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _uuid = const Uuid();

  PiggyBank? _piggyBank;
  bool _isLoading = false;

  PiggyBank? get piggyBank => _piggyBank;
  bool get isLoading => _isLoading;
  bool get hasSetup => _piggyBank != null;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    final row = await _db.getPiggyBank();
    _piggyBank = row != null ? PiggyBank.fromMap(row) : null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setup({required String name, required double targetAmount}) async {
    final pig = PiggyBank(
      id: _uuid.v4(),
      name: name,
      targetAmount: targetAmount,
      currentAmount: 0,
    );
    await _db.savePiggyBank(pig.toMap());
    _piggyBank = pig;
    notifyListeners();
  }

  Future<void> addMoney(double amount) async {
    if (_piggyBank == null) return;
    final updated = _piggyBank!.copyWith(
      currentAmount: _piggyBank!.currentAmount + amount,
    );
    await _db.updatePiggyBank(updated.toMap());
    _piggyBank = updated;
    notifyListeners();
  }

  Future<void> withdraw(double amount) async {
    if (_piggyBank == null) return;
    final newAmount = (_piggyBank!.currentAmount - amount).clamp(0.0, double.infinity);
    final updated = _piggyBank!.copyWith(currentAmount: newAmount);
    await _db.updatePiggyBank(updated.toMap());
    _piggyBank = updated;
    notifyListeners();
  }

  Future<void> updateTarget({required String name, required double targetAmount}) async {
    if (_piggyBank == null) return;
    final updated = _piggyBank!.copyWith(name: name, targetAmount: targetAmount);
    await _db.updatePiggyBank(updated.toMap());
    _piggyBank = updated;
    notifyListeners();
  }

  Future<void> reset() async {
    if (_piggyBank == null) return;
    await _db.deletePiggyBank(_piggyBank!.id);
    _piggyBank = null;
    notifyListeners();
  }
}
