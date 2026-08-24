import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../models/holding_model.dart';
import '../../models/trade_order_model.dart';

abstract class PortfolioLocalDataSource {
  Future<Decimal> getWalletBalance();
  Future<void> saveWalletBalance(Decimal balance);
  Future<List<HoldingModel>> getHoldings();
  Future<void> saveHoldings(List<HoldingModel> holdings);
  Future<List<TradeOrderModel>> getOrders();
  Future<void> saveOrders(List<TradeOrderModel> orders);
}

class PortfolioLocalDataSourceImpl implements PortfolioLocalDataSource {
  final SharedPreferences sharedPreferences;

  PortfolioLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Decimal> getWalletBalance() async {
    try {
      final String? raw = sharedPreferences.getString(StockConstants.keyWalletBalance);
      if (raw == null || raw.isEmpty) {
        return StockConstants.defaultWalletBalance;
      }
      return Decimal.parse(raw);
    } catch (_) {
      return StockConstants.defaultWalletBalance;
    }
  }

  @override
  Future<void> saveWalletBalance(Decimal balance) async {
    try {
      await sharedPreferences.setString(StockConstants.keyWalletBalance, balance.toString());
    } catch (e) {
      throw StorageException('Failed to save wallet balance', e);
    }
  }

  @override
  Future<List<HoldingModel>> getHoldings() async {
    try {
      final String? raw = sharedPreferences.getString(StockConstants.keyHoldings);
      if (raw == null || raw.isEmpty) {
        return _getDefaultHoldings();
      }
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => HoldingModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getDefaultHoldings();
    }
  }

  List<HoldingModel> _getDefaultHoldings() {
    return [
      HoldingModel(
        symbol: 'RELIANCE',
        quantity: 10,
        avgCost: Decimal.parse('2850.00'),
      ),
      HoldingModel(
        symbol: 'TCS',
        quantity: 5,
        avgCost: Decimal.parse('4000.00'),
      ),
      HoldingModel(
        symbol: 'INFY',
        quantity: 20,
        avgCost: Decimal.parse('1900.00'),
      ),
    ];
  }

  @override
  Future<void> saveHoldings(List<HoldingModel> holdings) async {
    try {
      final raw = jsonEncode(holdings.map((h) => h.toJson()).toList());
      await sharedPreferences.setString(StockConstants.keyHoldings, raw);
    } catch (e) {
      throw StorageException('Failed to save holdings', e);
    }
  }

  @override
  Future<List<TradeOrderModel>> getOrders() async {
    try {
      final String? raw = sharedPreferences.getString(StockConstants.keyOrders);
      if (raw == null || raw.isEmpty) return [];
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => TradeOrderModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveOrders(List<TradeOrderModel> orders) async {
    try {
      final raw = jsonEncode(orders.map((o) => o.toJson()).toList());
      await sharedPreferences.setString(StockConstants.keyOrders, raw);
    } catch (e) {
      throw StorageException('Failed to save order history', e);
    }
  }
}
