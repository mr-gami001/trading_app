import 'package:flutter_bloc/flutter_bloc.dart';
import 'stock_detail_event.dart';
import 'stock_detail_state.dart';

class StockDetailBloc extends Bloc<StockDetailEvent, StockDetailState> {
  StockDetailBloc() : super(const StockDetailState()) {
    on<ToggleChartTypeEvent>(_onToggleChartType);
  }

  void _onToggleChartType(ToggleChartTypeEvent event, Emitter<StockDetailState> emit) {
    emit(StockDetailState(chartType: event.chartType));
  }
}
