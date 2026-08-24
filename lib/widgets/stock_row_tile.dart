import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/market_feed/market_feed_bloc.dart';
import '../blocs/market_feed/market_feed_state.dart';
import '../models/stock_quote.dart';
import '../utils/formatters.dart';

class StockRowTile extends StatefulWidget {
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

  @override
  State<StockRowTile> createState() => _StockRowTileState();
}

class _StockRowTileState extends State<StockRowTile> with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late ValueNotifier<Animation<Color?>> _flashAnimationNotifier;
  StockQuote? _previousQuote;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flashAnimationNotifier = ValueNotifier<Animation<Color?>>(
      ColorTween(
        begin: Colors.transparent,
        end: Colors.transparent,
      ).animate(_flashController),
    );
  }

  void _triggerFlash(bool isUp) {
    if (!mounted) return;
    final flashColor = isUp
        ? const Color(0x3322C55E) // Green flash
        : const Color(0x33EF4444); // Red flash

    _flashAnimationNotifier.value = ColorTween(
      begin: flashColor,
      end: Colors.transparent,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    ));
    _flashController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _flashController.dispose();
    _flashAnimationNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarketFeedBloc, MarketFeedState, StockQuote?>(
      selector: (state) => state.quotes[widget.symbol],
      builder: (context, quote) {
        if (quote == null) return const SizedBox.shrink();

        if (_previousQuote != null && _previousQuote!.ltp != quote.ltp) {
          final bool isUp = quote.ltp > _previousQuote!.ltp;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _triggerFlash(isUp);
          });
        }
        _previousQuote = quote;

        final isPositive = quote.change >= 0;
        final color = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

        return ValueListenableBuilder<Animation<Color?>>(
          valueListenable: _flashAnimationNotifier,
          builder: (context, flashAnim, _) {
            return AnimatedBuilder(
              animation: _flashController,
              builder: (context, child) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: flashAnim.value,
                        border: const Border(
                          bottom: BorderSide(color: Color(0xFF334155), width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (widget.isReorderable)
                            const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(Icons.drag_indicator, color: Color(0xFF64748B)),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quote.symbol,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  quote.name,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
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
                                Formatters.currency(quote.ltp),
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  Formatters.priceChange(quote.change, quote.changePercent),
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (widget.trailingWidget != null) ...[
                            const SizedBox(width: 8),
                            widget.trailingWidget!,
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
