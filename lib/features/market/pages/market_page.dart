import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/theme_bloc.dart';
import '../../../app/theme/theme_event.dart';
import '../../../app/theme/theme_state.dart';
import '../../../core/constants/stock_constants.dart';
import '../../profile/pages/profile_page.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_filter_bloc.dart';
import '../bloc/market_filter_event.dart';
import '../bloc/market_filter_state.dart';
import '../bloc/market_state.dart';
import '../widgets/indices_ticker_tape.dart';
import '../widgets/stock_row_tile.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MarketFilterBloc>(
      create: (context) => MarketFilterBloc(),
      child: const _MarketPageContent(),
    );
  }
}

class _MarketPageContent extends StatefulWidget {
  const _MarketPageContent();

  @override
  State<_MarketPageContent> createState() => _MarketPageContentState();
}

class _MarketPageContentState extends State<_MarketPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = AppTheme.getCardSurface(context);
    final borderColor = AppTheme.getBorderColor(context);
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final activeColor = AppTheme.getGainColor(context);
    final mutedText = AppTheme.getTextMuted(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardSurface,
        elevation: 0,
        leading: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: activeColor,
              child: const Text('DG', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.bolt, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text(
              'Market Overview',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return IconButton(
                icon: Icon(
                  themeState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF536DFE),
                ),
                tooltip: 'Toggle Theme',
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Indices Ticker Tape
          const IndicesTickerTape(),

          // Search Bar & Filter Chips
          Container(
            padding: const EdgeInsets.all(12),
            color: cardSurface,
            child: Column(
              children: [
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: BlocBuilder<MarketFilterBloc, MarketFilterState>(
                    builder: (context, filterState) {
                      return TextField(
                        controller: _searchController,
                        style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search stock (e.g. RELIANCE, TCS, INFY)',
                          hintStyle: TextStyle(color: mutedText, fontSize: 13),
                          prefixIcon: Icon(Icons.search, color: mutedText, size: 20),
                          suffixIcon: filterState.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: mutedText, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<MarketFilterBloc>().add(const UpdateSearchQueryEvent(''));
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (val) {
                          context.read<MarketFilterBloc>().add(UpdateSearchQueryEvent(val.trim().toLowerCase()));
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                BlocBuilder<MarketFilterBloc, MarketFilterState>(
                  builder: (context, filterState) {
                    return Row(
                      children: [
                        _buildFilterChip(context, 'All', filterState.activeFilter),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, 'Top Gainers', filterState.activeFilter),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, 'Top Losers', filterState.activeFilter),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // WebSocket Feed Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.getGainColor(context),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE WEBSOCKET FEED',
                      style: TextStyle(color: AppTheme.getGainColor(context), fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
                Text(
                  'NSE / BSE REAL-TIME',
                  style: TextStyle(color: mutedText, fontWeight: FontWeight.w600, fontSize: 11),
                ),
              ],
            ),
          ),

          // Filtered Stock List
          Expanded(
            child: BlocBuilder<MarketFilterBloc, MarketFilterState>(
              builder: (context, filterState) {
                return BlocBuilder<MarketBloc, MarketState>(
                  builder: (context, feedState) {
                    final filteredStocks = StockConstants.supportedStocks.where((stock) {
                      final matchesSearch = filterState.searchQuery.isEmpty ||
                          stock.symbol.toLowerCase().contains(filterState.searchQuery) ||
                          stock.name.toLowerCase().contains(filterState.searchQuery);

                      if (!matchesSearch) return false;

                      final quote = feedState.quotes[stock.symbol];
                      if (filterState.activeFilter == 'Top Gainers') {
                        return quote != null && quote.changePercent.toDouble() > 0;
                      } else if (filterState.activeFilter == 'Top Losers') {
                        return quote != null && quote.changePercent.toDouble() < 0;
                      }
                      return true;
                    }).toList();

                    if (filteredStocks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 48, color: mutedText),
                            const SizedBox(height: 12),
                            Text('No matching stocks found', style: TextStyle(color: mutedText, fontSize: 14)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredStocks.length,
                      itemBuilder: (context, index) {
                        final stock = filteredStocks[index];
                        return StockRowTile(
                          key: ValueKey('market_tile_${stock.symbol}'),
                          symbol: stock.symbol,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String activeFilter) {
    final bool isSelected = activeFilter == label;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final activeColor = AppTheme.getGainColor(context);
    final mutedText = AppTheme.getTextMuted(context);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: activeColor,
      backgroundColor: bg,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : mutedText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) {
        context.read<MarketFilterBloc>().add(SelectFilterChipEvent(label));
      },
    );
  }
}
