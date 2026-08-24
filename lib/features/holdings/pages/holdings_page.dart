import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/theme_bloc.dart';
import '../../../app/theme/theme_event.dart';
import '../../../app/theme/theme_state.dart';
import '../../../core/utils/decimal_utils.dart';
import '../../../domain/entities/trade_order.dart';
import '../../../domain/usecases/holdings/get_portfolio_summary_usecase.dart';
import '../../../injection_container.dart';
import '../../market/bloc/market_bloc.dart';
import '../../market/bloc/market_state.dart';
import '../../profile/pages/profile_page.dart';
import '../../trading/pages/buy_sell_ticket_page.dart';
import '../bloc/holdings_bloc.dart';
import '../bloc/holdings_event.dart';
import '../bloc/holdings_state.dart';
import '../bloc/holdings_tab_bloc.dart';
import '../bloc/holdings_tab_event.dart';
import '../bloc/holdings_tab_state.dart';
import '../widgets/portfolio_summary_card.dart';

enum PortfolioTab { holdings, positions }

class HoldingsPage extends StatelessWidget {
  const HoldingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HoldingsTabBloc>(
      create: (context) => HoldingsTabBloc(),
      child: const _HoldingsPageContent(),
    );
  }
}

class _HoldingsPageContent extends StatefulWidget {
  const _HoldingsPageContent();

  @override
  State<_HoldingsPageContent> createState() => _HoldingsPageContentState();
}

