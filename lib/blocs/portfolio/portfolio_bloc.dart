import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/holding.dart';
import '../../models/trade_order.dart';
import '../../services/storage_service.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  PortfolioBloc() : super(const PortfolioState()) {
    on<InitPortfolioEvent>(_onInit);
    on<SetHoldingSortOptionEvent>(_onSetSortOption);
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<ResetWalletBalanceEvent>(_onResetWalletBalance);

    add(InitPortfolioEvent());
  }

  Future<void> _onInit(InitPortfolioEvent event, Emitter<PortfolioState> emit) async {
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

  void _onSetSortOption(SetHoldingSortOptionEvent event, Emitter<PortfolioState> emit) {
    emit(state.copyWith(sortOption: event.option));
  }

  Future<void> _onPlaceOrder(PlaceOrderEvent event, Emitter<PortfolioState> emit) async {
    if (event.quantity <= 0) {
      event.completer?.complete('Quantity must be greater than 0');
      return;
    }

    final double totalOrderValue = double.parse((event.quantity * event.ltp).toStringAsFixed(2));
    double currentBalance = state.walletBalance;
    final holdingsList = List<Holding>.from(state.holdings);
    final ordersList = List<TradeOrder>.from(state.orders);

    if (event.side == OrderSide.buy) {
      if (currentBalance < totalOrderValue) {
        event.completer?.complete(
          'Insufficient wallet balance. Required: ₹${totalOrderValue.toStringAsFixed(2)}, Available: ₹${currentBalance.toStringAsFixed(2)}',
        );
        return;
      }

      currentBalance -= totalOrderValue;
      currentBalance = double.parse(currentBalance.toStringAsFixed(2));

      final existingIndex = holdingsList.indexWhere((h) => h.symbol == event.symbol);
      if (existingIndex != -1) {
        final oldHolding = holdingsList[existingIndex];
        final newQty = oldHolding.quantity + event.quantity;
        final double newAvgCost = double.parse(
          (((oldHolding.quantity * oldHolding.avgCost) + totalOrderValue) / newQty).toStringAsFixed(2),
        );
        holdingsList[existingIndex] = Holding(
          symbol: event.symbol,
          quantity: newQty,
          avgCost: newAvgCost,
        );
      } else {
        holdingsList.add(Holding(
          symbol: event.symbol,
          quantity: event.quantity,
          avgCost: double.parse(event.ltp.toStringAsFixed(2)),
        ));
      }
    } else {
      final existingIndex = holdingsList.indexWhere((h) => h.symbol == event.symbol);
      if (existingIndex == -1) {
        event.completer?.complete('You do not hold any shares of ${event.symbol}');
        return;
      }
      final existingHolding = holdingsList[existingIndex];
      if (existingHolding.quantity < event.quantity) {
        event.completer?.complete(
          'Cannot sell ${event.quantity} shares. You only hold ${existingHolding.quantity} shares of ${event.symbol}',
        );
        return;
      }

      currentBalance += totalOrderValue;
      currentBalance = double.parse(currentBalance.toStringAsFixed(2));

      final newQty = existingHolding.quantity - event.quantity;
      if (newQty == 0) {
        holdingsList.removeAt(existingIndex);
      } else {
        holdingsList[existingIndex] = existingHolding.copyWith(quantity: newQty);
      }
    }

    final order = TradeOrder(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      symbol: event.symbol,
      side: event.side,
      quantity: event.quantity,
      executionPrice: event.ltp,
      totalValue: totalOrderValue,
      timestamp: DateTime.now(),
    );
    ordersList.insert(0, order);

    emit(state.copyWith(
      walletBalance: currentBalance,
      holdings: holdingsList,
      orders: ordersList,
    ));

    await StorageService.saveWalletBalance(currentBalance);
    await StorageService.saveHoldings(holdingsList);
    await StorageService.saveOrders(ordersList);

    event.completer?.complete(null); // Success
  }

  Future<void> _onResetWalletBalance(ResetWalletBalanceEvent event, Emitter<PortfolioState> emit) async {
    emit(state.copyWith(walletBalance: event.newBalance));
    await StorageService.saveWalletBalance(event.newBalance);
  }
}
