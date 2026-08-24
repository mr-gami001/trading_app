import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/stock_quote.dart';
import 'market_feed_event.dart';
import 'market_feed_state.dart';

class InitialStockData {
  final String symbol;
  final String name;
  final double initialPrice;

  const InitialStockData(this.symbol, this.name, this.initialPrice);
}

class MarketFeedBloc extends Bloc<MarketFeedEvent, MarketFeedState> {
  static final List<InitialStockData> initialUniverse = [
    const InitialStockData('RELIANCE', 'Reliance Industries Ltd.', 2950.50),
    const InitialStockData('TCS', 'Tata Consultancy Services', 4120.00),
    const InitialStockData('INFY', 'Infosys Ltd.', 1850.25),
    const InitialStockData('HDFCBANK', 'HDFC Bank Ltd.', 1620.00),
    const InitialStockData('ICICIBANK', 'ICICI Bank Ltd.', 1180.75),
    const InitialStockData('SBIN', 'State Bank of India', 840.50),
    const InitialStockData('ITC', 'ITC Ltd.', 490.00),
    const InitialStockData('LT', 'Larsen & Toubro Ltd.', 3650.00),
    const InitialStockData('BHARTIARTL', 'Bharti Airtel Ltd.', 1475.25),
    const InitialStockData('AXISBANK', 'Axis Bank Ltd.', 1170.00),
  ];

  Timer? _timer;
  final Random _random = Random();

  MarketFeedBloc() : super(_createInitialState()) {
    on<StartMarketFeedEvent>(_onStartFeed);
    on<StopMarketFeedEvent>(_onStopFeed);
    on<GenerateNextTickEvent>(_onGenerateNextTick);
    on<SetTickIntervalEvent>(_onSetTickInterval);
    on<ToggleStressModeEvent>(_onToggleStressMode);

    add(StartMarketFeedEvent());
  }

  static MarketFeedState _createInitialState() {
    final Map<String, StockQuote> initialQuotes = {};
    for (final item in initialUniverse) {
      initialQuotes[item.symbol] = StockQuote.initial(
        symbol: item.symbol,
        name: item.name,
        initialPrice: item.initialPrice,
      );
    }
    return MarketFeedState(quotes: initialQuotes);
  }

  void _onStartFeed(StartMarketFeedEvent event, Emitter<MarketFeedState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: state.tickIntervalMs), (_) {
      add(GenerateNextTickEvent());
    });
  }

  void _onStopFeed(StopMarketFeedEvent event, Emitter<MarketFeedState> emit) {
    _timer?.cancel();
    _timer = null;
  }

  void _onSetTickInterval(SetTickIntervalEvent event, Emitter<MarketFeedState> emit) {
    final newInterval = event.intervalMs.clamp(10, 5000);
    final isStress = newInterval <= 50;
    emit(state.copyWith(tickIntervalMs: newInterval, isStressMode: isStress));
    add(StartMarketFeedEvent());
  }

  void _onToggleStressMode(ToggleStressModeEvent event, Emitter<MarketFeedState> emit) {
    final newInterval = event.enable ? 20 : 500; // 20ms = 50+ ticks/sec
    emit(state.copyWith(isStressMode: event.enable, tickIntervalMs: newInterval));
    add(StartMarketFeedEvent());
  }

  void _onGenerateNextTick(GenerateNextTickEvent event, Emitter<MarketFeedState> emit) {
    if (state.quotes.isEmpty) return;

    final updatedQuotes = Map<String, StockQuote>.from(state.quotes);
    StockQuote? lastTicked;

    if (state.isStressMode) {
      final count = _random.nextInt(3) + 2;
      for (int i = 0; i < count; i++) {
        lastTicked = _tickRandomStockInMap(updatedQuotes);
      }
    } else {
      lastTicked = _tickRandomStockInMap(updatedQuotes);
    }

    emit(state.copyWith(
      quotes: updatedQuotes,
      totalTicksCount: state.totalTicksCount + 1,
      lastTickedQuote: lastTicked,
    ));
  }

  StockQuote _tickRandomStockInMap(Map<String, StockQuote> quotesMap) {
    final symbols = quotesMap.keys.toList();
    final symbol = symbols[_random.nextInt(symbols.length)];
    final currentQuote = quotesMap[symbol]!;

    final percentChange = (_random.nextDouble() * 0.6 - 0.3) / 100;
    double newPrice = currentQuote.ltp * (1 + percentChange);

    if ((newPrice - currentQuote.ltp).abs() < 0.05) {
      final delta = (_random.nextBool() ? 0.25 : -0.25);
      newPrice += delta;
    }

    if (newPrice < 1.0) newPrice = 1.0;

    final updated = currentQuote.updatePrice(newPrice);
    quotesMap[symbol] = updated;
    return updated;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
