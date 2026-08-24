import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/watchlist.dart';
import '../../services/storage_service.dart';
import 'watchlist_state.dart';

class WatchlistCubit extends Cubit<WatchlistState> {
  WatchlistCubit() : super(const WatchlistState()) {
    init();
  }

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    final loaded = await StorageService.loadWatchlists();
    if (loaded != null && loaded.isNotEmpty) {
      emit(state.copyWith(watchlists: loaded, isLoading: false));
    } else {
      final defaultWatchlists = [
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
      emit(state.copyWith(watchlists: defaultWatchlists, isLoading: false));
      await _persist(defaultWatchlists);
    }
  }

  void setActiveWatchlistIndex(int index) {
    if (index >= 0 && index < state.watchlists.length) {
      emit(state.copyWith(activeWatchlistIndex: index));
    }
  }

  Future<void> createWatchlist(String name) async {
    if (name.trim().isEmpty) return;
    final newWl = Watchlist(
      id: 'wl_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      symbols: [],
    );
    final updated = List<Watchlist>.from(state.watchlists)..add(newWl);
    emit(state.copyWith(
      watchlists: updated,
      activeWatchlistIndex: updated.length - 1,
    ));
    await _persist(updated);
  }

  Future<void> renameWatchlist(String id, String newName) async {
    final idx = state.watchlists.indexWhere((w) => w.id == id);
    if (idx != -1 && newName.trim().isNotEmpty) {
      final updated = List<Watchlist>.from(state.watchlists);
      updated[idx] = updated[idx].copyWith(name: newName.trim());
      emit(state.copyWith(watchlists: updated));
      await _persist(updated);
    }
  }

  Future<void> deleteWatchlist(String id) async {
    if (state.watchlists.length <= 1) {
      final idx = state.watchlists.indexWhere((w) => w.id == id);
      if (idx != -1) {
        final updated = List<Watchlist>.from(state.watchlists);
        updated[idx] = updated[idx].copyWith(symbols: []);
        emit(state.copyWith(watchlists: updated));
        await _persist(updated);
      }
      return;
    }

    final updated = List<Watchlist>.from(state.watchlists)..removeWhere((w) => w.id == id);
    int newIndex = state.activeWatchlistIndex;
    if (newIndex >= updated.length) {
      newIndex = updated.length - 1;
    }
    emit(state.copyWith(watchlists: updated, activeWatchlistIndex: newIndex));
    await _persist(updated);
  }

  Future<void> addStockToWatchlist(String watchlistId, String symbol) async {
    final idx = state.watchlists.indexWhere((w) => w.id == watchlistId);
    if (idx != -1) {
      final currentSymbols = List<String>.from(state.watchlists[idx].symbols);
      if (!currentSymbols.contains(symbol)) {
        currentSymbols.add(symbol);
        final updated = List<Watchlist>.from(state.watchlists);
        updated[idx] = updated[idx].copyWith(symbols: currentSymbols);
        emit(state.copyWith(watchlists: updated));
        await _persist(updated);
      }
    }
  }

  Future<void> removeStockFromWatchlist(String watchlistId, String symbol) async {
    final idx = state.watchlists.indexWhere((w) => w.id == watchlistId);
    if (idx != -1) {
      final currentSymbols = List<String>.from(state.watchlists[idx].symbols);
      currentSymbols.remove(symbol);
      final updated = List<Watchlist>.from(state.watchlists);
      updated[idx] = updated[idx].copyWith(symbols: currentSymbols);
      emit(state.copyWith(watchlists: updated));
      await _persist(updated);
    }
  }

  Future<void> reorderStock(String watchlistId, int oldIndex, int newIndex) async {
    final idx = state.watchlists.indexWhere((w) => w.id == watchlistId);
    if (idx != -1) {
      final currentSymbols = List<String>.from(state.watchlists[idx].symbols);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = currentSymbols.removeAt(oldIndex);
      currentSymbols.insert(newIndex, item);
      final updated = List<Watchlist>.from(state.watchlists);
      updated[idx] = updated[idx].copyWith(symbols: currentSymbols);
      emit(state.copyWith(watchlists: updated));
      await _persist(updated);
    }
  }

  Future<void> _persist(List<Watchlist> watchlists) async {
    await StorageService.saveWatchlists(watchlists);
  }
}
