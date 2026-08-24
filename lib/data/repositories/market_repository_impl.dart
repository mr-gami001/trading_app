import '../../domain/entities/stock_quote.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market/market_data_datasource.dart';

class MarketRepositoryImpl implements MarketRepository {
  final MarketDataDataSource dataSource;

  MarketRepositoryImpl({required this.dataSource});

  @override
  Map<String, StockQuote> get currentQuotes => dataSource.currentQuotes;

  @override
  Stream<StockQuote> get tickStream => dataSource.tickStream;

  @override
  int get tickIntervalMs => dataSource.tickIntervalMs;

  @override
  bool get isStressMode => dataSource.isStressMode;

  @override
  int get totalTicksCount => dataSource.totalTicksCount;

  @override
  void startFeed() => dataSource.startFeed();

  @override
  void stopFeed() => dataSource.stopFeed();

  @override
  void setTickInterval(int intervalMs) => dataSource.setTickInterval(intervalMs);

  @override
  void toggleStressMode(bool enable) => dataSource.toggleStressMode(enable);

  @override
  StockQuote? getQuote(String symbol) => dataSource.getQuote(symbol);
}
