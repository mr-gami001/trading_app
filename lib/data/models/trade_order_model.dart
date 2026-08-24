import 'package:decimal/decimal.dart';
import '../../domain/entities/trade_order.dart';

class TradeOrderModel extends TradeOrder {
  const TradeOrderModel({
    required super.id,
    required super.symbol,
    required super.side,
    required super.quantity,
    required super.executionPrice,
    required super.totalValue,
    required super.timestamp,
  });

  factory TradeOrderModel.fromEntity(TradeOrder entity) {
    return TradeOrderModel(
      id: entity.id,
      symbol: entity.symbol,
      side: entity.side,
      quantity: entity.quantity,
      executionPrice: entity.executionPrice,
      totalValue: entity.totalValue,
      timestamp: entity.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'symbol': symbol,
        'side': side.name,
        'quantity': quantity,
        'executionPrice': executionPrice.toString(),
        'totalValue': totalValue.toString(),
        'timestamp': timestamp.toIso8601String(),
      };

  factory TradeOrderModel.fromJson(Map<String, dynamic> json) => TradeOrderModel(
        id: json['id'] as String,
        symbol: json['symbol'] as String,
        side: (json['side'] as String) == 'buy' ? OrderSide.buy : OrderSide.sell,
        quantity: json['quantity'] as int,
        executionPrice: Decimal.parse(json['executionPrice'].toString()),
        totalValue: Decimal.parse(json['totalValue'].toString()),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
