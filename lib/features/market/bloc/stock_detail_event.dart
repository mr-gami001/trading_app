import 'package:equatable/equatable.dart';
import '../widgets/stock_detail_bottom_sheet.dart';

abstract class StockDetailEvent extends Equatable {
  const StockDetailEvent();

  @override
  List<Object?> get props => [];
}

class ToggleChartTypeEvent extends StockDetailEvent {
  final ChartType chartType;

  const ToggleChartTypeEvent(this.chartType);

  @override
  List<Object?> get props => [chartType];
}
