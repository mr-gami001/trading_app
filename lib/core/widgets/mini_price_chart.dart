import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class MiniPriceChart extends StatelessWidget {
  final Decimal currentPrice;
  final Decimal previousClose;
  final bool isGain;
  final double height;

  const MiniPriceChart({
    super.key,
    required this.currentPrice,
    required this.previousClose,
    required this.isGain,
    this.height = 120,
  });

  List<double> _generateStablePoints() {
    final double ltp = currentPrice.toDouble();
    final double prev = previousClose.toDouble();
    // Seed with previousClose to ensure historical trend line stays 100% consistent!
    final Random random = Random(previousClose.toString().hashCode);

    final List<double> points = [prev];
    double current = prev;
    const int count = 20;

    for (int i = 1; i < count - 1; i++) {
      final double progress = i / count;
      final double target = prev + (ltp - prev) * progress * 0.3;
      final double noise = (random.nextDouble() - 0.48) * (prev * 0.005);
      current = target + noise;
      points.add(current);
    }
    // Only final point updates dynamically with live LTP tick
    points.add(ltp);
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final points = _generateStablePoints();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color chartColor = isGain
        ? (isDark ? const Color(0xFF00D09C) : const Color(0xFF00B386))
        : (isDark ? const Color(0xFFEB5757) : const Color(0xFFE53935));

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ChartPainter(
          points: points,
          color: chartColor,
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _ChartPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double minVal = points.reduce(min);
    final double maxVal = points.reduce(max);
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final Path path = Path();
    final Path fillPath = Path();

    final double stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      final double normalizedY = (points[i] - minVal) / range;
      final double y = size.height - (normalizedY * (size.height - 16) + 8);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final double prevX = (i - 1) * stepX;
        final double prevNormalizedY = (points[i - 1] - minVal) / range;
        final double prevY = size.height - (prevNormalizedY * (size.height - 16) + 8);

        final double controlX1 = prevX + stepX / 2;
        final double controlY1 = prevY;
        final double controlX2 = prevX + stepX / 2;
        final double controlY2 = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Gradient fill under curve
    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Smooth line stroke
    final Paint linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // End price dot indicator
    final double lastX = size.width;
    final double lastNormalizedY = (points.last - minVal) / range;
    final double lastY = size.height - (lastNormalizedY * (size.height - 16) + 8);

    final Paint dotPaint = Paint()..color = color;
    final Paint dotGlow = Paint()..color = color.withValues(alpha: 0.4);

    canvas.drawCircle(Offset(lastX - 2, lastY), 6, dotGlow);
    canvas.drawCircle(Offset(lastX - 2, lastY), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
