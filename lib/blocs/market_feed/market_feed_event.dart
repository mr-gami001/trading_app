import 'package:equatable/equatable.dart';

abstract class MarketFeedEvent extends Equatable {
  const MarketFeedEvent();

  @override
  List<Object?> get props => [];
}

class StartMarketFeedEvent extends MarketFeedEvent {}

class StopMarketFeedEvent extends MarketFeedEvent {}

class GenerateNextTickEvent extends MarketFeedEvent {}

class SetTickIntervalEvent extends MarketFeedEvent {
  final int intervalMs;

  const SetTickIntervalEvent(this.intervalMs);

  @override
  List<Object?> get props => [intervalMs];
}

class ToggleStressModeEvent extends MarketFeedEvent {
  final bool enable;

  const ToggleStressModeEvent(this.enable);

  @override
  List<Object?> get props => [enable];
}
