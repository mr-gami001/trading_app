import 'dart:async';
import 'dart:math';
import 'package:decimal/decimal.dart';
import '../../../core/constants/stock_constants.dart';
import '../../models/stock_quote_model.dart';

abstract class MarketDataDataSource {
  Map<String, StockQuoteModel> get currentQuotes;
  Stream<StockQuoteModel> get tickStream;
  int get tickIntervalMs;
  bool get isStressMode;
  int get totalTicksCount;

  void startFeed();
  void stopFeed();
  void setTickInterval(int intervalMs);
  void toggleStressMode(bool enable);
  StockQuoteModel? getQuote(String symbol);
}

class MarketDataDataSourceImpl implements MarketDataDataSource {
  final Map<String, StockQuoteModel> _quotes = {};
  final StreamController<StockQuoteModel> _tickController = StreamController<StockQuoteModel>.broadcast();
  Timer? _timer;
  final Random _random = Random();

  int _tickIntervalMs = 500;
  bool _isStressMode = false;
  int _totalTicksCount = 0;

  @override
  Map<String, StockQuoteModel> get currentQuotes => Map.unmodifiable(_quotes);

  @override
  Stream<StockQuoteModel> get tickStream => _tickController.stream;

  @override
  int get tickIntervalMs => _tickIntervalMs;

  @override
  bool get isStressMode => _isStressMode;

  @override
  int get totalTicksCount => _totalTicksCount;

  MarketDataDataSourceImpl() {
    _initUniverse();
    startFeed();
  }

  void _initUniverse() {
    for (final info in StockConstants.supportedStocks) {
      _quotes[info.symbol] = StockQuoteModel.fromEntity(
        StockQuoteModel.initial(
          symbol: info.symbol,
          name: info.name,
          initialPrice: info.initialPrice,
        ),
      );
    }
  }

  @override
  StockQuoteModel? getQuote(String symbol) => _quotes[symbol];

  @override
  void startFeed() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _tickIntervalMs), (_) {
      _generateTicks();
    });
  }

  @override
  void stopFeed() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void setTickInterval(int intervalMs) {
    _tickIntervalMs = intervalMs.clamp(10, 5000);
    _isStressMode = _tickIntervalMs <= 50;
    startFeed();
  }

  @override
  void toggleStressMode(bool enable) {
    _isStressMode = enable;
    _tickIntervalMs = enable ? 20 : 500; // 20ms = 50+ ticks/sec
    startFeed();
  }

  void _generateTicks() {
    if (_quotes.isEmpty) return;

    if (_isStressMode) {
      final count = _random.nextInt(3) + 2;
      for (int i = 0; i < count; i++) {
        _tickRandomStock();
      }
    } else {
      _tickRandomStock();
    }
  }

  void _tickRandomStock() {
    final symbols = _quotes.keys.toList();
    final symbol = symbols[_random.nextInt(symbols.length)];
    final currentModel = _quotes[symbol]!;

    // Random percentage drift -0.3% to +0.3%
    final double pctDouble = (_random.nextDouble() * 0.6 - 0.3) / 100;
    final double ltpDouble = currentModel.ltp.toDouble();
    double newPriceDouble = ltpDouble * (1 + pctDouble);

    if ((newPriceDouble - ltpDouble).abs() < 0.05) {
      final delta = _random.nextBool() ? 0.25 : -0.25;
      newPriceDouble += delta;
    }

    if (newPriceDouble < 1.0) newPriceDouble = 1.0;

    final Decimal newLtp = Decimal.parse(newPriceDouble.toStringAsFixed(2));
    final StockQuoteModel updated = StockQuoteModel.fromEntity(currentModel.updatePrice(newLtp));

    _quotes[symbol] = updated;
    _tickController.add(updated);
    _totalTicksCount++;
  }
}
