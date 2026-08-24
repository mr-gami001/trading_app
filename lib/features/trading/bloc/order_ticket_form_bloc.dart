import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/trade_order.dart';
import 'order_ticket_form_event.dart';
import 'order_ticket_form_state.dart';

class OrderTicketFormBloc extends Bloc<OrderTicketFormEvent, OrderTicketFormState> {
  OrderTicketFormBloc({required OrderSide initialSide}) : super(OrderTicketFormState(side: initialSide)) {
    on<ChangeSideEvent>(_onChangeSide);
    on<ChangeProductTypeEvent>(_onChangeProductType);
    on<ChangeOrderTypeEvent>(_onChangeOrderType);
    on<SetFormErrorMessageEvent>(_onSetErrorMessage);
  }

  void _onChangeSide(ChangeSideEvent event, Emitter<OrderTicketFormState> emit) {
    emit(state.copyWith(side: event.side, clearError: true));
  }

  void _onChangeProductType(ChangeProductTypeEvent event, Emitter<OrderTicketFormState> emit) {
    emit(state.copyWith(productType: event.productType));
  }

  void _onChangeOrderType(ChangeOrderTypeEvent event, Emitter<OrderTicketFormState> emit) {
    emit(state.copyWith(orderType: event.orderType));
  }

  void _onSetErrorMessage(SetFormErrorMessageEvent event, Emitter<OrderTicketFormState> emit) {
    emit(state.copyWith(errorMessage: event.errorMessage));
  }
}
