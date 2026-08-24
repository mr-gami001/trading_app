import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../utils/decimal_utils.dart';

class MarketDepthEntry {
  final Decimal price;
  final int quantity;
  final int orders;

  const MarketDepthEntry({
    required this.price,
    required this.quantity,
    required this.orders,
  });
}

class MarketDepthWidget extends StatelessWidget {
  final Decimal ltp;

  const MarketDepthWidget({super.key, required this.ltp});

  List<MarketDepthEntry> _generateBids() {
    final double basePrice = ltp.toDouble();
    final Random random = Random((basePrice * 100).toInt());
    final List<MarketDepthEntry> bids = [];

    for (int i = 1; i <= 5; i++) {
      final double p = basePrice - (i * 0.25) - (random.nextDouble() * 0.1);
      final int qty = (random.nextInt(15) + 1) * 25;
      final int orders = random.nextInt(5) + 1;
      bids.add(MarketDepthEntry(
        price: Decimal.parse(p.toStringAsFixed(2)),
        quantity: qty,
        orders: orders,
      ));
    }
    return bids;
  }

  List<MarketDepthEntry> _generateAsks() {
    final double basePrice = ltp.toDouble();
    final Random random = Random((basePrice * 100).toInt() + 1);
    final List<MarketDepthEntry> asks = [];

    for (int i = 1; i <= 5; i++) {
      final double p = basePrice + (i * 0.25) + (random.nextDouble() * 0.1);
      final int qty = (random.nextInt(15) + 1) * 25;
      final int orders = random.nextInt(5) + 1;
      asks.add(MarketDepthEntry(
        price: Decimal.parse(p.toStringAsFixed(2)),
        quantity: qty,
        orders: orders,
      ));
    }
    return asks;
  }

  @override
  Widget build(BuildContext context) {
    final bids = _generateBids();
    final asks = _generateAsks();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = AppTheme.getCardSurface(context);
    final borderColor = AppTheme.getBorderColor(context);
    final mutedText = AppTheme.getTextMuted(context);
    final gainColor = AppTheme.getGainColor(context);
    final lossColor = AppTheme.getLossColor(context);

    final int totalBidQty = bids.fold(0, (sum, item) => sum + item.quantity);
    final int totalAskQty = asks.fold(0, (sum, item) => sum + item.quantity);
    final int grandTotal = (totalBidQty + totalAskQty) == 0 ? 1 : (totalBidQty + totalAskQty);
    final double buyRatio = totalBidQty / grandTotal;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Market Depth (5 Bids / 5 Asks)',
                  style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('LADDER', style: TextStyle(color: mutedText, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Depth Header Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: Text('Bid Qty', style: TextStyle(color: mutedText, fontSize: 11))),
                    Expanded(child: Text('Bid Price', textAlign: TextAlign.right, style: TextStyle(color: mutedText, fontSize: 11))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: Text('Ask Price', style: TextStyle(color: mutedText, fontSize: 11))),
                    Expanded(child: Text('Ask Qty', textAlign: TextAlign.right, style: TextStyle(color: mutedText, fontSize: 11))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Divider(color: borderColor, height: 1),

          // 5 Depth Rows
          ...List.generate(5, (index) {
            final bid = bids[index];
            final ask = asks[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      decoration: BoxDecoration(
                        color: gainColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text('${bid.quantity}', style: TextStyle(color: mutedText, fontSize: 11))),
                          Expanded(
                            child: Text(
                              DecimalUtils.formatCurrency(bid.price, showSymbol: false),
                              textAlign: TextAlign.right,
                              style: TextStyle(color: gainColor, fontWeight: FontWeight.w600, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      decoration: BoxDecoration(
                        color: lossColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DecimalUtils.formatCurrency(ask.price, showSymbol: false),
                              style: TextStyle(color: lossColor, fontWeight: FontWeight.w600, fontSize: 11),
                            ),
                          ),
                          Expanded(child: Text('${ask.quantity}', textAlign: TextAlign.right, style: TextStyle(color: mutedText, fontSize: 11))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 8),

          // Total Buy vs Total Sell Progress Bar
          Row(
            children: [
              Expanded(
                child: Text(
                  'Buy: $totalBidQty (${(buyRatio * 100).toStringAsFixed(1)}%)',
                  style: TextStyle(color: gainColor, fontSize: 11, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sell: $totalAskQty (${((1 - buyRatio) * 100).toStringAsFixed(1)}%)',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: lossColor, fontSize: 11, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: buyRatio,
              minHeight: 6,
              backgroundColor: lossColor,
              valueColor: AlwaysStoppedAnimation<Color>(gainColor),
            ),
          ),
        ],
      ),
    );
  }
}
