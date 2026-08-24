import 'package:decimal/decimal.dart';

class InitialStockInfo {
  final String symbol;
  final String name;
  final Decimal initialPrice;

  const InitialStockInfo({
    required this.symbol,
    required this.name,
    required this.initialPrice,
  });
}

class StockConstants {
  static final List<InitialStockInfo> supportedStocks = [
    InitialStockInfo(
      symbol: 'RELIANCE',
      name: 'Reliance Industries Ltd.',
      initialPrice: Decimal.parse('2950.50'),
    ),
    InitialStockInfo(
      symbol: 'TCS',
      name: 'Tata Consultancy Services',
      initialPrice: Decimal.parse('4120.00'),
    ),
    InitialStockInfo(
      symbol: 'INFY',
      name: 'Infosys Ltd.',
      initialPrice: Decimal.parse('1850.25'),
    ),
    InitialStockInfo(
      symbol: 'HDFCBANK',
      name: 'HDFC Bank Ltd.',
      initialPrice: Decimal.parse('1620.00'),
    ),
    InitialStockInfo(
      symbol: 'ICICIBANK',
      name: 'ICICI Bank Ltd.',
      initialPrice: Decimal.parse('1180.75'),
    ),
    InitialStockInfo(
      symbol: 'SBIN',
      name: 'State Bank of India',
      initialPrice: Decimal.parse('840.50'),
    ),
    InitialStockInfo(
      symbol: 'ITC',
      name: 'ITC Ltd.',
      initialPrice: Decimal.parse('490.00'),
    ),
    InitialStockInfo(
      symbol: 'LT',
      name: 'Larsen & Toubro Ltd.',
      initialPrice: Decimal.parse('3650.00'),
    ),
    InitialStockInfo(
      symbol: 'BHARTIARTL',
      name: 'Bharti Airtel Ltd.',
      initialPrice: Decimal.parse('1475.25'),
    ),
    InitialStockInfo(
      symbol: 'AXISBANK',
      name: 'Axis Bank Ltd.',
      initialPrice: Decimal.parse('1170.00'),
    ),
  ];

  static const String keyWatchlists = 'key_watchlists_v2';
  static const String keyHoldings = 'key_holdings_v2';
  static const String keyWalletBalance = 'key_wallet_balance_v2';
  static const String keyOrders = 'key_orders_v2';

  static final Decimal defaultWalletBalance = Decimal.parse('1000000.00'); // ₹10,00,000.00
}
