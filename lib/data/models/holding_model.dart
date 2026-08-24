import 'package:decimal/decimal.dart';
import '../../domain/entities/holding.dart';

class HoldingModel extends Holding {
  const HoldingModel({
    required super.symbol,
    required super.quantity,
    required super.avgCost,
  });

  factory HoldingModel.fromEntity(Holding entity) {
    return HoldingModel(
      symbol: entity.symbol,
      quantity: entity.quantity,
      avgCost: entity.avgCost,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'quantity': quantity,
        'avgCost': avgCost.toString(),
      };

  factory HoldingModel.fromJson(Map<String, dynamic> json) => HoldingModel(
        symbol: json['symbol'] as String,
        quantity: json['quantity'] as int,
        avgCost: Decimal.parse(json['avgCost'].toString()),
      );
}
