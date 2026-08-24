import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/domain/repositories/market_repository.dart';
import 'package:trading_app/features/watchlist/bloc/watchlist_bloc.dart';
import 'package:trading_app/features/watchlist/bloc/watchlist_event.dart';
import 'package:trading_app/injection_container.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    if (!sl.isRegistered<SharedPreferences>()) {
      await initDependencyInjection();
    }
  });

  tearDown(() {
    if (sl.isRegistered<MarketRepository>()) {
      sl<MarketRepository>().stopFeed();
    }
  });

  group('WatchlistBloc Tests', () {
    late WatchlistBloc watchlistBloc;

    setUp(() async {
      watchlistBloc = sl<WatchlistBloc>();
      // Allow initial async loading to settle
      await Future.delayed(const Duration(milliseconds: 200));
    });

    tearDown(() {
      watchlistBloc.close();
    });

    test('Initial state loads default watchlists', () {
      expect(watchlistBloc.state.watchlists.length, greaterThanOrEqualTo(1));
    });

    test('CreateWatchlistEvent adds a new watchlist', () async {
      watchlistBloc.add(const CreateWatchlistEvent('Tech Stocks'));
      await Future.delayed(const Duration(milliseconds: 200));

      expect(watchlistBloc.state.watchlists.any((w) => w.name == 'Tech Stocks'), isTrue);
    });

    test('AddStockToWatchlistEvent and RemoveStockFromWatchlistEvent update symbols', () async {
      watchlistBloc.add(const CreateWatchlistEvent('Test Watchlist'));
      await Future.delayed(const Duration(milliseconds: 200));

      final activeId = watchlistBloc.state.activeWatchlist!.id;

      watchlistBloc.add(AddStockToWatchlistEvent(activeId, 'RELIANCE'));
      await Future.delayed(const Duration(milliseconds: 200));

      expect(watchlistBloc.state.activeWatchlist!.symbols.contains('RELIANCE'), isTrue);

      watchlistBloc.add(RemoveStockFromWatchlistEvent(activeId, 'RELIANCE'));
      await Future.delayed(const Duration(milliseconds: 200));

      expect(watchlistBloc.state.activeWatchlist!.symbols.contains('RELIANCE'), isFalse);
    });
  });
}
