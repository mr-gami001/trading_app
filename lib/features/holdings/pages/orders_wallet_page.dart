import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/theme_bloc.dart';
import '../../../app/theme/theme_event.dart';
import '../../../app/theme/theme_state.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../core/utils/decimal_utils.dart';
import '../../../domain/entities/trade_order.dart';
import '../../../domain/usecases/holdings/get_portfolio_summary_usecase.dart';
import '../../../injection_container.dart';
import '../../market/bloc/market_bloc.dart';
import '../../market/bloc/market_state.dart';
import '../bloc/holdings_bloc.dart';
import '../bloc/holdings_event.dart';
import '../bloc/holdings_state.dart';

class OrdersWalletPage extends StatelessWidget {
  const OrdersWalletPage({super.key});

  void _showAddFundsDialog(BuildContext context, Decimal currentBalance) {
    final controller = TextEditingController(text: '50000');
    final cardSurface = AppTheme.getCardSurface(context);
    final activeColor = AppTheme.getGainColor(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Funds to Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount (₹):', style: TextStyle(color: AppTheme.getTextMuted(context))),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: activeColor)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: activeColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: AppTheme.getTextMuted(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: activeColor),
            onPressed: () {
              final addVal = Decimal.tryParse(controller.text.trim());
              if (addVal != null && addVal > Decimal.zero) {
                final newBalance = currentBalance + addVal;
                context.read<HoldingsBloc>().add(ResetWalletBalanceEvent(newBalance));
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add Money', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetWalletDialog(BuildContext context) {
    final cardSurface = AppTheme.getCardSurface(context);
    final activeColor = AppTheme.getGainColor(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Wallet Balance'),
        content: Text(
          'Reset wallet margin balance back to initial ${DecimalUtils.formatCurrency(StockConstants.defaultWalletBalance)}?',
          style: TextStyle(color: AppTheme.getTextMuted(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: AppTheme.getTextMuted(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: activeColor),
            onPressed: () {
              context.read<HoldingsBloc>().add(ResetWalletBalanceEvent(StockConstants.defaultWalletBalance));
              Navigator.of(ctx).pop();
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summaryUseCase = sl<GetPortfolioSummaryUseCase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = AppTheme.getCardSurface(context);
    final borderColor = AppTheme.getBorderColor(context);
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final activeColor = AppTheme.getGainColor(context);
    final mutedText = AppTheme.getTextMuted(context);

    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, feedState) {
        return BlocBuilder<HoldingsBloc, HoldingsState>(
          builder: (context, portfolioState) {
            final summary = summaryUseCase.execute(
              holdings: portfolioState.holdings,
              quotes: feedState.quotes,
            );

            return Scaffold(
              backgroundColor: bg,
              appBar: AppBar(
                backgroundColor: cardSurface,
                elevation: 0,
                title: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: activeColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Funds & Orders',
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
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF536DFE), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF536DFE).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Available Trading Funds',
                                style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 13),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                                tooltip: 'Reset Cash Balance',
                                onPressed: () => _showResetWalletDialog(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              DecimalUtils.formatCurrency(portfolioState.walletBalance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Invested Amount', style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 11)),
                                      const SizedBox(height: 2),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          DecimalUtils.formatCurrency(summary.totalInvested),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Total Equity Value', style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 11)),
                                      const SizedBox(height: 2),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          DecimalUtils.formatCurrency(portfolioState.walletBalance + summary.totalCurrentValue),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: activeColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('Add Funds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              onPressed: () => _showAddFundsDialog(context, portfolioState.walletBalance),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Order History Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Executed Orders (${portfolioState.orders.length})',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Order History List
                    portfolioState.orders.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'No orders executed yet',
                                style: TextStyle(color: mutedText, fontSize: 14),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: portfolioState.orders.length,
                            itemBuilder: (context, index) {
                              final order = portfolioState.orders[index];
                              final isBuy = order.side == OrderSide.buy;
                              final sideColor = isBuy ? AppTheme.getGainColor(context) : AppTheme.getLossColor(context);

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: cardSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: sideColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isBuy ? 'BUY' : 'SELL',
                                        style: TextStyle(
                                          color: sideColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                order.symbol,
                                                style: TextStyle(
                                                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.getGainColor(context).withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                                child: Text('EXECUTED', style: TextStyle(color: AppTheme.getGainColor(context), fontSize: 8, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            DecimalUtils.formatDateTime(order.timestamp),
                                            style: TextStyle(color: mutedText, fontSize: 10),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          DecimalUtils.formatCurrency(order.totalValue),
                                          style: TextStyle(
                                            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${order.quantity} qty @ ${DecimalUtils.formatCurrency(order.executionPrice, showSymbol: false)}',
                                          style: TextStyle(color: mutedText, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
