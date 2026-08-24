import 'package:equatable/equatable.dart';
import '../../../domain/entities/trade_order.dart';
import '../pages/buy_sell_ticket_page.dart';

class OrderTicketFormState extends Equatable {
  final OrderSide side;
  final ProductType productType;
  final OrderType orderType;
  final String? errorMessage;

  const OrderTicketFormState({
    required this.side,
    this.productType = ProductType.cnc,
    this.orderType = OrderType.market,
    this.errorMessage,
  });

  OrderTicketFormState copyWith({
    OrderSide? side,
    ProductType? productType,
    OrderType? orderType,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrderTicketFormState(
      side: side ?? this.side,
      productType: productType ?? this.productType,
      orderType: orderType ?? this.orderType,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [side, productType, orderType, errorMessage];
}
