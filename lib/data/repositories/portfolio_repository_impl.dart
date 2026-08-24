import 'package:decimal/decimal.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/trade_order.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/local/portfolio_local_datasource.dart';
import '../models/holding_model.dart';
import '../models/trade_order_model.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioLocalDataSource localDataSource;

  PortfolioRepositoryImpl({required this.localDataSource});

  @override
  Future<Decimal> getWalletBalance() async {
    return await localDataSource.getWalletBalance();
  }

  @override
  Future<void> saveWalletBalance(Decimal balance) async {
    await localDataSource.saveWalletBalance(balance);
  }

  @override
  Future<List<Holding>> getHoldings() async {
    return await localDataSource.getHoldings();
  }

  @override
  Future<void> saveHoldings(List<Holding> holdings) async {
    final models = holdings.map((h) => HoldingModel.fromEntity(h)).toList();
    await localDataSource.saveHoldings(models);
  }

  @override
  Future<List<TradeOrder>> getOrders() async {
    return await localDataSource.getOrders();
  }

  @override
  Future<void> saveOrders(List<TradeOrder> orders) async {
    final models = orders.map((o) => TradeOrderModel.fromEntity(o)).toList();
    await localDataSource.saveOrders(models);
  }
}
