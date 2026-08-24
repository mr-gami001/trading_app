import 'package:flutter/foundation.dart';
import '../models/watchlist.dart';
import '../services/storage_service.dart';

class WatchlistProvider extends ChangeNotifier {
  List<Watchlist> _watchlists = [];
  int _activeWatchlistIndex = 0;
  bool _isLoading = true;

  List<Watchlist> get watchlists => _watchlists;
  int get activeWatchlistIndex => _activeWatchlistIndex;
  bool get isLoading => _isLoading;

  Watchlist? get activeWatchlist {
    if (_watchlists.isEmpty) return null;
    if (_activeWatchlistIndex >= _watchlists.length) {
      _activeWatchlistIndex = 0;
    }
    return _watchlists[_activeWatchlistIndex];
  }

  WatchlistProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final loaded = await StorageService.loadWatchlists();
    if (loaded != null && loaded.isNotEmpty) {
      _watchlists = loaded;
    } else {
      // Default initial watchlists
      _watchlists = [
        const Watchlist(
          id: 'wl_default_1',
          name: 'Core Portfolio',
          symbols: ['RELIANCE', 'TCS', 'INFY', 'HDFCBANK', 'ICICIBANK'],
        ),
        const Watchlist(
          id: 'wl_default_2',
          name: 'Banking & Finance',
          symbols: ['HDFCBANK', 'ICICIBANK', 'SBIN', 'AXISBANK'],
        ),
      ];
      await _persist();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setActiveWatchlistIndex(int index) {
    if (index >= 0 && index < _watchlists.length) {
      _activeWatchlistIndex = index;
      notifyListeners();
    }
  }

  Future<void> createWatchlist(String name) async {
    if (name.trim().isEmpty) return;
    final newWl = Watchlist(
      id: 'wl_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      symbols: [],
    );
    _watchlists.add(newWl);
    _activeWatchlistIndex = _watchlists.length - 1;
    notifyListeners();
    await _persist();
  }

  Future<void> renameWatchlist(String id, String newName) async {
    final idx = _watchlists.indexWhere((w) => w.id == id);
    if (idx != -1 && newName.trim().isNotEmpty) {
      _watchlists[idx] = _watchlists[idx].copyWith(name: newName.trim());
      notifyListeners();
      await _persist();
    }
  }

  Future<void> deleteWatchlist(String id) async {
    if (_watchlists.length <= 1) {
      // Keep at least one empty watchlist or handle gracefully
      final idx = _watchlists.indexWhere((w) => w.id == id);
      if (idx != -1) {
        _watchlists[idx] = _watchlists[idx].copyWith(symbols: []);
        notifyListeners();
        await _persist();
      }
      return;
    }

    _watchlists.removeWhere((w) => w.id == id);
    if (_activeWatchlistIndex >= _watchlists.length) {
      _activeWatchlistIndex = _watchlists.length - 1;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> addStockToWatchlist(String watchlistId, String symbol) async {
    final idx = _watchlists.indexWhere((w) => w.id == watchlistId);
    if (idx != -1) {
      final currentSymbols = List<String>.from(_watchlists[idx].symbols);
      if (!currentSymbols.contains(symbol)) {
        currentSymbols.add(symbol);
        _watchlists[idx] = _watchlists[idx].copyWith(symbols: currentSymbols);
        notifyListeners();
        await _persist();
      }
    }
  }

  Future<void> removeStockFromWatchlist(String watchlistId, String symbol) async {
    final idx = _watchlists.indexWhere((w) => w.id == watchlistId);
    if (idx != -1) {
      final currentSymbols = List<String>.from(_watchlists[idx].symbols);
      currentSymbols.remove(symbol);
      _watchlists[idx] = _watchlists[idx].copyWith(symbols: currentSymbols);
      notifyListeners();
      await _persist();
    }
  }

  Future<void> reorderStock(String watchlistId, int oldIndex, int newIndex) async {
    final idx = _watchlists.indexWhere((w) => w.id == watchlistId);
    if (idx != -1) {
      final currentSymbols = List<String>.from(_watchlists[idx].symbols);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = currentSymbols.removeAt(oldIndex);
      currentSymbols.insert(newIndex, item);
      _watchlists[idx] = _watchlists[idx].copyWith(symbols: currentSymbols);
      notifyListeners();
      await _persist();
    }
  }

  Future<void> _persist() async {
    await StorageService.saveWatchlists(_watchlists);
  }
}
