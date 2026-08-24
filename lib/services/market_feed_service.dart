import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/stock_quote.dart';

class InitialStockData {
  final String symbol;
  final String name;
  final double initialPrice;

  const InitialStockData(this.symbol, this.name, this.initialPrice);
}

class MarketFeedService extends ChangeNotifier {
  static final List<InitialStockData> initialUniverse = [
    const InitialStockData('RELIANCE', 'Reliance Industries Ltd.', 2950.50),
    const InitialStockData('TCS', 'Tata Consultancy Services', 4120.00),
    const InitialStockData('INFY', 'Infosys Ltd.', 1850.25),
    const InitialStockData('HDFCBANK', 'HDFC Bank Ltd.', 1620.00),
    const InitialStockData('ICICIBANK', 'ICICI Bank Ltd.', 1180.75),
    const InitialStockData('SBIN', 'State Bank of India', 840.50),
    const InitialStockData('ITC', 'ITC Ltd.', 490.00),
    const InitialStockData('LT', 'Larsen & Toubro Ltd.', 3650.00),
    const InitialStockData('BHARTIARTL', 'Bharti Airtel Ltd.', 1475.25),
    const InitialStockData('AXISBANK', 'Axis Bank Ltd.', 1170.00),
  ];

  final Map<String, StockQuote> _quotes = {};
  final Map<String, ValueNotifier<StockQuote>> _stockNotifiers = {};
  final StreamController<StockQuote> _tickStreamController = StreamController<StockQuote>.broadcast();

  Timer? _timer;
  final Random _random = Random();

  int _tickIntervalMs = 500; // Normal rate: 500ms per tick
  bool _isStressMode = false;
  int _totalTicksCount = 0;

  Map<String, StockQuote> get quotes => Map.unmodifiable(_quotes);
  Stream<StockQuote> get tickStream => _tickStreamController.stream;
  int get tickIntervalMs => _tickIntervalMs;
  bool get isStressMode => _isStressMode;
  int get totalTicksCount => _totalTicksCount;

  MarketFeedService() {
    _initUniverse();
    startFeed();
  }

  void _initUniverse() {
    for (final item in initialUniverse) {
      final quote = StockQuote.initial(
        symbol: item.symbol,
        name: item.name,
        initialPrice: item.initialPrice,
      );
      _quotes[item.symbol] = quote;
      _stockNotifiers[item.symbol] = ValueNotifier<StockQuote>(quote);
    }
  }

  ValueNotifier<StockQuote>? getNotifierForSymbol(String symbol) {
    return _stockNotifiers[symbol];
  }

  StockQuote? getQuote(String symbol) => _quotes[symbol];

  void startFeed() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _tickIntervalMs), (_) {
      _generateNextTick();
    });
  }

  void stopFeed() {
    _timer?.cancel();
    _timer = null;
  }

  void setTickIntervalMs(int ms) {
    _tickIntervalMs = ms.clamp(10, 5000);
    _isStressMode = _tickIntervalMs <= 50;
    startFeed();
    notifyListeners();
  }

  void toggleStressMode(bool enable) {
    _isStressMode = enable;
    _tickIntervalMs = enable ? 20 : 500; // 20ms = 50 ticks/sec
    startFeed();
    notifyListeners();
  }

  void _generateNextTick() {
    if (_quotes.isEmpty) return;

    if (_isStressMode) {
      // In stress mode emit ticks for 2 to 4 random stocks at once
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
    final currentQuote = _quotes[symbol]!;

    // Random walk calculation: -0.3% to +0.3% price change
    final percentChange = (_random.nextDouble() * 0.6 - 0.3) / 100;
    double newPrice = currentQuote.ltp * (1 + percentChange);
    
    // Slight tick offset ensuring visible 2-decimal movement
    if ((newPrice - currentQuote.ltp).abs() < 0.05) {
      final delta = (_random.nextBool() ? 0.25 : -0.25);
      newPrice += delta;
    }
    
    // Ensure positive price
    if (newPrice < 1.0) newPrice = 1.0;

    final updatedQuote = currentQuote.updatePrice(newPrice);
    _quotes[symbol] = updatedQuote;
    _stockNotifiers[symbol]?.value = updatedQuote;
    _tickStreamController.add(updatedQuote);
    _totalTicksCount++;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tickStreamController.close();
    for (final notifier in _stockNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }
}
