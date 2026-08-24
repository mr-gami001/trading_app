import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:rational/rational.dart';

class DecimalUtils {
  static final NumberFormat _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format Decimal to Indian Rupee String (e.g. ₹1,23,456.78)
  static String formatCurrency(Decimal amount, {bool showSymbol = true}) {
    final double val = amount.toDouble();
    final String formatted = _inrFormatter.format(val);
    if (!showSymbol) {
      return formatted.replaceAll('₹', '').trim();
    }
    return formatted;
  }

  /// Format price change and percentage e.g. +25.50 (+0.85%)
  static String formatPriceChange(Decimal change, Decimal changePercent) {
    final double changeVal = change.toDouble();
    final double changePctVal = changePercent.toDouble();
    final String sign = changeVal > 0 ? '+' : '';
    return '$sign${changeVal.toStringAsFixed(2)} ($sign${changePctVal.toStringAsFixed(2)}%)';
  }

  /// Calculate weighted average cost on Buy order:
  /// (oldQty * oldAvg + newQty * buyPrice) / (oldQty + newQty)
  static Decimal calculateWeightedAvgCost({
    required Decimal oldQty,
    required Decimal oldAvgCost,
    required Decimal newQty,
    required Decimal buyPrice,
  }) {
    final totalQty = oldQty + newQty;
    if (totalQty == Decimal.zero) return Decimal.zero;
    final totalSpent = (oldQty * oldAvgCost) + (newQty * buyPrice);
    return (totalSpent / totalQty).toDecimal(scaleOnInfinitePrecision: 4);
  }

  /// Calculate Current Value: quantity * LTP
  static Decimal calculateCurrentValue(Decimal quantity, Decimal ltp) {
    return quantity * ltp;
  }

  /// Calculate Invested Value: quantity * averageCost
  static Decimal calculateInvestedValue(Decimal quantity, Decimal avgCost) {
    return quantity * avgCost;
  }

  /// Calculate P&L: Current Value - Invested Value
  static Decimal calculatePnl(Decimal quantity, Decimal avgCost, Decimal ltp) {
    return calculateCurrentValue(quantity, ltp) - calculateInvestedValue(quantity, avgCost);
  }

  /// Calculate P&L %: (P&L / Invested Value) * 100
  static Decimal calculatePnlPercent(Decimal quantity, Decimal avgCost, Decimal ltp) {
    final invested = calculateInvestedValue(quantity, avgCost);
    if (invested == Decimal.zero) return Decimal.zero;
    final pnl = calculatePnl(quantity, avgCost, ltp);
    return ((pnl / invested) * Rational.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 4);
  }

  /// Format date time cleanly
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm:ss a').format(dateTime);
  }
}
