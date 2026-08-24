import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:rational/rational.dart';

class StockQuote extends Equatable {
  final String symbol;
  final String name;
  final Decimal ltp;
  final Decimal previousClose;
  final Decimal change;
  final Decimal changePercent;
  final bool? isUp;
  final DateTime lastUpdated;
  final Decimal initialPrice;

  const StockQuote({
    required this.symbol,
    required this.name,
    required this.ltp,
    required this.previousClose,
    required this.change,
    required this.changePercent,
    this.isUp,
    required this.lastUpdated,
    required this.initialPrice,
  });

  factory StockQuote.initial({
    required String symbol,
    required String name,
    required Decimal initialPrice,
  }) {
    return StockQuote(
      symbol: symbol,
      name: name,
      ltp: initialPrice,
      previousClose: initialPrice,
      change: Decimal.zero,
      changePercent: Decimal.zero,
      isUp: null,
      lastUpdated: DateTime.now(),
      initialPrice: initialPrice,
    );
  }

  StockQuote updatePrice(Decimal newLtp) {
    final Decimal newChange = newLtp - previousClose;
    Decimal newChangePct = Decimal.zero;
    if (previousClose > Decimal.zero) {
      newChangePct = ((newChange / previousClose) * Rational.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 4);
    }

    bool? direction;
    if (newLtp > ltp) {
      direction = true;
    } else if (newLtp < ltp) {
      direction = false;
    } else {
      direction = isUp;
    }

    return StockQuote(
      symbol: symbol,
      name: name,
      ltp: newLtp,
      previousClose: previousClose,
      change: newChange,
      changePercent: newChangePct,
      isUp: direction,
      lastUpdated: DateTime.now(),
      initialPrice: initialPrice,
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        name,
        ltp,
        previousClose,
        change,
        changePercent,
        isUp,
        lastUpdated,
        initialPrice,
      ];
}
