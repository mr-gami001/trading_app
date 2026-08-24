import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../models/watchlist_model.dart';

abstract class WatchlistLocalDataSource {
  Future<List<WatchlistModel>> getWatchlists();
  Future<void> saveWatchlists(List<WatchlistModel> watchlists);
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  final SharedPreferences sharedPreferences;

  WatchlistLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<WatchlistModel>> getWatchlists() async {
    try {
      final String? raw = sharedPreferences.getString(StockConstants.keyWatchlists);
      if (raw == null || raw.isEmpty) {
        return _getDefaultWatchlists();
      }
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => WatchlistModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Graceful recovery with safe defaults on parse failure
      return _getDefaultWatchlists();
    }
  }

  List<WatchlistModel> _getDefaultWatchlists() {
    return [
      const WatchlistModel(
        id: 'wl_core_1',
        name: 'Core Portfolio',
        symbols: ['RELIANCE', 'TCS', 'INFY', 'HDFCBANK', 'ICICIBANK'],
      ),
      const WatchlistModel(
        id: 'wl_bank_2',
        name: 'Banking & Finance',
        symbols: ['HDFCBANK', 'ICICIBANK', 'SBIN', 'AXISBANK'],
      ),
    ];
  }

  @override
  Future<void> saveWatchlists(List<WatchlistModel> watchlists) async {
    try {
      final raw = jsonEncode(watchlists.map((w) => w.toJson()).toList());
      await sharedPreferences.setString(StockConstants.keyWatchlists, raw);
    } catch (e) {
      throw StorageException('Failed to persist watchlists', e);
    }
  }
}
