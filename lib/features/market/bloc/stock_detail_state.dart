import 'package:equatable/equatable.dart';
import '../widgets/stock_detail_bottom_sheet.dart';

class StockDetailState extends Equatable {
  final ChartType chartType;

  const StockDetailState({this.chartType = ChartType.candlestick});

  @override
  List<Object?> get props => [chartType];
}
