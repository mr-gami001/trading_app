import 'package:flutter_bloc/flutter_bloc.dart';
import 'holdings_tab_event.dart';
import 'holdings_tab_state.dart';

class HoldingsTabBloc extends Bloc<HoldingsTabEvent, HoldingsTabState> {
  HoldingsTabBloc() : super(const HoldingsTabState()) {
    on<SelectPortfolioTabEvent>(_onSelectTab);
    on<UpdateHoldingsSearchQueryEvent>(_onUpdateSearchQuery);
  }

  void _onSelectTab(SelectPortfolioTabEvent event, Emitter<HoldingsTabState> emit) {
    emit(state.copyWith(currentTab: event.tab));
  }

  void _onUpdateSearchQuery(UpdateHoldingsSearchQueryEvent event, Emitter<HoldingsTabState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }
}
