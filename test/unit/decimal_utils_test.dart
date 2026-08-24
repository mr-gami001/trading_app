import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/utils/decimal_utils.dart';

void main() {
  group('DecimalUtils Financial Math Tests', () {
    test('calculateWeightedAvgCost calculates correct average cost', () {
      // 10 shares @ ₹2850.00 + 5 shares @ ₹3000.00
      // Total spent = 28500 + 15000 = 43500. Total qty = 15. Avg = 43500 / 15 = 2900.00
      final result = DecimalUtils.calculateWeightedAvgCost(
        oldQty: Decimal.fromInt(10),
        oldAvgCost: Decimal.parse('2850.00'),
        newQty: Decimal.fromInt(5),
        buyPrice: Decimal.parse('3000.00'),
      );

      expect(result, equals(Decimal.parse('2900.00')));
    });

    test('calculatePnl and calculatePnlPercent match expectations', () {
      // 10 shares @ ₹100.00 avg cost, LTP = ₹150.00
      // Invested = 1000, Current = 1500, P&L = 500 (+50%)
      final qty = Decimal.fromInt(10);
      final avg = Decimal.parse('100.00');
      final ltp = Decimal.parse('150.00');

      final currentValue = DecimalUtils.calculateCurrentValue(qty, ltp);
      final pnl = DecimalUtils.calculatePnl(qty, avg, ltp);
      final pnlPct = DecimalUtils.calculatePnlPercent(qty, avg, ltp);

      expect(currentValue, equals(Decimal.parse('1500.00')));
      expect(pnl, equals(Decimal.parse('500.00')));
      expect(pnlPct.toDouble(), equals(50.0));
    });

    test('formatCurrency formats Indian Rupee correctly', () {
      final formatted = DecimalUtils.formatCurrency(Decimal.parse('123456.78'));
      expect(formatted, contains('1,23,456.78'));
    });
  });
}
