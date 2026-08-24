import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/watchlist.dart';
import '../../services/storage_service.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc() : super(const WatchlistState()) {
    on<InitWatchlistsEvent>(_onInit);
    on<SetActiveWatchlistIndexEvent>(_onSetActiveIndex);
    on<CreateWatchlistEvent>(_onCreateWatchlist);
    on<RenameWatchlistEvent>(_onRenameWatchlist);
    on<DeleteWatchlistEvent>(_onDeleteWatchlist);
    on<AddStockToWatchlistEvent>(_onAddStock);
    on<RemoveStockFromWatchlistEvent>(_onRemoveStock);
    on<ReorderStockEvent>(_onReorderStock);

    add(InitWatchlistsEvent());
  }

  Future<void> _onInit(InitWatchlistsEvent event, Emitter<WatchlistState> emit) async {
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
      await StorageService.saveWatchlists(defaultWatchlists);
    }
  }

  void _onSetActiveIndex(SetActiveWatchlistIndexEvent event, Emitter<WatchlistState> emit) {
    if (event.index >= 0 && event.index < state.watchlists.length) {
      emit(state.copyWith(activeWatchlistIndex: event.index));
    }
  }

  Future<void> _onCreateWatchlist(CreateWatchlistEvent event, Emitter<WatchlistState> emit) async {
    if (event.name.trim().isEmpty) return;
    final newWl = Watchlist(
      id: 'wl_${DateTime.now().millisecondsSinceEpoch}',
      name: event.name.trim(),
      symbols: [],
    );
    final updated = List<Watchlist>.from(state.watchlists)..add(newWl);
    emit(state.copyWith(
      watchlists: updated,
      activeWatchlistIndex: updated.length - 1,
    ));
    await StorageService.saveWatchlists(updated);
  }

  Future<void> _onRenameWatchlist(RenameWatchlistEvent event, Emitter<WatchlistState> emit) async {
    final idx = state.watchlists.indexWhere((w) => w.id == event.id);
    if (idx != -1 && event.newName.trim().isNotEmpty) {
      final updated = List<Watchlist>.from(state.watchlists);
      updated[idx] = updated[idx].copyWith(name: event.newName.trim());
      emit(state.copyWith(watchlists: updated));
      await StorageService.saveWatchlists(updated);
    }
  }

  Future<void> _onDeleteWatchlist(DeleteWatchlistEvent event, Emitter<WatchlistState> emit) async {
    if (state.watchlists.length <= 1) {
      final idx = state.watchlists.indexWhere((w) => w.id == event.id);
      if (idx != -1) {
        final updated = List<Watchlist>.from(state.watchlists);
        updated[idx] = updated[idx].copyWith(symbols: []);
        emit(state.copyWith(watchlists: updated));
        await StorageService.saveWatchlists(updated);
      }
      return;
    }

    final updated = List<Watchlist>.from(state.watchlists)..removeWhere((w) => w.id == event.id);
    int newIndex = state.activeWatchlistIndex;
    if (newIndex >= updated.length) {
      newIndex = updated.length - 1;
    }
    emit(state.copyWith(watchlists: updated, activeWatchlistIndex: newIndex));
    await StorageService.saveWatchlists(updated);
  }

  Future<void> _onAddStock(AddStockToWatchlistEvent event, Emitter<WatchlistState> emit) async {
    final idx = state.watchlists.indexWhere((w) => w.id == event.watchlistId);
    if (idx != -1) {
      final currentSymbols = List<String>.from(state.watchlists[idx].symbols);
      if (!currentSymbols.contains(event.symbol)) {
        currentSymbols.add(event.symbol);
        final updated = List<Watchlist>.from(state.watchlists);
        updated[idx] = updated[idx].copyWith(symbols: currentSymbols);
        emit(state.copyWith(watchlists: updated));
        await StorageService.saveWatchlists(updated);
      }
    }
  }

  Future<void> _onRemoveStock(RemoveStockFromWatchlistEvent event, Emitter<WatchlistState> emit) async {
    final idx = state.watchlists.indexWhere((w) => w.id == event.watchlistId);
    if (idx != -1) {
      final currentSymbols = List<String>.from(state.watchlists[idx].symbols);
      currentSymbols.remove(event.symbol);
      final updated = List<Watchlist>.from(state.watchlists);
      updated[idx] = updated[idx].copyWith(symbols: currentSymbols);
      emit(state.copyWith(watchlists: updated));
      await StorageService.saveWatchlists(updated);
    }
  }

  Future<void> _onReorderStock(ReorderStockEvent event, Emitter<WatchlistState> emit) async {
    final idx = state.watchlists.indexWhere((w) => w.id == event.watchlistId);
    if (idx != -1) {
      final currentSymbols = List<String>.from(state.watchlists[idx].symbols);
      int newIdx = event.newIndex;
      if (event.oldIndex < newIdx) {
        newIdx -= 1;
      }
      final item = currentSymbols.removeAt(event.oldIndex);
      currentSymbols.insert(newIdx, item);
      final updated = List<Watchlist>.from(state.watchlists);
      updated[idx] = updated[idx].copyWith(symbols: currentSymbols);
      emit(state.copyWith(watchlists: updated));
      await StorageService.saveWatchlists(updated);
    }
  }
}
