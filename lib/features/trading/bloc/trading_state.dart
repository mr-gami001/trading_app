import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/trade_order.dart';

abstract class TradingState extends Equatable {
  const TradingState();

  @override
  List<Object?> get props => [];
}

class TradingInitial extends TradingState {}

class TradingSubmitting extends TradingState {}

class TradingSuccess extends TradingState {
  final String symbol;
  final OrderSide side;
  final int quantity;
  final Decimal executionPrice;
  final Decimal totalValue;

  const TradingSuccess({
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.executionPrice,
    required this.totalValue,
  });

  @override
  List<Object?> get props => [symbol, side, quantity, executionPrice, totalValue];
}

class TradingFailure extends TradingState {
  final String errorMessage;

  const TradingFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
