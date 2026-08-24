import 'package:equatable/equatable.dart';
import '../pages/holdings_page.dart';

abstract class HoldingsTabEvent extends Equatable {
  const HoldingsTabEvent();

  @override
  List<Object?> get props => [];
}

class SelectPortfolioTabEvent extends HoldingsTabEvent {
  final PortfolioTab tab;

  const SelectPortfolioTabEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class UpdateHoldingsSearchQueryEvent extends HoldingsTabEvent {
  final String query;

  const UpdateHoldingsSearchQueryEvent(this.query);

  @override
  List<Object?> get props => [query];
}
