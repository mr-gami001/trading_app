import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/market_feed/market_feed_bloc.dart';
import '../blocs/market_feed/market_feed_state.dart';
import '../blocs/watchlist/watchlist_bloc.dart';
import '../blocs/watchlist/watchlist_event.dart';
import '../blocs/watchlist/watchlist_state.dart';
import '../utils/formatters.dart';

class AddStockModal extends StatelessWidget {
  final String watchlistId;

  const AddStockModal({super.key, required this.watchlistId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, watchlistState) {
        final watchlist = watchlistState.watchlists.firstWhere(
          (w) => w.id == watchlistId,
          orElse: () => watchlistState.activeWatchlist!,
        );

        return Container(
          padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Stock to "${watchlist.name}"',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: BlocBuilder<MarketFeedBloc, MarketFeedState>(
                  builder: (context, feedState) {
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: MarketFeedBloc.initialUniverse.length,
                      separatorBuilder: (context, index) => const Divider(color: Color(0xFF334155), height: 1),
                      itemBuilder: (context, index) {
                        final stock = MarketFeedBloc.initialUniverse[index];
                        final quote = feedState.quotes[stock.symbol];
                        final bool isAlreadyInWatchlist = watchlist.symbols.contains(stock.symbol);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            stock.symbol,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            stock.name,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (quote != null)
                                Text(
                                  Formatters.currency(quote.ltp),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: Icon(
                                  isAlreadyInWatchlist ? Icons.check_circle : Icons.add_circle_outline,
                                  color: isAlreadyInWatchlist ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                                ),
                                onPressed: () {
                                  final bloc = context.read<WatchlistBloc>();
                                  if (isAlreadyInWatchlist) {
                                    bloc.add(RemoveStockFromWatchlistEvent(watchlistId, stock.symbol));
                                  } else {
                                    bloc.add(AddStockToWatchlistEvent(watchlistId, stock.symbol));
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
