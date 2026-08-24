import 'package:equatable/equatable.dart';
import '../../models/stock_quote.dart';

class MarketFeedState extends Equatable {
  final Map<String, StockQuote> quotes;
  final int tickIntervalMs;
  final bool isStressMode;
  final int totalTicksCount;
  final StockQuote? lastTickedQuote;

  const MarketFeedState({
    required this.quotes,
    this.tickIntervalMs = 500,
    this.isStressMode = false,
    this.totalTicksCount = 0,
    this.lastTickedQuote,
  });

  MarketFeedState copyWith({
    Map<String, StockQuote>? quotes,
    int? tickIntervalMs,
    bool? isStressMode,
    int? totalTicksCount,
    StockQuote? lastTickedQuote,
  }) {
    return MarketFeedState(
      quotes: quotes ?? this.quotes,
      tickIntervalMs: tickIntervalMs ?? this.tickIntervalMs,
      isStressMode: isStressMode ?? this.isStressMode,
      totalTicksCount: totalTicksCount ?? this.totalTicksCount,
      lastTickedQuote: lastTickedQuote ?? this.lastTickedQuote,
    );
  }

  @override
  List<Object?> get props => [
        quotes,
        tickIntervalMs,
        isStressMode,
        totalTicksCount,
        lastTickedQuote,
      ];
}
