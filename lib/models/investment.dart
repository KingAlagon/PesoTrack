class Investment {
  final String id;
  final String name;
  final String type;
  final String? ticker;
  final double quantity;
  final double buyPrice;
  final double currentPrice;
  final DateTime date;

  Investment({
    required this.id,
    required this.name,
    required this.type,
    this.ticker,
    required this.quantity,
    required this.buyPrice,
    required this.currentPrice,
    required this.date,
  });

  double get totalCost => buyPrice * quantity;
  double get currentValue => currentPrice * quantity;
  double get gainLoss => currentValue - totalCost;
  double get gainLossPercent => totalCost > 0 ? (gainLoss / totalCost) * 100 : 0;
  bool get isProfit => gainLoss >= 0;

  factory Investment.fromMap(Map<String, dynamic> map) => Investment(
        id: map['id'] as String,
        name: map['name'] as String,
        type: map['type'] as String,
        ticker: map['ticker'] as String?,
        quantity: (map['quantity'] as num).toDouble(),
        buyPrice: (map['buy_price'] as num).toDouble(),
        currentPrice: (map['current_price'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'ticker': ticker,
        'quantity': quantity,
        'buy_price': buyPrice,
        'current_price': currentPrice,
        'date': date.toIso8601String(),
      };

  Investment copyWith({
    String? name,
    String? type,
    String? ticker,
    double? quantity,
    double? buyPrice,
    double? currentPrice,
    DateTime? date,
  }) =>
      Investment(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        ticker: ticker ?? this.ticker,
        quantity: quantity ?? this.quantity,
        buyPrice: buyPrice ?? this.buyPrice,
        currentPrice: currentPrice ?? this.currentPrice,
        date: date ?? this.date,
      );
}
