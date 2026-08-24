import '../../domain/entities/watchlist.dart';

class WatchlistModel extends Watchlist {
  const WatchlistModel({
    required super.id,
    required super.name,
    required super.symbols,
  });

  factory WatchlistModel.fromEntity(Watchlist entity) {
    return WatchlistModel(
      id: entity.id,
      name: entity.name,
      symbols: entity.symbols,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbols': symbols,
      };

  factory WatchlistModel.fromJson(Map<String, dynamic> json) => WatchlistModel(
        id: json['id'] as String,
        name: json['name'] as String,
        symbols: List<String>.from(json['symbols'] as List),
      );
}
