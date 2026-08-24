import 'package:equatable/equatable.dart';
import '../../../domain/entities/trade_order.dart';
import '../pages/buy_sell_ticket_page.dart';

abstract class OrderTicketFormEvent extends Equatable {
  const OrderTicketFormEvent();

  @override
  List<Object?> get props => [];
}

class ChangeSideEvent extends OrderTicketFormEvent {
  final OrderSide side;

  const ChangeSideEvent(this.side);

  @override
  List<Object?> get props => [side];
}

class ChangeProductTypeEvent extends OrderTicketFormEvent {
  final ProductType productType;

  const ChangeProductTypeEvent(this.productType);

  @override
  List<Object?> get props => [productType];
}

class ChangeOrderTypeEvent extends OrderTicketFormEvent {
  final OrderType orderType;

  const ChangeOrderTypeEvent(this.orderType);

  @override
  List<Object?> get props => [orderType];
}

class SetFormErrorMessageEvent extends OrderTicketFormEvent {
  final String? errorMessage;

  const SetFormErrorMessageEvent(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
