import 'package:equatable/equatable.dart';
import '../../../domain/entities/stock_quote.dart';

class MarketState extends Equatable {
  final Map<String, StockQuote> quotes;
  final int tickIntervalMs;
  final bool isStressMode;
  final int totalTicksCount;
  final String? lastTickedSymbol;

  const MarketState({
    required this.quotes,
    this.tickIntervalMs = 500,
    this.isStressMode = false,
    this.totalTicksCount = 0,
    this.lastTickedSymbol,
  });

  MarketState copyWith({
    Map<String, StockQuote>? quotes,
    int? tickIntervalMs,
    bool? isStressMode,
    int? totalTicksCount,
    String? lastTickedSymbol,
  }) {
    return MarketState(
      quotes: quotes ?? this.quotes,
      tickIntervalMs: tickIntervalMs ?? this.tickIntervalMs,
      isStressMode: isStressMode ?? this.isStressMode,
      totalTicksCount: totalTicksCount ?? this.totalTicksCount,
      lastTickedSymbol: lastTickedSymbol ?? this.lastTickedSymbol,
    );
  }

  @override
  List<Object?> get props => [
        quotes,
        tickIntervalMs,
        isStressMode,
        totalTicksCount,
        lastTickedSymbol,
      ];
}
