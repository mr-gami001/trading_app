import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/decimal_utils.dart';
import '../../../domain/entities/stock_quote.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_state.dart';
import 'stock_detail_bottom_sheet.dart';

class StockRowTile extends StatelessWidget {
  final String symbol;
  final VoidCallback? onTap;
  final Widget? trailingWidget;
  final bool isReorderable;

  const StockRowTile({
    super.key,
    required this.symbol,
    this.onTap,
    this.trailingWidget,
    this.isReorderable = false,
  });

  void _openStockDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StockDetailBottomSheet(symbol: symbol),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : AppTheme.lightTextPrimary;
    final secondaryTextColor = AppTheme.getTextMuted(context);
    final borderColor = AppTheme.getBorderColor(context);

    return BlocSelector<MarketBloc, MarketState, StockQuote?>(
      selector: (state) => state.quotes[symbol],
      builder: (context, quote) {
        if (quote == null) return const SizedBox.shrink();

        final isGain = quote.change >= Decimal.zero;
        final color = isGain ? AppTheme.getGainColor(context) : AppTheme.getLossColor(context);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () => _openStockDetail(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  if (isReorderable)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(Icons.drag_indicator, color: secondaryTextColor),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              quote.symbol,
                              style: TextStyle(
                                color: primaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.getCardSurface(context),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: borderColor),
                              ),
                              child: Text(
                                'NSE',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quote.name,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DecimalUtils.formatPriceChange(quote.change, quote.changePercent),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (trailingWidget != null) ...[
                    const SizedBox(width: 8),
                    trailingWidget!,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
