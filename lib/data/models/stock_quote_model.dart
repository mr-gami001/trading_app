import 'package:decimal/decimal.dart';
import '../../domain/entities/stock_quote.dart';

class StockQuoteModel extends StockQuote {
  const StockQuoteModel({
    required super.symbol,
    required super.name,
    required super.ltp,
    required super.previousClose,
    required super.change,
    required super.changePercent,
    super.isUp,
    required super.lastUpdated,
    required super.initialPrice,
  });

  factory StockQuoteModel.initial({
    required String symbol,
    required String name,
    required Decimal initialPrice,
  }) {
    return StockQuoteModel(
      symbol: symbol,
      name: name,
      ltp: initialPrice,
      previousClose: initialPrice,
      change: Decimal.zero,
      changePercent: Decimal.zero,
      isUp: null,
      lastUpdated: DateTime.now(),
      initialPrice: initialPrice,
    );
  }

  factory StockQuoteModel.fromEntity(StockQuote entity) {
    return StockQuoteModel(
      symbol: entity.symbol,
      name: entity.name,
      ltp: entity.ltp,
      previousClose: entity.previousClose,
      change: entity.change,
      changePercent: entity.changePercent,
      isUp: entity.isUp,
      lastUpdated: entity.lastUpdated,
      initialPrice: entity.initialPrice,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'ltp': ltp.toString(),
        'previousClose': previousClose.toString(),
        'change': change.toString(),
        'changePercent': changePercent.toString(),
        'lastUpdated': lastUpdated.toIso8601String(),
        'initialPrice': initialPrice.toString(),
      };

  factory StockQuoteModel.fromJson(Map<String, dynamic> json) => StockQuoteModel(
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        ltp: Decimal.parse(json['ltp'].toString()),
        previousClose: Decimal.parse(json['previousClose'].toString()),
        change: Decimal.parse(json['change'].toString()),
        changePercent: Decimal.parse(json['changePercent'].toString()),
        isUp: null,
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
        initialPrice: json['initialPrice'] != null ? Decimal.parse(json['initialPrice'].toString()) : Decimal.parse(json['ltp'].toString()),
      );
}
