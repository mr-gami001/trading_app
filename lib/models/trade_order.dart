enum OrderSide { buy, sell }

class TradeOrder {
  final String id;
  final String symbol;
  final OrderSide side;
  final int quantity;
  final double executionPrice;
  final double totalValue;
  final DateTime timestamp;

  const TradeOrder({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.executionPrice,
    required this.totalValue,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'symbol': symbol,
        'side': side.name,
        'quantity': quantity,
        'executionPrice': executionPrice,
        'totalValue': totalValue,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TradeOrder.fromJson(Map<String, dynamic> json) => TradeOrder(
        id: json['id'] as String,
        symbol: json['symbol'] as String,
        side: (json['side'] as String) == 'buy' ? OrderSide.buy : OrderSide.sell,
        quantity: json['quantity'] as int,
        executionPrice: (json['executionPrice'] as num).toDouble(),
        totalValue: (json['totalValue'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
