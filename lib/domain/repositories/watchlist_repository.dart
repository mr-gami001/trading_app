import '../entities/watchlist.dart';

abstract class WatchlistRepository {
  Future<List<Watchlist>> getWatchlists();
  Future<void> saveWatchlists(List<Watchlist> watchlists);
}
