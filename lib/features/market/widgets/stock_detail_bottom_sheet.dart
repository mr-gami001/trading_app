import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/decimal_utils.dart';
import '../../../core/widgets/candlestick_chart.dart';
import '../../../core/widgets/market_depth_widget.dart';
import '../../../core/widgets/mini_price_chart.dart';
import '../../../domain/entities/stock_quote.dart';
import '../../../domain/entities/trade_order.dart';
import '../../trading/pages/buy_sell_ticket_page.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_state.dart';
import '../bloc/stock_detail_bloc.dart';
import '../bloc/stock_detail_event.dart';
import '../bloc/stock_detail_state.dart';

enum ChartType { line, candlestick }

class StockDetailBottomSheet extends StatelessWidget {
  final String symbol;

  const StockDetailBottomSheet({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StockDetailBloc>(
      create: (context) => StockDetailBloc(),
      child: _StockDetailBottomSheetContent(symbol: symbol),
    );
  }
}

class _StockDetailBottomSheetContent extends StatelessWidget {
  final String symbol;

  const _StockDetailBottomSheetContent({required this.symbol});

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.88;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = AppTheme.getCardSurface(context);
    final borderColor = AppTheme.getBorderColor(context);
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final mutedText = AppTheme.getTextMuted(context);

    return BlocSelector<MarketBloc, MarketState, StockQuote?>(
      selector: (state) => state.quotes[symbol],
      builder: (context, quote) {
        if (quote == null) return const SizedBox.shrink();

        final bool isGain = quote.change >= Decimal.zero;
        final Color color = isGain ? AppTheme.getGainColor(context) : AppTheme.getLossColor(context);

        return SizedBox(
          height: sheetHeight,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handlebar
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: mutedText,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Scrollable Content Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Symbol, Name, NSE Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        quote.symbol,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: cardSurface,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: borderColor),
                                        ),
                                        child: Text(
                                          'NSE',
                                          style: TextStyle(
                                            color: mutedText,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    quote.name,
                                    style: TextStyle(color: mutedText, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DecimalUtils.formatCurrency(quote.ltp),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DecimalUtils.formatPriceChange(quote.change, quote.changePercent),
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Interactive Chart Switcher Card (Candlestick vs Line)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: BlocBuilder<StockDetailBloc, StockDetailState>(
                            builder: (context, chartState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Technical Chart',
                                        style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => context.read<StockDetailBloc>().add(const ToggleChartTypeEvent(ChartType.candlestick)),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: chartState.chartType == ChartType.candlestick ? color.withValues(alpha: 0.2) : Colors.transparent,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: chartState.chartType == ChartType.candlestick ? color : borderColor),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.candlestick_chart, size: 14, color: chartState.chartType == ChartType.candlestick ? color : mutedText),
                                                  const SizedBox(width: 4),
                                                  Text('Candle', style: TextStyle(color: chartState.chartType == ChartType.candlestick ? color : mutedText, fontSize: 11, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () => context.read<StockDetailBloc>().add(const ToggleChartTypeEvent(ChartType.line)),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: chartState.chartType == ChartType.line ? color.withValues(alpha: 0.2) : Colors.transparent,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: chartState.chartType == ChartType.line ? color : borderColor),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.show_chart, size: 14, color: chartState.chartType == ChartType.line ? color : mutedText),
                                                  const SizedBox(width: 4),
                                                  Text('Line', style: TextStyle(color: chartState.chartType == ChartType.line ? color : mutedText, fontSize: 11, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  chartState.chartType == ChartType.candlestick
                                      ? CandlestickChart(
                                          currentPrice: quote.ltp,
                                          previousClose: quote.previousClose,
                                          height: 130,
                                        )
                                      : MiniPriceChart(
                                          currentPrice: quote.ltp,
                                          previousClose: quote.previousClose,
                                          isGain: isGain,
                                          height: 130,
                                        ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Key Statistics Overview Grid
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Key Statistics & OHLC',
                                style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _buildStatItem(context, 'Open', DecimalUtils.formatCurrency(quote.previousClose * Decimal.parse('0.998')))),
                                  Expanded(child: _buildStatItem(context, 'High', DecimalUtils.formatCurrency(quote.ltp > quote.previousClose ? quote.ltp : quote.previousClose * Decimal.parse('1.01')))),
                                  Expanded(child: _buildStatItem(context, 'Low', DecimalUtils.formatCurrency(quote.ltp < quote.previousClose ? quote.ltp : quote.previousClose * Decimal.parse('0.99')))),
                                  Expanded(child: _buildStatItem(context, 'Prev. Close', DecimalUtils.formatCurrency(quote.previousClose))),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _buildStatItem(context, '52W High', DecimalUtils.formatCurrency(quote.initialPrice * Decimal.parse('1.25')))),
                                  Expanded(child: _buildStatItem(context, '52W Low', DecimalUtils.formatCurrency(quote.initialPrice * Decimal.parse('0.85')))),
                                  Expanded(child: _buildStatItem(context, 'Volume', '1,42,850')),
                                  Expanded(child: _buildStatItem(context, 'Upper Circuit', DecimalUtils.formatCurrency(quote.previousClose * Decimal.parse('1.10')))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Market Depth Order Book Ladder
                        MarketDepthWidget(ltp: quote.ltp),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Fixed Bottom Action Bar: BUY & SELL Buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: cardSurface,
                    border: Border(top: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.getGainColor(context),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BuySellTicketPage(
                                    initialSymbol: quote.symbol,
                                    initialSide: OrderSide.buy,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'BUY',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.getLossColor(context),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BuySellTicketPage(
                                    initialSymbol: quote.symbol,
                                    initialSide: OrderSide.sell,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'SELL',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppTheme.getTextMuted(context), fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
