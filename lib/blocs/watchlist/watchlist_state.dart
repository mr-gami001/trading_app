import 'package:equatable/equatable.dart';
import '../../models/watchlist.dart';

class WatchlistState extends Equatable {
  final List<Watchlist> watchlists;
  final int activeWatchlistIndex;
  final bool isLoading;

  const WatchlistState({
    this.watchlists = const [],
    this.activeWatchlistIndex = 0,
    this.isLoading = true,
  });

  Watchlist? get activeWatchlist {
    if (watchlists.isEmpty) return null;
    final idx = activeWatchlistIndex.clamp(0, watchlists.length - 1);
    return watchlists[idx];
  }

  WatchlistState copyWith({
    List<Watchlist>? watchlists,
    int? activeWatchlistIndex,
    bool? isLoading,
  }) {
    return WatchlistState(
      watchlists: watchlists ?? this.watchlists,
      activeWatchlistIndex: activeWatchlistIndex ?? this.activeWatchlistIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [watchlists, activeWatchlistIndex, isLoading];
}
