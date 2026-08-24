import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrency = NumberFormat.compactSimpleCurrency(
    locale: 'en_IN',
    name: 'INR',
  );

  static String currency(double value, {bool showSymbol = true}) {
    final String formatted = _currencyFormatter.format(value);
    if (!showSymbol) {
      return formatted.replaceAll('₹', '').trim();
    }
    return formatted;
  }

  static String compactCurrency(double value) {
    return _compactCurrency.format(value);
  }

  static String priceChange(double change, double changePct) {
    final String sign = change > 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(2)} ($sign${changePct.toStringAsFixed(2)}%)';
  }

  static String dateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm:ss a').format(dt);
  }
}
