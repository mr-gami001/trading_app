import 'package:equatable/equatable.dart';

class Watchlist extends Equatable {
  final String id;
  final String name;
  final List<String> symbols;

  const Watchlist({
    required this.id,
    required this.name,
    required this.symbols,
  });

  Watchlist copyWith({
    String? id,
    String? name,
    List<String>? symbols,
  }) {
    return Watchlist(
      id: id ?? this.id,
      name: name ?? this.name,
      symbols: symbols ?? List.from(this.symbols),
    );
  }

  @override
  List<Object?> get props => [id, name, symbols];
}
