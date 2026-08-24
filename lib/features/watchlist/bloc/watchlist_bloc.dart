import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/watchlist.dart';
import '../../../domain/usecases/watchlist/get_watchlists_usecase.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetWatchlistsUseCase getWatchlistsUseCase;
  final SaveWatchlistsUseCase saveWatchlistsUseCase;

  WatchlistBloc({
    required this.getWatchlistsUseCase,
    required this.saveWatchlistsUseCase,
  }) : super(const WatchlistState()) {
    on<LoadWatchlistsEvent>(_onLoadWatchlists);
    on<SelectWatchlistEvent>(_onSelectWatchlist);
    on<CreateWatchlistEvent>(_onCreateWatchlist);
    on<RenameWatchlistEvent>(_onRenameWatchlist);
    on<DeleteWatchlistEvent>(_onDeleteWatchlist);
    on<AddStockToWatchlistEvent>(_onAddStockToWatchlist);
    on<RemoveStockFromWatchlistEvent>(_onRemoveStockFromWatchlist);
    on<ReorderWatchlistEvent>(_onReorderWatchlist);

    add(LoadWatchlistsEvent());
  }

  Future<void> _onLoadWatchlists(LoadWatchlistsEvent event, Emitter<WatchlistState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final list = await getWatchlistsUseCase.execute();
      emit(state.copyWith(watchlists: list, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to load watchlists: $e'));
    }
  }

  void _onSelectWatchlist(SelectWatchlistEvent event, Emitter<WatchlistState> emit) {
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
    await saveWatchlistsUseCase.execute(updated);
  }

  Future<void> _onRenameWatchlist(RenameWatchlistEvent event, Emitter<WatchlistState> emit) async {
    final idx = state.watchlists.indexWhere((w) => w.id == event.watchlistId);
    if (idx != -1 && event.newName.trim().isNotEmpty) {
      final updated = List<Watchlist>.from(state.watchlists);
      updated[idx] = updated[idx].copyWith(name: event.newName.trim());
      emit(state.copyWith(watchlists: updated));
      await saveWatchlistsUseCase.execute(updated);
    }
  }

  Future<void> _onDeleteWatchlist(DeleteWatchlistEvent event, Emitter<WatchlistState> emit) async {
    if (state.watchlists.length <= 1) {
      final idx = state.watchlists.indexWhere((w) => w.id == event.watchlistId);
      if (idx != -1) {
        final updated = List<Watchlist>.from(state.watchlists);
        updated[idx] = updated[idx].copyWith(symbols: []);
        emit(state.copyWith(watchlists: updated));
        await saveWatchlistsUseCase.execute(updated);
      }
      return;
    }

    final updated = List<Watchlist>.from(state.watchlists)..removeWhere((w) => w.id == event.watchlistId);
    int newIndex = state.activeWatchlistIndex;
    if (newIndex >= updated.length) {
      newIndex = updated.length - 1;
    }
    emit(state.copyWith(watchlists: updated, activeWatchlistIndex: newIndex));
    await saveWatchlistsUseCase.execute(updated);
  }

  Future<void> _onAddStockToWatchlist(AddStockToWatchlistEvent event, Emitter<WatchlistState> emit) async {
    final idx = state.watchlists.indexWhere((w) => w.id == event.watchlistId);
    if (idx != -1) {
      final currentSymbols = List<String>.from(state.watchlists[idx].symbols);
      if (!currentSymbols.contains(event.symbol)) {
        currentSymbols.add(event.symbol);
        final updated = List<Watchlist>.from(state.watchlists);
        updated[idx] = updated[idx].copyWith(symbols: currentSymbols);
        emit(state.copyWith(watchlists: updated));
        await saveWatchlistsUseCase.execute(updated);
      }
    }
  }

  Future<void> _onRemoveStockFromWatchlist(RemoveStockFromWatchlistEvent event, Emitter<WatchlistState> emit) async {
    final idx = state.watchlists.indexWhere((w) => w.id == event.watchlistId);
    if (idx != -1) {
      final currentSymbols = List<String>.from(state.watchlists[idx].symbols);
      currentSymbols.remove(event.symbol);
      final updated = List<Watchlist>.from(state.watchlists);
      updated[idx] = updated[idx].copyWith(symbols: currentSymbols);
      emit(state.copyWith(watchlists: updated));
      await saveWatchlistsUseCase.execute(updated);
    }
  }

  Future<void> _onReorderWatchlist(ReorderWatchlistEvent event, Emitter<WatchlistState> emit) async {
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
      await saveWatchlistsUseCase.execute(updated);
    }
  }
}
