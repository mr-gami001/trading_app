import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../core/utils/decimal_utils.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../domain/entities/stock_quote.dart';
import '../../../domain/entities/trade_order.dart';
import '../../../injection_container.dart';
import '../../holdings/bloc/holdings_bloc.dart';
import '../../holdings/bloc/holdings_event.dart';
import '../../holdings/bloc/holdings_state.dart';
import '../../market/bloc/market_bloc.dart';
import '../../market/bloc/market_state.dart';
import '../../profile/pages/profile_page.dart';
import '../bloc/order_ticket_form_bloc.dart';
import '../bloc/order_ticket_form_event.dart';
import '../bloc/order_ticket_form_state.dart';
import '../bloc/trading_bloc.dart';
import '../bloc/trading_event.dart';
import '../bloc/trading_state.dart';

enum ProductType { cnc, mis }
enum OrderType { market, limit }

class BuySellTicketPage extends StatelessWidget {
  final String initialSymbol;
  final OrderSide initialSide;

  const BuySellTicketPage({
    super.key,
    required this.initialSymbol,
    this.initialSide = OrderSide.buy,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TradingBloc>(
          create: (context) => sl<TradingBloc>(),
        ),
        BlocProvider<OrderTicketFormBloc>(
          create: (context) => OrderTicketFormBloc(initialSide: initialSide),
        ),
      ],
      child: _BuySellTicketForm(
        initialSymbol: initialSymbol,
      ),
    );
  }
}

class _BuySellTicketForm extends StatefulWidget {
  final String initialSymbol;

  const _BuySellTicketForm({
    required this.initialSymbol,
  });

  @override
  State<_BuySellTicketForm> createState() => _BuySellTicketFormState();
}

