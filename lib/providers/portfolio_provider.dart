import 'package:flutter/foundation.dart';
import '../models/holding.dart';
import '../models/trade_order.dart';
import '../models/stock_quote.dart';
import '../services/storage_service.dart';

enum HoldingSortOption {
  pnlDesc,
  pnlAsc,
  symbolAsc,
  currentValueDesc,
}

class PortfolioProvider extends ChangeNotifier {
  double _walletBalance = 100000.00; // Default ₹1,00,000 starting cash
  List<Holding> _holdings = [];
  List<TradeOrder> _orders = [];
  HoldingSortOption _sortOption = HoldingSortOption.pnlDesc;
  bool _isLoading = true;

  double get walletBalance => _walletBalance;
  List<Holding> get holdings => _holdings;
  List<TradeOrder> get orders => _orders;
  HoldingSortOption get sortOption => _sortOption;
  bool get isLoading => _isLoading;

  PortfolioProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final savedBalance = await StorageService.loadWalletBalance();
    if (savedBalance != null) {
      _walletBalance = savedBalance;
    }

    final savedHoldings = await StorageService.loadHoldings();
    if (savedHoldings != null) {
      _holdings = savedHoldings;
    } else {
      // Default initial mock holdings to get immediate P&L visualization if user opens app
      _holdings = [
        const Holding(symbol: 'RELIANCE', quantity: 10, avgCost: 2850.00),
        const Holding(symbol: 'TCS', quantity: 5, avgCost: 4000.00),
        const Holding(symbol: 'INFY', quantity: 20, avgCost: 1900.00),
      ];
      await StorageService.saveHoldings(_holdings);
      await StorageService.saveWalletBalance(_walletBalance);
    }

    final savedOrders = await StorageService.loadOrders();
    if (savedOrders != null) {
      _orders = savedOrders;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSortOption(HoldingSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  List<Holding> getSortedHoldings(Map<String, StockQuote> quotes) {
    final list = List<Holding>.from(_holdings);
    list.sort((a, b) {
      final aQuote = quotes[a.symbol];
      final bQuote = quotes[b.symbol];
      final aLtp = aQuote?.ltp ?? a.avgCost;
      final bLtp = bQuote?.ltp ?? b.avgCost;

      switch (_sortOption) {
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

  Holding? getHoldingForSymbol(String symbol) {
    try {
      return _holdings.firstWhere((h) => h.symbol == symbol);
    } catch (_) {
      return null;
    }
  }

  // Portfolio Totals
  double getTotalInvested() {
    double total = 0.0;
    for (final h in _holdings) {
      total += h.investedValue;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double getTotalCurrentValue(Map<String, StockQuote> quotes) {
    double total = 0.0;
    for (final h in _holdings) {
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

  // Place Order Method
  Future<String?> placeOrder({
    required String symbol,
    required OrderSide side,
    required int quantity,
    required double ltp,
  }) async {
    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }

    final double totalOrderValue = double.parse((quantity * ltp).toStringAsFixed(2));

    if (side == OrderSide.buy) {
      if (_walletBalance < totalOrderValue) {
        return 'Insufficient wallet balance. Required: ₹${totalOrderValue.toStringAsFixed(2)}, Available: ₹${_walletBalance.toStringAsFixed(2)}';
      }

      // Execute Buy
      _walletBalance -= totalOrderValue;
      _walletBalance = double.parse(_walletBalance.toStringAsFixed(2));

      final existingIndex = _holdings.indexWhere((h) => h.symbol == symbol);
      if (existingIndex != -1) {
        final oldHolding = _holdings[existingIndex];
        final newQty = oldHolding.quantity + quantity;
        final double newAvgCost = double.parse(
          (((oldHolding.quantity * oldHolding.avgCost) + totalOrderValue) / newQty).toStringAsFixed(2),
        );
        _holdings[existingIndex] = Holding(
          symbol: symbol,
          quantity: newQty,
          avgCost: newAvgCost,
        );
      } else {
        _holdings.add(Holding(
          symbol: symbol,
          quantity: quantity,
          avgCost: double.parse(ltp.toStringAsFixed(2)),
        ));
      }
    } else {
      // Execute Sell
      final existingIndex = _holdings.indexWhere((h) => h.symbol == symbol);
      if (existingIndex == -1) {
        return 'You do not hold any shares of $symbol';
      }
      final existingHolding = _holdings[existingIndex];
      if (existingHolding.quantity < quantity) {
        return 'Cannot sell $quantity shares. You only hold ${existingHolding.quantity} shares of $symbol';
      }

      _walletBalance += totalOrderValue;
      _walletBalance = double.parse(_walletBalance.toStringAsFixed(2));

      final newQty = existingHolding.quantity - quantity;
      if (newQty == 0) {
        _holdings.removeAt(existingIndex);
      } else {
        _holdings[existingIndex] = existingHolding.copyWith(quantity: newQty);
      }
    }

    // Record Order
    final order = TradeOrder(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      symbol: symbol,
      side: side,
      quantity: quantity,
      executionPrice: ltp,
      totalValue: totalOrderValue,
      timestamp: DateTime.now(),
    );
    _orders.insert(0, order);

    notifyListeners();
    await _persist();
    return null; // Null indicates success
  }

  Future<void> resetWalletBalance([double newBalance = 100000.00]) async {
    _walletBalance = newBalance;
    notifyListeners();
    await StorageService.saveWalletBalance(_walletBalance);
  }

  Future<void> _persist() async {
    await StorageService.saveWalletBalance(_walletBalance);
    await StorageService.saveHoldings(_holdings);
    await StorageService.saveOrders(_orders);
  }
}
