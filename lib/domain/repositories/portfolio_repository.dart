import 'package:decimal/decimal.dart';
import '../entities/holding.dart';
import '../entities/trade_order.dart';

abstract class PortfolioRepository {
  Future<Decimal> getWalletBalance();
  Future<void> saveWalletBalance(Decimal balance);
  Future<List<Holding>> getHoldings();
  Future<void> saveHoldings(List<Holding> holdings);
  Future<List<TradeOrder>> getOrders();
  Future<void> saveOrders(List<TradeOrder> orders);
}
