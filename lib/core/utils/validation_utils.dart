import 'package:decimal/decimal.dart';
import 'decimal_utils.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.success()
      : isValid = true,
        errorMessage = null;

  const ValidationResult.failure(this.errorMessage) : isValid = false;
}

class ValidationUtils {
  static ValidationResult validateOrderQuantity(String rawInput) {
    if (rawInput.trim().isEmpty) {
      return const ValidationResult.failure('Quantity is required');
    }
    final intVal = int.tryParse(rawInput.trim());
    if (intVal == null) {
      return const ValidationResult.failure('Quantity must be a valid whole integer number');
    }
    if (intVal <= 0) {
      return const ValidationResult.failure('Quantity must be greater than zero');
    }
    if (intVal > 1000000) {
      return const ValidationResult.failure('Quantity exceeds maximum allowed limit (1,00,000)');
    }
    return const ValidationResult.success();
  }

  static ValidationResult validateBuyOrder({
    required Decimal walletBalance,
    required Decimal orderValue,
  }) {
    if (walletBalance < orderValue) {
      return ValidationResult.failure(
        'Insufficient margin balance. Required: ${DecimalUtils.formatCurrency(orderValue)}, Available: ${DecimalUtils.formatCurrency(walletBalance)}',
      );
    }
    return const ValidationResult.success();
  }

  static ValidationResult validateSellOrder({
    required int heldQuantity,
    required int sellQuantity,
    required String symbol,
  }) {
    if (heldQuantity <= 0) {
      return ValidationResult.failure('You do not hold any shares of $symbol');
    }
    if (sellQuantity > heldQuantity) {
      return ValidationResult.failure(
        'Cannot sell $sellQuantity shares. You only hold $heldQuantity shares of $symbol',
      );
    }
    return const ValidationResult.success();
  }
}
