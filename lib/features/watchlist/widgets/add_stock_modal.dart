import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../core/utils/decimal_utils.dart';
import '../../../domain/entities/watchlist.dart';
import '../../market/bloc/market_bloc.dart';
import '../../market/bloc/market_state.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';

class AddStockModal extends StatelessWidget {
  final String watchlistId;

  const AddStockModal({super.key, required this.watchlistId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = AppTheme.getCardSurface(context);
    final borderColor = AppTheme.getBorderColor(context);
    final activeColor = AppTheme.getGainColor(context);
    final mutedText = AppTheme.getTextMuted(context);

    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, watchlistState) {
        if (watchlistState.watchlists.isEmpty) {
          return const SizedBox.shrink();
        }

        final Watchlist watchlist = watchlistState.watchlists.firstWhere(
          (w) => w.id == watchlistId,
          orElse: () => watchlistState.activeWatchlist ?? watchlistState.watchlists.first,
        );

        return Container(
          padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
          decoration: BoxDecoration(
            color: cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: mutedText,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Stock to "${watchlist.name}"',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: BlocBuilder<MarketBloc, MarketState>(
                  builder: (context, feedState) {
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: StockConstants.supportedStocks.length,
                      separatorBuilder: (context, index) => Divider(color: borderColor, height: 1),
                      itemBuilder: (context, index) {
                        final stock = StockConstants.supportedStocks[index];
                        final quote = feedState.quotes[stock.symbol];
                        final bool isAlreadyInWatchlist = watchlist.symbols.contains(stock.symbol);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            stock.symbol,
                            style: TextStyle(
                              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            stock.name,
                            style: TextStyle(color: mutedText, fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (quote != null)
                                Text(
                                  DecimalUtils.formatCurrency(quote.ltp),
                                  style: TextStyle(
                                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: Icon(
                                  isAlreadyInWatchlist ? Icons.check_circle : Icons.add_circle_outline,
                                  color: isAlreadyInWatchlist ? activeColor : const Color(0xFF536DFE),
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