class _HoldingsPageContentState extends State<_HoldingsPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryUseCase = sl<GetPortfolioSummaryUseCase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = AppTheme.getCardSurface(context);
    final borderColor = AppTheme.getBorderColor(context);
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final activeColor = AppTheme.getGainColor(context);
    final lossColor = AppTheme.getLossColor(context);
    final mutedText = AppTheme.getTextMuted(context);

    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, feedState) {
        return BlocBuilder<HoldingsBloc, HoldingsState>(
          builder: (context, holdingsState) {
            final quotes = feedState.quotes;
            final holdings = holdingsState.getSortedHoldings(quotes);
            final summary = summaryUseCase.execute(
              holdings: holdingsState.holdings,
              quotes: quotes,
            );

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
                title: Row(
                  children: [
                    Icon(Icons.pie_chart, color: activeColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Portfolio',
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
              body: holdingsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // Holdings vs Positions Tab Bar
                        BlocBuilder<HoldingsTabBloc, HoldingsTabState>(
                          builder: (context, tabState) {
                            return Container(
                              color: cardSurface,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ChoiceChip(
                                      label: const Center(child: Text('Holdings (CNC)')),
                                      selected: tabState.currentTab == PortfolioTab.holdings,
                                      selectedColor: activeColor,
                                      backgroundColor: bg,
                                      labelStyle: TextStyle(
                                        color: tabState.currentTab == PortfolioTab.holdings ? Colors.white : mutedText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onSelected: (_) => context.read<HoldingsTabBloc>().add(const SelectPortfolioTabEvent(PortfolioTab.holdings)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ChoiceChip(
                                      label: const Center(child: Text('Positions (Day)')),
                                      selected: tabState.currentTab == PortfolioTab.positions,
                                      selectedColor: activeColor,
                                      backgroundColor: bg,
                                      labelStyle: TextStyle(
                                        color: tabState.currentTab == PortfolioTab.positions ? Colors.white : mutedText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onSelected: (_) => context.read<HoldingsTabBloc>().add(const SelectPortfolioTabEvent(PortfolioTab.positions)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Portfolio Summary Card
                        PortfolioSummaryCard(summary: summary),

                        // Search & Sort Bar
                        if (holdings.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: cardSurface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Filter holdings',
                                        hintStyle: TextStyle(color: mutedText, fontSize: 12),
                                        prefixIcon: Icon(Icons.search, color: mutedText, size: 16),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      onChanged: (val) => context.read<HoldingsTabBloc>().add(UpdateHoldingsSearchQueryEvent(val.trim().toLowerCase())),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<HoldingSortOption>(
                                    value: holdingsState.sortOption,
                                    dropdownColor: cardSurface,
                                    style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 12),
                                    icon: Icon(Icons.sort, color: activeColor, size: 18),
                                    items: const [
                                      DropdownMenuItem(value: HoldingSortOption.pnlDesc, child: Text('P&L High')),
                                      DropdownMenuItem(value: HoldingSortOption.pnlAsc, child: Text('P&L Low')),
                                      DropdownMenuItem(value: HoldingSortOption.currentValueDesc, child: Text('Value')),
                                      DropdownMenuItem(value: HoldingSortOption.symbolAsc, child: Text('Symbol')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        context.read<HoldingsBloc>().add(SetSortOptionEvent(val));
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Holdings List
                        Expanded(
                          child: BlocBuilder<HoldingsTabBloc, HoldingsTabState>(
                            builder: (context, tabState) {
                              final filteredHoldings = holdings.where((h) => tabState.searchQuery.isEmpty || h.symbol.toLowerCase().contains(tabState.searchQuery)).toList();

                              if (tabState.currentTab == PortfolioTab.positions) {
                                return Center(
                                  child: Text(
                                    'No open intraday positions for today',
                                    style: TextStyle(color: mutedText, fontSize: 14),
                                  ),
                                );
                              }

                              if (filteredHoldings.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.account_balance_wallet_outlined, size: 64, color: mutedText),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No holdings in your portfolio',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Buy stocks from the Watchlist or Market to start',
                                        style: TextStyle(color: mutedText, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: filteredHoldings.length,
                                itemBuilder: (context, index) {
                                  final holding = filteredHoldings[index];
                                  final quote = quotes[holding.symbol];
                                  final Decimal currentLtp = quote?.ltp ?? holding.avgCost;
                                  final Decimal holdingPnl = holding.pnl(currentLtp);
                                  final Decimal holdingPnlPct = holding.pnlPercent(currentLtp);
                                  final bool isPos = holdingPnl >= Decimal.zero;
                                  final Color color = isPos ? activeColor : lossColor;

                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: cardSurface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => BuySellTicketPage(initialSymbol: holding.symbol, initialSide: OrderSide.buy),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        holding.symbol,
                                                        style: TextStyle(
                                                          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: bg,
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          'Qty: ${holding.quantity}',
                                                          style: TextStyle(color: mutedText, fontSize: 11),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    DecimalUtils.formatCurrency(holdingPnl),
                                                    style: TextStyle(
                                                      color: color,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Avg. Cost', style: TextStyle(color: mutedText, fontSize: 11)),
                                                      Text(
                                                        DecimalUtils.formatCurrency(holding.avgCost),
                                                        style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontSize: 13),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text('LTP', style: TextStyle(color: mutedText, fontSize: 11)),
                                                      Text(
                                                        DecimalUtils.formatCurrency(currentLtp),
                                                        style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text('P&L %', style: TextStyle(color: mutedText, fontSize: 11)),
                                                      Text(
                                                        '${isPos ? "+" : ""}${holdingPnlPct.toDouble().toStringAsFixed(2)}%',
                                                        style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Divider(color: borderColor, height: 1),
                                              const SizedBox(height: 10),

                                              // Explicit Action Buttons: BUY MORE & SELL / EXIT
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 36,
                                                      child: OutlinedButton.icon(
                                                        style: OutlinedButton.styleFrom(
                                                          side: BorderSide(color: activeColor),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                        ),
                                                        icon: Icon(Icons.add, color: activeColor, size: 16),
                                                        label: Text('BUY MORE', style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                                        onPressed: () {
                                                          Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                              builder: (_) => BuySellTicketPage(initialSymbol: holding.symbol, initialSide: OrderSide.buy),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 36,
                                                      child: ElevatedButton.icon(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: lossColor,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                        ),
                                                        icon: const Icon(Icons.sell, color: Colors.white, size: 16),
                                                        label: const Text('SELL / EXIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                                        onPressed: () {
                                                          Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                              builder: (_) => BuySellTicketPage(initialSymbol: holding.symbol, initialSide: OrderSide.sell),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
      },
    );
  }
}
