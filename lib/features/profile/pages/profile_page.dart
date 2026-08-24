import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/theme_bloc.dart';
import '../../../app/theme/theme_event.dart';
import '../../../app/theme/theme_state.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../core/utils/decimal_utils.dart';
import '../../../domain/usecases/holdings/get_portfolio_summary_usecase.dart';
import '../../../injection_container.dart';
import '../../holdings/bloc/holdings_bloc.dart';
import '../../holdings/bloc/holdings_event.dart';
import '../../holdings/bloc/holdings_state.dart';
import '../../holdings/pages/orders_wallet_page.dart';
import '../../market/bloc/market_bloc.dart';
import '../../market/bloc/market_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.lightTextPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Account & Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Identity Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: activeColor,
                        child: const Text(
                          'DG',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: activeColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardSurface, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Divyesh Gami',
                              style: TextStyle(
                                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: activeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'PRO',
                                style: TextStyle(color: activeColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'divyesh.gami@trading.com',
                          style: TextStyle(color: mutedText, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Client ID: U84920 • NSE / BSE',
                          style: TextStyle(color: mutedText, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Wallet Section Header
            Text(
              'TRADING FUNDS & WALLET',
              style: TextStyle(color: mutedText, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
            ),
            const SizedBox(height: 10),

            // Embedded Wallet Card
            BlocBuilder<MarketBloc, MarketState>(
              builder: (context, feedState) {
                return BlocBuilder<HoldingsBloc, HoldingsState>(
                  builder: (context, portfolioState) {
                    final summary = summaryUseCase.execute(
                      holdings: portfolioState.holdings,
                      quotes: feedState.quotes,
                    );

                    return Container(
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
                                'Available Margin Balance',
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
                                fontSize: 28,
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
                                      const Text('Total Portfolio Value', style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 11)),
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
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Account & Preferences Section Header
            Text(
              'ACCOUNT & APP SETTINGS',
              style: TextStyle(color: mutedText, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
            ),
            const SizedBox(height: 10),

            // Settings Tile List
            Container(
              decoration: BoxDecoration(
                color: cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // Executed Orders Shortcut
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.receipt_long, color: activeColor, size: 20),
                    ),
                    title: const Text('Executed Orders & Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('View complete history of executed orders', style: TextStyle(color: mutedText, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrdersWalletPage()),
                      );
                    },
                  ),
                  Divider(color: borderColor, height: 1),

                  // Theme Toggle Tile
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, themeState) {
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: const Color(0xFFF59E0B),
                            size: 20,
                          ),
                        ),
                        title: const Text('App Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          themeState.isDarkMode ? 'Dark Mode (Groww Dark)' : 'Light Mode (Clean Slate)',
                          style: TextStyle(color: mutedText, fontSize: 12),
                        ),
                        trailing: Switch(
                          value: themeState.isDarkMode,
                          activeTrackColor: activeColor,
                          onChanged: (_) {
                            context.read<ThemeBloc>().add(ToggleThemeEvent());
                          },
                        ),
                      );
                    },
                  ),
                  Divider(color: borderColor, height: 1),

                  // Bank Account Info
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance, color: Color(0xFF3B82F6), size: 20),
                    ),
                    title: const Text('Primary Bank Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('HDFC Bank ••••••8921 (Primary)', style: TextStyle(color: mutedText, fontSize: 12)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('VERIFIED', style: TextStyle(color: activeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Divider(color: borderColor, height: 1),

                  // Demat DP ID
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.badge, color: Color(0xFF8B5CF6), size: 20),
                    ),
                    title: const Text('Demat Account (CDSL)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('BO ID: 1208160000491023', style: TextStyle(color: mutedText, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Version Badge
            Center(
              child: Column(
                children: [
                  Text(
                    'Groww Trading App',
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Version 1.0.0 (Interview Production Demo)',
                    style: TextStyle(color: mutedText, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
