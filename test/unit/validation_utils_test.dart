import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/utils/validation_utils.dart';

void main() {
  group('ValidationUtils Tests', () {
    test('validateOrderQuantity rejects invalid, zero, and negative inputs', () {
      expect(ValidationUtils.validateOrderQuantity('').isValid, isFalse);
      expect(ValidationUtils.validateOrderQuantity('abc').isValid, isFalse);
      expect(ValidationUtils.validateOrderQuantity('0').isValid, isFalse);
      expect(ValidationUtils.validateOrderQuantity('-5').isValid, isFalse);
      expect(ValidationUtils.validateOrderQuantity('10').isValid, isTrue);
    });

    test('validateBuyOrder fails when wallet balance is insufficient', () {
      final balance = Decimal.parse('5000.00');
      final orderVal = Decimal.parse('10000.00');

      final result = ValidationUtils.validateBuyOrder(
        walletBalance: balance,
        orderValue: orderVal,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Insufficient margin balance'));
    });

    test('validateSellOrder fails when selling more shares than held', () {
      final result = ValidationUtils.validateSellOrder(
        heldQuantity: 5,
        sellQuantity: 10,
        symbol: 'TCS',
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Cannot sell 10 shares'));
    });
  });
}
