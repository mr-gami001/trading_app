import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../domain/entities/holding.dart';
import '../../../domain/entities/stock_quote.dart';
import '../../../domain/entities/trade_order.dart';

enum HoldingSortOption {
  pnlDesc,
  pnlAsc,
  symbolAsc,
  currentValueDesc,
}

class HoldingsState extends Equatable {
  final Decimal walletBalance;
  final List<Holding> holdings;
  final List<TradeOrder> orders;
  final HoldingSortOption sortOption;
  final bool isLoading;
  final String? errorMessage;

  HoldingsState({
    Decimal? walletBalance,
    this.holdings = const [],
    this.orders = const [],
    this.sortOption = HoldingSortOption.pnlDesc,
    this.isLoading = true,
    this.errorMessage,
  }) : walletBalance = walletBalance ?? StockConstants.defaultWalletBalance;

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

  HoldingsState copyWith({
    Decimal? walletBalance,
    List<Holding>? holdings,
    List<TradeOrder>? orders,
    HoldingSortOption? sortOption,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HoldingsState(
      walletBalance: walletBalance ?? this.walletBalance,
      holdings: holdings ?? this.holdings,
      orders: orders ?? this.orders,
      sortOption: sortOption ?? this.sortOption,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        walletBalance,
        holdings,
        orders,
        sortOption,
        isLoading,
        errorMessage,
      ];
}
