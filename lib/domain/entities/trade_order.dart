import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

enum OrderSide { buy, sell }

class TradeOrder extends Equatable {
  final String id;
  final String symbol;
  final OrderSide side;
  final int quantity;
  final Decimal executionPrice;
  final Decimal totalValue;
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

  @override
  List<Object?> get props => [
        id,
        symbol,
        side,
        quantity,
        executionPrice,
        totalValue,
        timestamp,
      ];
}
