import 'package:equatable/equatable.dart';

class WatchlistFilterState extends Equatable {
  final String searchQuery;

  const WatchlistFilterState({this.searchQuery = ''});

  @override
  List<Object?> get props => [searchQuery];
}
