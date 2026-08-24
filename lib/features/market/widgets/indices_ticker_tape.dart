import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/decimal_utils.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_state.dart';

class IndicesTickerTape extends StatelessWidget {
  const IndicesTickerTape({super.key});

  @override
  Widget build(BuildContext context) {
    final cardSurface = AppTheme.getCardSurface(context);
    final borderColor = AppTheme.getBorderColor(context);

    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, state) {
        final rel = state.quotes['RELIANCE'];
        final tcs = state.quotes['TCS'];
        final hdfc = state.quotes['HDFCBANK'];

        final double niftyVal = 24500.0 + (rel != null ? rel.change.toDouble() * 1.5 : 0.0);
        final double sensexVal = 80200.0 + (tcs != null ? tcs.change.toDouble() * 3.2 : 0.0);
        final double bankNiftyVal = 52100.0 + (hdfc != null ? hdfc.change.toDouble() * 2.8 : 0.0);

        final Decimal niftyDec = Decimal.parse(niftyVal.toStringAsFixed(2));
        final Decimal sensexDec = Decimal.parse(sensexVal.toStringAsFixed(2));
        final Decimal bankNiftyDec = Decimal.parse(bankNiftyVal.toStringAsFixed(2));

        final double niftyChg = rel != null ? rel.changePercent.toDouble() * 0.4 : 0.25;
        final double sensexChg = tcs != null ? tcs.changePercent.toDouble() * 0.4 : 0.30;
        final double bankChg = hdfc != null ? hdfc.changePercent.toDouble() * 0.5 : -0.15;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: cardSurface,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildIndexCard(context, 'NIFTY 50', niftyDec, niftyChg),
                const SizedBox(width: 10),
                _buildIndexCard(context, 'SENSEX', sensexDec, sensexChg),
                const SizedBox(width: 10),
                _buildIndexCard(context, 'BANK NIFTY', bankNiftyDec, bankChg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndexCard(BuildContext context, String title, Decimal value, double changePct) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isGain = changePct >= 0;
    final Color color = isGain ? AppTheme.getGainColor(context) : AppTheme.getLossColor(context);
    final String sign = isGain ? '+' : '';
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final borderColor = AppTheme.getBorderColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.getTextMuted(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isGain ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: color,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                DecimalUtils.formatCurrency(value, showSymbol: false),
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$sign${changePct.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
