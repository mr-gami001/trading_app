import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/trade_order.dart';

abstract class TradingEvent extends Equatable {
  const TradingEvent();

  @override
  List<Object?> get props => [];
}

class ExecuteOrderEvent extends TradingEvent {
  final String symbol;
  final OrderSide side;
  final int quantity;
  final Decimal ltp;

  const ExecuteOrderEvent({
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.ltp,
  });

  @override
  List<Object?> get props => [symbol, side, quantity, ltp];
}

class ResetTradingStateEvent extends TradingEvent {}
