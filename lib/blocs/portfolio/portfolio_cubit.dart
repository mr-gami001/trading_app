import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/holding.dart';
import '../../models/trade_order.dart';
import '../../services/storage_service.dart';
import 'portfolio_state.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  PortfolioCubit() : super(const PortfolioState()) {
    init();
  }

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    double balance = 100000.00;
    final savedBalance = await StorageService.loadWalletBalance();
    if (savedBalance != null) {
      balance = savedBalance;
    }

    List<Holding> holdingsList = [];
    final savedHoldings = await StorageService.loadHoldings();
    if (savedHoldings != null) {
      holdingsList = savedHoldings;
    } else {
      holdingsList = [
        const Holding(symbol: 'RELIANCE', quantity: 10, avgCost: 2850.00),
        const Holding(symbol: 'TCS', quantity: 5, avgCost: 4000.00),
        const Holding(symbol: 'INFY', quantity: 20, avgCost: 1900.00),
      ];
      await StorageService.saveHoldings(holdingsList);
      await StorageService.saveWalletBalance(balance);
    }

    List<TradeOrder> ordersList = [];
    final savedOrders = await StorageService.loadOrders();
    if (savedOrders != null) {
      ordersList = savedOrders;
    }

    emit(state.copyWith(
      walletBalance: balance,
      holdings: holdingsList,
      orders: ordersList,
      isLoading: false,
    ));
  }

  void setSortOption(HoldingSortOption option) {
    emit(state.copyWith(sortOption: option));
  }

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
    double currentBalance = state.walletBalance;
    final holdingsList = List<Holding>.from(state.holdings);
    final ordersList = List<TradeOrder>.from(state.orders);

    if (side == OrderSide.buy) {
      if (currentBalance < totalOrderValue) {
        return 'Insufficient wallet balance. Required: ₹${totalOrderValue.toStringAsFixed(2)}, Available: ₹${currentBalance.toStringAsFixed(2)}';
      }

      currentBalance -= totalOrderValue;
      currentBalance = double.parse(currentBalance.toStringAsFixed(2));

      final existingIndex = holdingsList.indexWhere((h) => h.symbol == symbol);
      if (existingIndex != -1) {
        final oldHolding = holdingsList[existingIndex];
        final newQty = oldHolding.quantity + quantity;
        final double newAvgCost = double.parse(
          (((oldHolding.quantity * oldHolding.avgCost) + totalOrderValue) / newQty).toStringAsFixed(2),
        );
        holdingsList[existingIndex] = Holding(
          symbol: symbol,
          quantity: newQty,
          avgCost: newAvgCost,
        );
      } else {
        holdingsList.add(Holding(
          symbol: symbol,
          quantity: quantity,
          avgCost: double.parse(ltp.toStringAsFixed(2)),
        ));
      }
    } else {
      final existingIndex = holdingsList.indexWhere((h) => h.symbol == symbol);
      if (existingIndex == -1) {
        return 'You do not hold any shares of $symbol';
      }
      final existingHolding = holdingsList[existingIndex];
      if (existingHolding.quantity < quantity) {
        return 'Cannot sell $quantity shares. You only hold ${existingHolding.quantity} shares of $symbol';
      }

      currentBalance += totalOrderValue;
      currentBalance = double.parse(currentBalance.toStringAsFixed(2));

      final newQty = existingHolding.quantity - quantity;
      if (newQty == 0) {
        holdingsList.removeAt(existingIndex);
      } else {
        holdingsList[existingIndex] = existingHolding.copyWith(quantity: newQty);
      }
    }

    final order = TradeOrder(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      symbol: symbol,
      side: side,
      quantity: quantity,
      executionPrice: ltp,
      totalValue: totalOrderValue,
      timestamp: DateTime.now(),
    );
    ordersList.insert(0, order);

    emit(state.copyWith(
      walletBalance: currentBalance,
      holdings: holdingsList,
      orders: ordersList,
    ));

    await _persist(currentBalance, holdingsList, ordersList);
    return null;
  }

  Future<void> resetWalletBalance([double newBalance = 100000.00]) async {
    emit(state.copyWith(walletBalance: newBalance));
    await StorageService.saveWalletBalance(newBalance);
  }

  Future<void> _persist(double balance, List<Holding> holdings, List<TradeOrder> orders) async {
    await StorageService.saveWalletBalance(balance);
    await StorageService.saveHoldings(holdings);
    await StorageService.saveOrders(orders);
  }
}
