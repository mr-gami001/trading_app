import 'package:equatable/equatable.dart';
import '../pages/holdings_page.dart';

class HoldingsTabState extends Equatable {
  final PortfolioTab currentTab;
  final String searchQuery;

  const HoldingsTabState({
    this.currentTab = PortfolioTab.holdings,
    this.searchQuery = '',
  });

  HoldingsTabState copyWith({
    PortfolioTab? currentTab,
    String? searchQuery,
  }) {
    return HoldingsTabState(
      currentTab: currentTab ?? this.currentTab,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [currentTab, searchQuery];
}
