import 'package:equatable/equatable.dart';

abstract class MarketFilterEvent extends Equatable {
  const MarketFilterEvent();

  @override
  List<Object?> get props => [];
}

class UpdateSearchQueryEvent extends MarketFilterEvent {
  final String query;

  const UpdateSearchQueryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectFilterChipEvent extends MarketFilterEvent {
  final String filter;

  const SelectFilterChipEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}
