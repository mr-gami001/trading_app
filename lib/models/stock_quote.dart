class StockQuote {
  final String symbol;
  final String name;
  final double ltp;
  final double previousClose;
  final double change;
  final double changePercent;
  final bool? isUp; // null = initial, true = green flash, false = red flash
  final DateTime lastUpdated;

  const StockQuote({
    required this.symbol,
    required this.name,
    required this.ltp,
    required this.previousClose,
    required this.change,
    required this.changePercent,
    this.isUp,
    required this.lastUpdated,
  });

  factory StockQuote.initial({
    required String symbol,
    required String name,
    required double initialPrice,
  }) {
    return StockQuote(
      symbol: symbol,
      name: name,
      ltp: initialPrice,
      previousClose: initialPrice,
      change: 0.0,
      changePercent: 0.0,
      isUp: null,
      lastUpdated: DateTime.now(),
    );
  }

  StockQuote updatePrice(double newLtp) {
    final double newChange = newLtp - previousClose;
    final double newChangePct = (previousClose > 0) ? (newChange / previousClose) * 100 : 0.0;
    bool? direction;
    if (newLtp > ltp) {
      direction = true;
    } else if (newLtp < ltp) {
      direction = false;
    } else {
      direction = isUp;
    }

    return StockQuote(
      symbol: symbol,
      name: name,
      ltp: double.parse(newLtp.toStringAsFixed(2)),
      previousClose: previousClose,
      change: double.parse(newChange.toStringAsFixed(2)),
      changePercent: double.parse(newChangePct.toStringAsFixed(2)),
      isUp: direction,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'ltp': ltp,
        'previousClose': previousClose,
        'change': change,
        'changePercent': changePercent,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory StockQuote.fromJson(Map<String, dynamic> json) => StockQuote(
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        ltp: (json['ltp'] as num).toDouble(),
        previousClose: (json['previousClose'] as num).toDouble(),
        change: (json['change'] as num).toDouble(),
        changePercent: (json['changePercent'] as num).toDouble(),
        isUp: null,
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      );
}
