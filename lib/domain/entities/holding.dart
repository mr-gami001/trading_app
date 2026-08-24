import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import '../../core/utils/decimal_utils.dart';

class Holding extends Equatable {
  final String symbol;
  final int quantity;
  final Decimal avgCost;

  const Holding({
    required this.symbol,
    required this.quantity,
    required this.avgCost,
  });

  Decimal get quantityDecimal => Decimal.fromInt(quantity);

  Decimal get investedValue => DecimalUtils.calculateInvestedValue(quantityDecimal, avgCost);

  Decimal currentValue(Decimal ltp) => DecimalUtils.calculateCurrentValue(quantityDecimal, ltp);

  Decimal pnl(Decimal ltp) => DecimalUtils.calculatePnl(quantityDecimal, avgCost, ltp);

  Decimal pnlPercent(Decimal ltp) => DecimalUtils.calculatePnlPercent(quantityDecimal, avgCost, ltp);

  Holding copyWith({
    String? symbol,
    int? quantity,
    Decimal? avgCost,
  }) {
    return Holding(
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      avgCost: avgCost ?? this.avgCost,
    );
  }

  @override
  List<Object?> get props => [symbol, quantity, avgCost];
}
