import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class CandleData {
  final double open;
  final double high;
  final double low;
  final double close;

  const CandleData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  bool get isBullish => close >= open;
}

class CandlestickChart extends StatelessWidget {
  final Decimal currentPrice;
  final Decimal previousClose;
  final double height;

  const CandlestickChart({
    super.key,
    required this.currentPrice,
    required this.previousClose,
    this.height = 140,
  });

  List<CandleData> _generateStableCandles() {
    final double ltp = currentPrice.toDouble();
    final double prev = previousClose.toDouble();

    // Deterministic random generator seeded with previousClose
    // Ensures historical candles (0 to N-2) remain 100% stable and fixed!
    final Random random = Random(previousClose.toString().hashCode);

    final List<CandleData> candles = [];
    const int count = 16;

    // Start baseline and target close for historical candles (0 to 14) based on previousClose
    final double startPrice = prev * 0.994;
    final double targetCloseBeforeLive = prev;
    final double stepDelta = (targetCloseBeforeLive - startPrice) / (count - 1);

    double lastClose = startPrice;

    for (int i = 0; i < count; i++) {
      if (i == count - 1) {
        // Active 16th Live Candle: Open is previous candle close, Close is live LTP tick
        final double open = lastClose;
        final double close = ltp;
        final double wickOffset = max(0.40, prev * 0.001);
        final double high = max(open, close) + wickOffset;
        final double low = min(open, close) - wickOffset;
        candles.add(CandleData(open: open, high: high, low: low, close: close));
      } else {
        // Historical Stable Candles (0 to 14): Fixed walk from startPrice to prev
        final double noise = (random.nextDouble() - 0.48) * (prev * 0.003);
        final double open = lastClose;
        final double close = startPrice + (stepDelta * (i + 1)) + noise;
        final double wickNoise = max(0.30, random.nextDouble() * prev * 0.0015);
        final double high = max(open, close) + wickNoise;
        final double low = min(open, close) - wickNoise;

        candles.add(CandleData(open: open, high: high, low: low, close: close));
        lastClose = close;
      }
    }
    return candles;
  }

  @override
  Widget build(BuildContext context) {
    final candles = _generateStableCandles();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = isDark ? const Color(0xFF2A2E39) : const Color(0xFFE2E8F0);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _CandlestickPainter(
          candles: candles,
          gridColor: gridColor,
        ),
      ),
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  final List<CandleData> candles;
  final Color gridColor;

  _CandlestickPainter({required this.candles, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    double minPrice = candles.first.low;
    double maxPrice = candles.first.high;

    for (final c in candles) {
      if (c.low < minPrice) minPrice = c.low;
      if (c.high > maxPrice) maxPrice = c.high;
    }

    double priceRange = maxPrice - minPrice;
    if (priceRange < 1.0) priceRange = 1.0;

    // Add padding top and bottom for visual breathing space
    minPrice -= priceRange * 0.10;
    maxPrice += priceRange * 0.10;
    priceRange = maxPrice - minPrice;

    final double chartWidth = size.width - 55; // Leave right margin for live price badge
    final double stepX = chartWidth / candles.length;
    final double candleWidth = max(5.0, stepX * 0.60);

    // Draw horizontal grid lines
    final Paint gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 3; i++) {
      final double y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    // Draw Candlesticks
    for (int i = 0; i < candles.length; i++) {
      final c = candles[i];
      final double centerX = (i * stepX) + (stepX / 2);

      final double highY = size.height - (((c.high - minPrice) / priceRange) * size.height);
      final double lowY = size.height - (((c.low - minPrice) / priceRange) * size.height);
      final double openY = size.height - (((c.open - minPrice) / priceRange) * size.height);
      final double closeY = size.height - (((c.close - minPrice) / priceRange) * size.height);

      final Color candleColor = c.isBullish ? const Color(0xFF00D09C) : const Color(0xFFEB5757);

      // Draw Wick Line
      final Paint wickPaint = Paint()
        ..color = candleColor
        ..strokeWidth = 1.5;

      canvas.drawLine(Offset(centerX, highY), Offset(centerX, lowY), wickPaint);

      // Draw Candle Body Box
      final Paint bodyPaint = Paint()
        ..color = candleColor
        ..style = PaintingStyle.fill;

      final double bodyTop = min(openY, closeY);
      final double bodyBottom = max(openY, closeY);
      final double bodyHeight = max(2.5, bodyBottom - bodyTop);

      final Rect bodyRect = Rect.fromLTWH(
        centerX - (candleWidth / 2),
        bodyTop,
        candleWidth,
        bodyHeight,
      );

      canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(1.5)), bodyPaint);
    }

    // Live Price Line & Sliding Badge
    final double lastPriceY = size.height - (((candles.last.close - minPrice) / priceRange) * size.height);
    final Color lastColor = candles.last.isBullish ? const Color(0xFF00D09C) : const Color(0xFFEB5757);

    final Paint linePaint = Paint()
      ..color = lastColor.withValues(alpha: 0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, lastPriceY), Offset(chartWidth, lastPriceY), linePaint);

    // Live Price Badge Box on the Right Margin
    final TextSpan textSpan = TextSpan(
      text: candles.last.close.toStringAsFixed(2),
      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
    );
    final TextPainter tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    final RRect badgeRRect = RRect.fromLTRBR(
      chartWidth + 2,
      lastPriceY - 9,
      size.width,
      lastPriceY + 9,
      const Radius.circular(4),
    );

    canvas.drawRRect(badgeRRect, Paint()..color = lastColor);
    tp.paint(canvas, Offset(chartWidth + 5, lastPriceY - 6));
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) => true;
}
