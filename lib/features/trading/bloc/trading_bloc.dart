import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/trading/place_order_usecase.dart';
import 'trading_event.dart';
import 'trading_state.dart';

class TradingBloc extends Bloc<TradingEvent, TradingState> {
  final PlaceOrderUseCase placeOrderUseCase;

  TradingBloc({required this.placeOrderUseCase}) : super(TradingInitial()) {
    on<ExecuteOrderEvent>(_onExecuteOrder);
    on<ResetTradingStateEvent>(_onResetState);
  }

  Future<void> _onExecuteOrder(ExecuteOrderEvent event, Emitter<TradingState> emit) async {
    emit(TradingSubmitting());

    final failure = await placeOrderUseCase.execute(
      PlaceOrderParams(
        symbol: event.symbol,
        side: event.side,
        quantity: event.quantity,
        executionLtp: event.ltp,
      ),
    );

    if (failure != null) {
      emit(TradingFailure(failure.message));
    } else {
      final Decimal qtyDecimal = Decimal.fromInt(event.quantity);
      final Decimal totalVal = qtyDecimal * event.ltp;
      emit(TradingSuccess(
        symbol: event.symbol,
        side: event.side,
        quantity: event.quantity,
        executionPrice: event.ltp,
        totalValue: totalVal,
      ));
    }
  }

  void _onResetState(ResetTradingStateEvent event, Emitter<TradingState> emit) {
    emit(TradingInitial());
  }
}
