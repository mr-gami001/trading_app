import 'package:equatable/equatable.dart';
import '../../models/holding.dart';
import '../../models/trade_order.dart';
import '../../models/stock_quote.dart';

enum HoldingSortOption {
  pnlDesc,
  pnlAsc,
  symbolAsc,
  currentValueDesc,
}

class PortfolioState extends Equatable {
  final double walletBalance;
  final List<Holding> holdings;
  final List<TradeOrder> orders;
  final HoldingSortOption sortOption;
  final bool isLoading;

  const PortfolioState({
    this.walletBalance = 100000.00,
    this.holdings = const [],
    this.orders = const [],
    this.sortOption = HoldingSortOption.pnlDesc,
    this.isLoading = true,
  });

  Holding? getHoldingForSymbol(String symbol) {
    try {
      return holdings.firstWhere((h) => h.symbol == symbol);
    } catch (_) {
      return null;
    }
  }

  List<Holding> getSortedHoldings(Map<String, StockQuote> quotes) {
    final list = List<Holding>.from(holdings);
    list.sort((a, b) {
      final aQuote = quotes[a.symbol];
      final bQuote = quotes[b.symbol];
      final aLtp = aQuote?.ltp ?? a.avgCost;
      final bLtp = bQuote?.ltp ?? b.avgCost;

      switch (sortOption) {
        case HoldingSortOption.pnlDesc:
          return b.pnl(bLtp).compareTo(a.pnl(aLtp));
        case HoldingSortOption.pnlAsc:
          return a.pnl(aLtp).compareTo(b.pnl(bLtp));
        case HoldingSortOption.symbolAsc:
          return a.symbol.compareTo(b.symbol);
        case HoldingSortOption.currentValueDesc:
          return b.currentValue(bLtp).compareTo(a.currentValue(aLtp));
      }
    });
    return list;
  }

  double getTotalInvested() {
    double total = 0.0;
    for (final h in holdings) {
      total += h.investedValue;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double getTotalCurrentValue(Map<String, StockQuote> quotes) {
    double total = 0.0;
    for (final h in holdings) {
      final ltp = quotes[h.symbol]?.ltp ?? h.avgCost;
      total += h.currentValue(ltp);
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double getTotalPnl(Map<String, StockQuote> quotes) {
    return double.parse((getTotalCurrentValue(quotes) - getTotalInvested()).toStringAsFixed(2));
  }

  double getTotalPnlPercent(Map<String, StockQuote> quotes) {
    final invested = getTotalInvested();
    if (invested == 0) return 0.0;
    return double.parse(((getTotalPnl(quotes) / invested) * 100).toStringAsFixed(2));
  }

  PortfolioState copyWith({
    double? walletBalance,
    List<Holding>? holdings,
    List<TradeOrder>? orders,
    HoldingSortOption? sortOption,
    bool? isLoading,
  }) {
    return PortfolioState(
      walletBalance: walletBalance ?? this.walletBalance,
      holdings: holdings ?? this.holdings,
      orders: orders ?? this.orders,
      sortOption: sortOption ?? this.sortOption,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        walletBalance,
        holdings,
        orders,
        sortOption,
        isLoading,
      ];
}
