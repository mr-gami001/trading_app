import 'dart:async';
import 'package:equatable/equatable.dart';
import '../../models/trade_order.dart';
import 'portfolio_state.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object?> get props => [];
}

class InitPortfolioEvent extends PortfolioEvent {}

class SetHoldingSortOptionEvent extends PortfolioEvent {
  final HoldingSortOption option;

  const SetHoldingSortOptionEvent(this.option);

  @override
  List<Object?> get props => [option];
}

class PlaceOrderEvent extends PortfolioEvent {
  final String symbol;
  final OrderSide side;
  final int quantity;
  final double ltp;
  final Completer<String?>? completer;

  const PlaceOrderEvent({
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.ltp,
    this.completer,
  });

  @override
  List<Object?> get props => [symbol, side, quantity, ltp];
}

class ResetWalletBalanceEvent extends PortfolioEvent {
  final double newBalance;

  const ResetWalletBalanceEvent([this.newBalance = 100000.00]);

  @override
  List<Object?> get props => [newBalance];
}
