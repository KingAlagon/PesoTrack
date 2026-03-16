import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/database.dart';
import '../models/investment.dart';

class InvestmentProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _uuid = const Uuid();

  List<Investment> _investments = [];
  bool _isLoading = false;

  List<Investment> get investments => _investments;
  bool get isLoading => _isLoading;

  double get totalInvested => _investments.fold(0.0, (sum, i) => sum + i.totalCost);
  double get totalCurrentValue => _investments.fold(0.0, (sum, i) => sum + i.currentValue);
  double get totalGainLoss => totalCurrentValue - totalInvested;
  double get totalGainLossPercent =>
      totalInvested > 0 ? (totalGainLoss / totalInvested) * 100 : 0;
  bool get isOverallProfit => totalGainLoss >= 0;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    final rows = await _db.getInvestments();
    _investments = rows.map(Investment.fromMap).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> add({
    required String name,
    required String type,
    String? ticker,
    required double quantity,
    required double buyPrice,
    required double currentPrice,
    required DateTime date,
  }) async {
    final investment = Investment(
      id: _uuid.v4(),
      name: name,
      type: type,
      ticker: ticker,
      quantity: quantity,
      buyPrice: buyPrice,
      currentPrice: currentPrice,
      date: date,
    );
    await _db.insertInvestment(investment.toMap());
    _investments.insert(0, investment);
    notifyListeners();
  }

  Future<void> update(Investment investment) async {
    await _db.updateInvestment(investment.toMap());
    final idx = _investments.indexWhere((i) => i.id == investment.id);
    if (idx != -1) _investments[idx] = investment;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _db.deleteInvestment(id);
    _investments.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}
