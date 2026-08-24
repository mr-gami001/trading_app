import '../../domain/entities/watchlist.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/local/watchlist_local_datasource.dart';
import '../models/watchlist_model.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource localDataSource;

  WatchlistRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Watchlist>> getWatchlists() async {
    final models = await localDataSource.getWatchlists();
    return models
        .map((m) => Watchlist(
              id: m.id,
              name: m.name,
              symbols: List<String>.from(m.symbols),
            ))
        .toList();
  }

  @override
  Future<void> saveWatchlists(List<Watchlist> watchlists) async {
    final models = watchlists.map((w) => WatchlistModel.fromEntity(w)).toList();
    await localDataSource.saveWatchlists(models);
  }
}
