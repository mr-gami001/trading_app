import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/decimal_utils.dart';
import '../../../core/utils/validation_utils.dart';
import '../../entities/holding.dart';
import '../../entities/trade_order.dart';
import '../../repositories/portfolio_repository.dart';

class PlaceOrderParams {
  final String symbol;
  final OrderSide side;
  final int quantity;
  final Decimal executionLtp;

  const PlaceOrderParams({
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.executionLtp,
  });
}

class PlaceOrderUseCase {
  final PortfolioRepository repository;
  final Uuid _uuid = const Uuid();

  PlaceOrderUseCase({required this.repository});

  Future<Failure?> execute(PlaceOrderParams params) async {
    // 1. Quantity validation
    final qtyVal = ValidationUtils.validateOrderQuantity(params.quantity.toString());
    if (!qtyVal.isValid) {
      return ValidationFailure(qtyVal.errorMessage!);
    }

    final int quantity = params.quantity;
    final Decimal qtyDecimal = Decimal.fromInt(quantity);
    final Decimal orderValue = qtyDecimal * params.executionLtp;

    Decimal balance = await repository.getWalletBalance();
    final holdings = List<Holding>.from(await repository.getHoldings());
    final orders = List<TradeOrder>.from(await repository.getOrders());

    if (params.side == OrderSide.buy) {
      // 2. Buy Balance Validation
      final buyVal = ValidationUtils.validateBuyOrder(
        walletBalance: balance,
        orderValue: orderValue,
      );
      if (!buyVal.isValid) {
        return InsufficientBalanceFailure(buyVal.errorMessage!);
      }

      // Execute Buy
      balance = balance - orderValue;

      final existingIndex = holdings.indexWhere((h) => h.symbol == params.symbol);
      if (existingIndex != -1) {
        final oldHolding = holdings[existingIndex];
        final newAvgCost = DecimalUtils.calculateWeightedAvgCost(
          oldQty: oldHolding.quantityDecimal,
          oldAvgCost: oldHolding.avgCost,
          newQty: qtyDecimal,
          buyPrice: params.executionLtp,
        );
        holdings[existingIndex] = Holding(
          symbol: params.symbol,
          quantity: oldHolding.quantity + quantity,
          avgCost: newAvgCost,
        );
      } else {
        holdings.add(Holding(
          symbol: params.symbol,
          quantity: quantity,
          avgCost: params.executionLtp,
        ));
      }
    } else {
      // 3. Sell Quantity Validation
      final existingIndex = holdings.indexWhere((h) => h.symbol == params.symbol);
      final heldQty = existingIndex != -1 ? holdings[existingIndex].quantity : 0;

      final sellVal = ValidationUtils.validateSellOrder(
        heldQuantity: heldQty,
        sellQuantity: quantity,
        symbol: params.symbol,
      );
      if (!sellVal.isValid) {
        return InsufficientQuantityFailure(sellVal.errorMessage!);
      }

      // Execute Sell
      balance = balance + orderValue;
      final existingHolding = holdings[existingIndex];
      final newQty = existingHolding.quantity - quantity;

      if (newQty == 0) {
        holdings.removeAt(existingIndex);
      } else {
        holdings[existingIndex] = existingHolding.copyWith(quantity: newQty);
      }
    }

    // 4. Record Trade Order
    final order = TradeOrder(
      id: 'ord_${_uuid.v4()}',
      symbol: params.symbol,
      side: params.side,
      quantity: quantity,
      executionPrice: params.executionLtp,
      totalValue: orderValue,
      timestamp: DateTime.now(),
    );
    orders.insert(0, order);

    // 5. Atomic Persist
    await repository.saveWalletBalance(balance);
    await repository.saveHoldings(holdings);
    await repository.saveOrders(orders);

    return null; // Null indicates success
  }
}
