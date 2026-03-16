class Budget {
  final String id;
  final String category;
  final double limitAmount;
  final String period; // 'monthly' or 'weekly'

  Budget({
    required this.id,
    required this.category,
    required this.limitAmount,
    required this.period,
  });

  factory Budget.fromMap(Map<String, dynamic> map) => Budget(
        id: map['id'] as String,
        category: map['category'] as String,
        limitAmount: (map['limit_amount'] as num).toDouble(),
        period: map['period'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'limit_amount': limitAmount,
        'period': period,
      };

  Budget copyWith({String? category, double? limitAmount, String? period}) => Budget(
        id: id,
        category: category ?? this.category,
        limitAmount: limitAmount ?? this.limitAmount,
        period: period ?? this.period,
      );
}
