import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import 'holdings_event.dart';
import 'holdings_state.dart';

class HoldingsBloc extends Bloc<HoldingsEvent, HoldingsState> {
  final PortfolioRepository repository;

  HoldingsBloc({required this.repository}) : super(HoldingsState()) {
    on<LoadPortfolioEvent>(_onLoadPortfolio);
    on<SetSortOptionEvent>(_onSetSortOption);
    on<ResetWalletBalanceEvent>(_onResetWalletBalance);

    add(LoadPortfolioEvent());
  }

  Future<void> _onLoadPortfolio(LoadPortfolioEvent event, Emitter<HoldingsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final balance = await repository.getWalletBalance();
      final holdings = await repository.getHoldings();
      final orders = await repository.getOrders();

      emit(state.copyWith(
        walletBalance: balance,
        holdings: holdings,
        orders: orders,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to load portfolio: $e'));
    }
  }

  void _onSetSortOption(SetSortOptionEvent event, Emitter<HoldingsState> emit) {
    emit(state.copyWith(sortOption: event.option));
  }

  Future<void> _onResetWalletBalance(ResetWalletBalanceEvent event, Emitter<HoldingsState> emit) async {
    final newBalance = event.newBalance ?? StockConstants.defaultWalletBalance;
    emit(state.copyWith(walletBalance: newBalance));
    await repository.saveWalletBalance(newBalance);
  }
}
