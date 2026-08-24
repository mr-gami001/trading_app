import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/watchlist.dart';
import '../models/holding.dart';
import '../models/trade_order.dart';

class StorageService {
  static const String _keyWatchlists = 'key_watchlists';
  static const String _keyHoldings = 'key_holdings';
  static const String _keyWalletBalance = 'key_wallet_balance';
  static const String _keyOrders = 'key_orders';

  // Watchlists
  static Future<List<Watchlist>?> loadWatchlists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_keyWatchlists);
    if (raw == null || raw.isEmpty) return null;
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => Watchlist.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveWatchlists(List<Watchlist> watchlists) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(watchlists.map((w) => w.toJson()).toList());
    await prefs.setString(_keyWatchlists, raw);
  }

  // Holdings
  static Future<List<Holding>?> loadHoldings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_keyHoldings);
    if (raw == null || raw.isEmpty) return null;
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => Holding.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveHoldings(List<Holding> holdings) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(holdings.map((h) => h.toJson()).toList());
    await prefs.setString(_keyHoldings, raw);
  }

  // Wallet Balance
  static Future<double?> loadWalletBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyWalletBalance);
  }

  static Future<void> saveWalletBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyWalletBalance, balance);
  }

  // Order History
  static Future<List<TradeOrder>?> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_keyOrders);
    if (raw == null || raw.isEmpty) return null;
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => TradeOrder.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveOrders(List<TradeOrder> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(orders.map((o) => o.toJson()).toList());
    await prefs.setString(_keyOrders, raw);
  }
}
