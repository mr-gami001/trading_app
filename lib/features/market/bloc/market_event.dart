import 'package:equatable/equatable.dart';
import '../../../domain/entities/stock_quote.dart';

abstract class MarketEvent extends Equatable {
  const MarketEvent();

  @override
  List<Object?> get props => [];
}

class StartMarketFeedEvent extends MarketEvent {}

class StopMarketFeedEvent extends MarketEvent {}

class OnMarketTickEvent extends MarketEvent {
  final StockQuote quote;

  const OnMarketTickEvent(this.quote);

  @override
  List<Object?> get props => [quote];
}

class SetTickRateEvent extends MarketEvent {
  final int intervalMs;

  const SetTickRateEvent(this.intervalMs);

  @override
  List<Object?> get props => [intervalMs];
}

class ToggleStressModeEvent extends MarketEvent {
  final bool enable;

  const ToggleStressModeEvent(this.enable);

  @override
  List<Object?> get props => [enable];
}
