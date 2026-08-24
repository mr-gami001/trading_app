import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/stock_quote.dart';
import '../../../domain/repositories/market_repository.dart';
import 'market_event.dart';
import 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final MarketRepository repository;
  StreamSubscription<StockQuote>? _tickSubscription;

  MarketBloc({required this.repository})
      : super(MarketState(quotes: Map.from(repository.currentQuotes))) {
    on<StartMarketFeedEvent>(_onStartFeed);
    on<StopMarketFeedEvent>(_onStopFeed);
    on<OnMarketTickEvent>(_onMarketTick);
    on<SetTickRateEvent>(_onSetTickRate);
    on<ToggleStressModeEvent>(_onToggleStressMode);

    add(StartMarketFeedEvent());
  }

  void _onStartFeed(StartMarketFeedEvent event, Emitter<MarketState> emit) {
    repository.startFeed();
    _tickSubscription?.cancel();
    _tickSubscription = repository.tickStream.listen((quote) {
      add(OnMarketTickEvent(quote));
    });
  }

  void _onStopFeed(StopMarketFeedEvent event, Emitter<MarketState> emit) {
    repository.stopFeed();
    _tickSubscription?.cancel();
    _tickSubscription = null;
  }

  void _onMarketTick(OnMarketTickEvent event, Emitter<MarketState> emit) {
    final updatedMap = Map<String, StockQuote>.from(state.quotes);
    updatedMap[event.quote.symbol] = event.quote;

    emit(state.copyWith(
      quotes: updatedMap,
      totalTicksCount: repository.totalTicksCount,
      lastTickedSymbol: event.quote.symbol,
    ));
  }

  void _onSetTickRate(SetTickRateEvent event, Emitter<MarketState> emit) {
    repository.setTickInterval(event.intervalMs);
    emit(state.copyWith(
      tickIntervalMs: repository.tickIntervalMs,
      isStressMode: repository.isStressMode,
    ));
  }

  void _onToggleStressMode(ToggleStressModeEvent event, Emitter<MarketState> emit) {
    repository.toggleStressMode(event.enable);
    emit(state.copyWith(
      isStressMode: repository.isStressMode,
      tickIntervalMs: repository.tickIntervalMs,
    ));
  }

  @override
  Future<void> close() {
    _tickSubscription?.cancel();
    return super.close();
  }
}
