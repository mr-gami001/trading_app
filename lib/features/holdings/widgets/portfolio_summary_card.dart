import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/decimal_utils.dart';
import '../../../domain/usecases/holdings/get_portfolio_summary_usecase.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final PortfolioSummary summary;

  const PortfolioSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isPnlPositive = summary.totalPnl >= Decimal.zero;
    final pnlColor = isPnlPositive ? const Color(0xFF00D09C) : const Color(0xFFEB5757);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2E39)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Value',
            style: TextStyle(color: Color(0xFF8A8D93), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            DecimalUtils.formatCurrency(summary.totalCurrentValue),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2A2E39), height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invested Value',
                    style: TextStyle(color: Color(0xFF8A8D93), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DecimalUtils.formatCurrency(summary.totalInvested),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total Returns (P&L)',
                    style: TextStyle(color: Color(0xFF8A8D93), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DecimalUtils.formatCurrency(summary.totalPnl),
                        style: TextStyle(
                          color: pnlColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${isPnlPositive ? "+" : ""}${summary.totalPnlPercent.toDouble().toStringAsFixed(2)}%)',
                        style: TextStyle(
                          color: pnlColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
