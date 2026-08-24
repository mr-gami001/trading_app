import '../../entities/watchlist.dart';
import '../../repositories/watchlist_repository.dart';

class GetWatchlistsUseCase {
  final WatchlistRepository repository;

  GetWatchlistsUseCase({required this.repository});

  Future<List<Watchlist>> execute() async {
    return await repository.getWatchlists();
  }
}

class SaveWatchlistsUseCase {
  final WatchlistRepository repository;

  SaveWatchlistsUseCase({required this.repository});

  Future<void> execute(List<Watchlist> watchlists) async {
    await repository.saveWatchlists(watchlists);
  }
}
