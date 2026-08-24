import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:rational/rational.dart';
import '../../entities/holding.dart';
import '../../entities/stock_quote.dart';

class PortfolioSummary extends Equatable {
  final Decimal totalInvested;
  final Decimal totalCurrentValue;
  final Decimal totalPnl;
  final Decimal totalPnlPercent;

  const PortfolioSummary({
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.totalPnl,
    required this.totalPnlPercent,
  });

  @override
  List<Object?> get props => [
        totalInvested,
        totalCurrentValue,
        totalPnl,
        totalPnlPercent,
      ];
}

class GetPortfolioSummaryUseCase {
  PortfolioSummary execute({
    required List<Holding> holdings,
    required Map<String, StockQuote> quotes,
  }) {
    Decimal invested = Decimal.zero;
    Decimal currentValue = Decimal.zero;

    for (final holding in holdings) {
      invested += holding.investedValue;
      final quote = quotes[holding.symbol];
      final ltp = quote?.ltp ?? holding.avgCost;
      currentValue += holding.currentValue(ltp);
    }

    final pnl = currentValue - invested;
    Decimal pnlPct = Decimal.zero;

    if (invested > Decimal.zero) {
      pnlPct = ((pnl / invested) * Rational.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 4);
    }

    return PortfolioSummary(
      totalInvested: invested,
      totalCurrentValue: currentValue,
      totalPnl: pnl,
      totalPnlPercent: pnlPct,
    );
  }
}
