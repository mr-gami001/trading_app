import 'package:flutter_bloc/flutter_bloc.dart';
import 'watchlist_filter_event.dart';
import 'watchlist_filter_state.dart';

class WatchlistFilterBloc extends Bloc<WatchlistFilterEvent, WatchlistFilterState> {
  WatchlistFilterBloc() : super(const WatchlistFilterState()) {
    on<UpdateWatchlistSearchQueryEvent>(_onUpdateSearchQuery);
  }

  void _onUpdateSearchQuery(UpdateWatchlistSearchQueryEvent event, Emitter<WatchlistFilterState> emit) {
    emit(WatchlistFilterState(searchQuery: event.query));
  }
}
