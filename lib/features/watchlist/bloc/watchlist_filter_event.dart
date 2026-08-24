import 'package:equatable/equatable.dart';

abstract class WatchlistFilterEvent extends Equatable {
  const WatchlistFilterEvent();

  @override
  List<Object?> get props => [];
}

class UpdateWatchlistSearchQueryEvent extends WatchlistFilterEvent {
  final String query;

  const UpdateWatchlistSearchQueryEvent(this.query);

  @override
  List<Object?> get props => [query];
}
