import 'package:equatable/equatable.dart';

class MarketFilterState extends Equatable {
  final String searchQuery;
  final String activeFilter;

  const MarketFilterState({
    this.searchQuery = '',
    this.activeFilter = 'All',
  });

  MarketFilterState copyWith({
    String? searchQuery,
    String? activeFilter,
  }) {
    return MarketFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [searchQuery, activeFilter];
}