class _BuySellTicketFormState extends State<_BuySellTicketForm> {
  late String _selectedSymbol;
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _limitPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSymbol = widget.initialSymbol;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _limitPriceController.dispose();
    super.dispose();
  }

  void _validateAndSubmit(StockQuote quote, HoldingsState holdingsState, OrderTicketFormState formState) {
    context.read<OrderTicketFormBloc>().add(const SetFormErrorMessageEvent(null));

    final rawQty = _quantityController.text.trim();
    final qtyVal = ValidationUtils.validateOrderQuantity(rawQty);
    if (!qtyVal.isValid) {
      context.read<OrderTicketFormBloc>().add(SetFormErrorMessageEvent(qtyVal.errorMessage));
      return;
    }

    final int quantity = int.parse(rawQty);
    final Decimal qtyDecimal = Decimal.fromInt(quantity);

    Decimal executionLtp = quote.ltp;
    if (formState.orderType == OrderType.limit && _limitPriceController.text.trim().isNotEmpty) {
      final parsedLimit = Decimal.tryParse(_limitPriceController.text.trim());
      if (parsedLimit != null && parsedLimit > Decimal.zero) {
        executionLtp = parsedLimit;
      }
    }

    final Decimal projectedValue = qtyDecimal * executionLtp;

    if (formState.side == OrderSide.buy) {
      final buyVal = ValidationUtils.validateBuyOrder(
        walletBalance: holdingsState.walletBalance,
        orderValue: projectedValue,
      );
      if (!buyVal.isValid) {
        context.read<OrderTicketFormBloc>().add(SetFormErrorMessageEvent(buyVal.errorMessage));
        return;
      }
    } else {
      final holding = holdingsState.getHoldingForSymbol(_selectedSymbol);
      final heldQty = holding?.quantity ?? 0;
      final sellVal = ValidationUtils.validateSellOrder(
        heldQuantity: heldQty,
        sellQuantity: quantity,
        symbol: _selectedSymbol,
      );
      if (!sellVal.isValid) {
        context.read<OrderTicketFormBloc>().add(SetFormErrorMessageEvent(sellVal.errorMessage));
        return;
      }
    }

    // Submit Order
    context.read<TradingBloc>().add(
          ExecuteOrderEvent(
            symbol: _selectedSymbol,
            side: formState.side,
            quantity: quantity,
            ltp: executionLtp,
          ),
        );
  }

  void _showConfirmationDialog(TradingSuccess successState, OrderTicketFormState formState) {
    final cardSurface = AppTheme.getCardSurface(context);
    final isBuy = successState.side == OrderSide.buy;
    final sideColor = isBuy ? AppTheme.getGainColor(context) : AppTheme.getLossColor(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isBuy ? Icons.check_circle : Icons.sell,
              color: sideColor,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              '${isBuy ? "BUY" : "SELL"} Executed!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Stock', '${successState.symbol} (NSE)'),
            _buildDetailRow('Product', formState.productType == ProductType.cnc ? 'CNC (Delivery)' : 'MIS (Intraday)'),
            _buildDetailRow('Order Type', formState.orderType == OrderType.market ? 'MARKET' : 'LIMIT'),
            _buildDetailRow('Quantity', '${successState.quantity} shares'),
            _buildDetailRow('Execution Price', DecimalUtils.formatCurrency(successState.executionPrice)),
            Divider(color: AppTheme.getBorderColor(context)),
            _buildDetailRow('Total Amount', DecimalUtils.formatCurrency(successState.totalValue), isBold: true),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: sideColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.getTextMuted(context), fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = AppTheme.getCardSurface(context);
    final borderColor = AppTheme.getBorderColor(context);
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final mutedText = AppTheme.getTextMuted(context);

    final stockInfo = StockConstants.supportedStocks.firstWhere(
      (s) => s.symbol == _selectedSymbol,
      orElse: () => StockConstants.supportedStocks.first,
    );

    return BlocBuilder<OrderTicketFormBloc, OrderTicketFormState>(
      builder: (context, formState) {
        final isBuy = formState.side == OrderSide.buy;
        final primaryColor = isBuy ? AppTheme.getGainColor(context) : AppTheme.getLossColor(context);

        return BlocListener<TradingBloc, TradingState>(
          listener: (context, tradingState) {
            if (tradingState is TradingSuccess) {
              context.read<HoldingsBloc>().add(LoadPortfolioEvent());
              _showConfirmationDialog(tradingState, formState);
            } else if (tradingState is TradingFailure) {
              context.read<OrderTicketFormBloc>().add(SetFormErrorMessageEvent(tradingState.errorMessage));
            }
          },
          child: Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: cardSurface,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.lightTextPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(isBuy ? Icons.shopping_bag : Icons.sell, color: primaryColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${isBuy ? "BUY" : "SELL"} $_selectedSymbol',
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stock Symbol & Live Price Header Card (Groww Style)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: primaryColor.withValues(alpha: 0.15),
                          child: Text(
                            _selectedSymbol.substring(0, min(2, _selectedSymbol.length)),
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _selectedSymbol,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Text(
                                      'NSE',
                                      style: TextStyle(color: mutedText, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                stockInfo.name,
                                style: TextStyle(color: mutedText, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        BlocSelector<MarketBloc, MarketState, StockQuote?>(
                          selector: (state) => state.quotes[_selectedSymbol],
                          builder: (context, quote) {
                            if (quote == null) return const SizedBox.shrink();
                            final isGain = quote.change >= Decimal.zero;
                            final color = isGain ? AppTheme.getGainColor(context) : AppTheme.getLossColor(context);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DecimalUtils.formatCurrency(quote.ltp),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
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
                                    DecimalUtils.formatPriceChange(quote.change, quote.changePercent),
                                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Side Switcher Segmented Toggle (BUY vs SELL)
                  BlocBuilder<HoldingsBloc, HoldingsState>(
                    builder: (context, holdingsState) {
                      final holding = holdingsState.getHoldingForSymbol(_selectedSymbol);
                      final int heldQty = holding?.quantity ?? 0;

                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  context.read<OrderTicketFormBloc>().add(const ChangeSideEvent(OrderSide.buy));
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isBuy ? AppTheme.getGainColor(context) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: isBuy
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.getGainColor(context).withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'BUY',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  context.read<OrderTicketFormBloc>().add(const ChangeSideEvent(OrderSide.sell));
                                  if (heldQty > 0) {
                                    _quantityController.text = heldQty.toString();
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !isBuy ? AppTheme.getLossColor(context) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: !isBuy
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.getLossColor(context).withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'SELL',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Product Segment Switcher (CNC vs MIS)
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
                        Text('Product Type', style: TextStyle(color: mutedText, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Column(
                                  children: [
                                    Text('Delivery (CNC)', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Hold for long term', style: TextStyle(fontSize: 10)),
                                  ],
                                ),
                                selected: formState.productType == ProductType.cnc,
                                selectedColor: primaryColor,
                                backgroundColor: bg,
                                labelStyle: TextStyle(
                                  color: formState.productType == ProductType.cnc ? Colors.white : mutedText,
                                ),
                                onSelected: (_) => context.read<OrderTicketFormBloc>().add(const ChangeProductTypeEvent(ProductType.cnc)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ChoiceChip(
                                label: const Column(
                                  children: [
                                    Text('Intraday (MIS)', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Same day auto-squareoff', style: TextStyle(fontSize: 10)),
                                  ],
                                ),
                                selected: formState.productType == ProductType.mis,
                                selectedColor: primaryColor,
                                backgroundColor: bg,
                                labelStyle: TextStyle(
                                  color: formState.productType == ProductType.mis ? Colors.white : mutedText,
                                ),
                                onSelected: (_) => context.read<OrderTicketFormBloc>().add(const ChangeProductTypeEvent(ProductType.mis)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Order Type Switcher (Market vs Limit)
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
                        Text('Order Type', style: TextStyle(color: mutedText, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Market Order', style: TextStyle(fontWeight: FontWeight.bold))),
                                selected: formState.orderType == OrderType.market,
                                selectedColor: primaryColor,
                                backgroundColor: bg,
                                labelStyle: TextStyle(
                                  color: formState.orderType == OrderType.market ? Colors.white : mutedText,
                                ),
                                onSelected: (_) => context.read<OrderTicketFormBloc>().add(const ChangeOrderTypeEvent(OrderType.market)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Limit Order', style: TextStyle(fontWeight: FontWeight.bold))),
                                selected: formState.orderType == OrderType.limit,
                                selectedColor: primaryColor,
                                backgroundColor: bg,
                                labelStyle: TextStyle(
                                  color: formState.orderType == OrderType.limit ? Colors.white : mutedText,
                                ),
                                onSelected: (_) => context.read<OrderTicketFormBloc>().add(const ChangeOrderTypeEvent(OrderType.limit)),
                              ),
                            ),
                          ],
                        ),
                        if (formState.orderType == OrderType.limit) ...[
                          const SizedBox(height: 14),
                          Divider(color: borderColor, height: 1),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text('Limit Price (₹):', style: TextStyle(color: mutedText, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: primaryColor),
                                  ),
                                  child: TextField(
                                    controller: _limitPriceController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter limit price',
                                      hintStyle: TextStyle(color: mutedText, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quantity Input & Multiplier Chips
                  BlocBuilder<HoldingsBloc, HoldingsState>(
                    builder: (context, holdingsState) {
                      final holding = holdingsState.getHoldingForSymbol(_selectedSymbol);
                      final int heldQty = holding?.quantity ?? 0;

                      return Container(
                        padding: const EdgeInsets.all(16),
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
                                Text('Quantity (Shares)', style: TextStyle(color: mutedText, fontSize: 12, fontWeight: FontWeight.bold)),
                                if (!isBuy)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (heldQty > 0 ? AppTheme.getGainColor(context) : AppTheme.getLossColor(context)).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Available: $heldQty shares',
                                      style: TextStyle(color: heldQty > 0 ? AppTheme.getGainColor(context) : AppTheme.getLossColor(context), fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Material(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      final current = int.tryParse(_quantityController.text) ?? 1;
                                      if (current > 1) {
                                        _quantityController.text = (current - 1).toString();
                                        context.read<OrderTicketFormBloc>().add(const SetFormErrorMessageEvent(null));
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Icon(Icons.remove, size: 22),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 12),
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: TextField(
                                      controller: _quantityController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                                      decoration: const InputDecoration(border: InputBorder.none),
                                      onChanged: (_) => context.read<OrderTicketFormBloc>().add(const SetFormErrorMessageEvent(null)),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      final current = int.tryParse(_quantityController.text) ?? 0;
                                      _quantityController.text = (current + 1).toString();
                                      context.read<OrderTicketFormBloc>().add(const SetFormErrorMessageEvent(null));
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Icon(Icons.add, size: 22),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (!isBuy && heldQty > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: ActionChip(
                                        backgroundColor: AppTheme.getLossColor(context).withValues(alpha: 0.15),
                                        side: BorderSide(color: AppTheme.getLossColor(context)),
                                        label: Text('SELL ALL ($heldQty)', style: TextStyle(color: AppTheme.getLossColor(context), fontWeight: FontWeight.bold, fontSize: 12)),
                                        onPressed: () {
                                          _quantityController.text = heldQty.toString();
                                          context.read<OrderTicketFormBloc>().add(const SetFormErrorMessageEvent(null));
                                        },
                                      ),
                                    ),
                                  ...[5, 10, 25, 50, 100].map((addQty) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: ActionChip(
                                        backgroundColor: bg,
                                        side: BorderSide(color: borderColor),
                                        label: Text('+$addQty', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                        onPressed: () {
                                          final current = int.tryParse(_quantityController.text) ?? 0;
                                          _quantityController.text = (current + addQty).toString();
                                          context.read<OrderTicketFormBloc>().add(const SetFormErrorMessageEvent(null));
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Margin Required & Available Cash Summary Card
                  BlocSelector<MarketBloc, MarketState, StockQuote?>(
                    selector: (state) => state.quotes[_selectedSymbol],
                    builder: (context, quote) {
                      if (quote == null) return const SizedBox.shrink();

                      return BlocBuilder<HoldingsBloc, HoldingsState>(
                        builder: (context, holdingsState) {
                          final int qty = int.tryParse(_quantityController.text.trim()) ?? 0;
                          final Decimal qtyDecimal = Decimal.fromInt(qty);
                          final Decimal orderVal = qtyDecimal * quote.ltp;
                          final holding = holdingsState.getHoldingForSymbol(_selectedSymbol);
                          final int heldQty = holding?.quantity ?? 0;

                          final bool isSellInvalid = !isBuy && (heldQty == 0 || qty > heldQty);
                          final bool isBuyInvalid = isBuy && holdingsState.walletBalance < orderVal;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardSurface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(isBuy ? 'Required Margin' : 'Estimated Value', style: TextStyle(color: mutedText, fontSize: 13)),
                                        Text(
                                          DecimalUtils.formatCurrency(orderVal),
                                          style: TextStyle(color: isDark ? Colors.white : AppTheme.lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 17),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Divider(color: borderColor, height: 1),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(isBuy ? 'Available Margin' : 'Shares Held', style: TextStyle(color: mutedText, fontSize: 13)),
                                        Row(
                                          children: [
                                            Text(
                                              isBuy
                                                  ? DecimalUtils.formatCurrency(holdingsState.walletBalance)
                                                  : '$heldQty shares',
                                              style: TextStyle(
                                                color: (isBuy && isBuyInvalid) || (!isBuy && isSellInvalid) ? AppTheme.getLossColor(context) : (isDark ? Colors.white : AppTheme.lightTextPrimary),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (isBuy && isBuyInvalid) ...[
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                                                  );
                                                },
                                                child: Text('Add Funds', style: TextStyle(color: AppTheme.getGainColor(context), fontWeight: FontWeight.bold, fontSize: 12)),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Brokerage Charges', style: TextStyle(color: mutedText, fontSize: 12)),
                                        Text(
                                          '₹0.00 (Free)',
                                          style: TextStyle(color: AppTheme.getGainColor(context), fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Real-Time Warning Banner for Sell Errors
                              if (!isBuy && heldQty == 0)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getLossColor(context).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.getLossColor(context)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: AppTheme.getLossColor(context), size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'You do not hold any shares of $_selectedSymbol. Buy shares first before selling.',
                                          style: TextStyle(color: AppTheme.getLossColor(context), fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (!isBuy && qty > heldQty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getLossColor(context).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.getLossColor(context)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: AppTheme.getLossColor(context), size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Cannot sell $qty shares. You only hold $heldQty shares of $_selectedSymbol.',
                                          style: TextStyle(color: AppTheme.getLossColor(context), fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Inline Error Banner
                              if (formState.errorMessage != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getLossColor(context).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.getLossColor(context)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, color: AppTheme.getLossColor(context), size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          formState.errorMessage!,
                                          style: TextStyle(color: AppTheme.getLossColor(context), fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Submit Action Button (Groww High-Contrast Button)
                              BlocBuilder<TradingBloc, TradingState>(
                                builder: (context, tradingState) {
                                  final isSubmitting = tradingState is TradingSubmitting;
                                  final bool isDisabled = isSubmitting || isSellInvalid || isBuyInvalid;

                                  return SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDisabled ? mutedText.withValues(alpha: 0.3) : primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        elevation: isDisabled ? 0 : 4,
                                        shadowColor: primaryColor.withValues(alpha: 0.4),
                                      ),
                                      onPressed: isDisabled ? null : () => _validateAndSubmit(quote, holdingsState, formState),
                                      child: isSubmitting
                                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(isBuy ? Icons.shopping_cart_checkout : Icons.sell, color: Colors.white, size: 22),
                                                const SizedBox(width: 10),
                                                Text(
                                                  '${isBuy ? "BUY" : "SELL"} $_selectedSymbol',
                                                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                                ),
                                              ],
                                            ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


