import 'package:flutter_bloc/flutter_bloc.dart';
import 'market_filter_event.dart';
import 'market_filter_state.dart';

class MarketFilterBloc extends Bloc<MarketFilterEvent, MarketFilterState> {
  MarketFilterBloc() : super(const MarketFilterState()) {
    on<UpdateSearchQueryEvent>(_onUpdateSearchQuery);
    on<SelectFilterChipEvent>(_onSelectFilterChip);
  }

  void _onUpdateSearchQuery(UpdateSearchQueryEvent event, Emitter<MarketFilterState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onSelectFilterChip(SelectFilterChipEvent event, Emitter<MarketFilterState> emit) {
    emit(state.copyWith(activeFilter: event.filter));
  }
}
