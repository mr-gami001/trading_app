class Holding {
  final String symbol;
  final int quantity;
  final double avgCost;

  const Holding({
    required this.symbol,
    required this.quantity,
    required this.avgCost,
  });

  double get investedValue => double.parse((quantity * avgCost).toStringAsFixed(2));

  double currentValue(double currentLtp) {
    return double.parse((quantity * currentLtp).toStringAsFixed(2));
  }

  double pnl(double currentLtp) {
    return double.parse((currentValue(currentLtp) - investedValue).toStringAsFixed(2));
  }

  double pnlPercent(double currentLtp) {
    if (investedValue == 0) return 0.0;
    return double.parse(((pnl(currentLtp) / investedValue) * 100).toStringAsFixed(2));
  }

  Holding copyWith({
    String? symbol,
    int? quantity,
    double? avgCost,
  }) {
    return Holding(
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      avgCost: avgCost ?? this.avgCost,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'quantity': quantity,
        'avgCost': avgCost,
      };

  factory Holding.fromJson(Map<String, dynamic> json) => Holding(
        symbol: json['symbol'] as String,
        quantity: json['quantity'] as int,
        avgCost: (json['avgCost'] as num).toDouble(),
      );
}
