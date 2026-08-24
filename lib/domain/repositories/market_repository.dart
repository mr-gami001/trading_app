import '../entities/stock_quote.dart';

abstract class MarketRepository {
  Map<String, StockQuote> get currentQuotes;
  Stream<StockQuote> get tickStream;
  int get tickIntervalMs;
  bool get isStressMode;
  int get totalTicksCount;

  void startFeed();
  void stopFeed();
  void setTickInterval(int intervalMs);
  void toggleStressMode(bool enable);
  StockQuote? getQuote(String symbol);
}
