import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'holdings_state.dart';

abstract class HoldingsEvent extends Equatable {
  const HoldingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPortfolioEvent extends HoldingsEvent {}

class SetSortOptionEvent extends HoldingsEvent {
  final HoldingSortOption option;

  const SetSortOptionEvent(this.option);

  @override
  List<Object?> get props => [option];
}

class ResetWalletBalanceEvent extends HoldingsEvent {
  final Decimal? newBalance;

  const ResetWalletBalanceEvent([this.newBalance]);

  @override
  List<Object?> get props => [newBalance];
}
