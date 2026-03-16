class PiggyBank {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;

  PiggyBank({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  double get remaining => (targetAmount - currentAmount).clamp(0, double.infinity);
  bool get isCompleted => currentAmount >= targetAmount;

  factory PiggyBank.fromMap(Map<String, dynamic> map) => PiggyBank(
        id: map['id'] as String,
        name: map['name'] as String,
        targetAmount: (map['target_amount'] as num).toDouble(),
        currentAmount: (map['current_amount'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
      };

  PiggyBank copyWith({String? name, double? targetAmount, double? currentAmount}) =>
      PiggyBank(
        id: id,
        name: name ?? this.name,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
      );
}
