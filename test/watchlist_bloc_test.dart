import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/blocs/watchlist/watchlist_bloc.dart';
import 'package:trading_app/blocs/watchlist/watchlist_event.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WatchlistBloc Tests', () {
    late WatchlistBloc watchlistBloc;

    setUp(() async {
      watchlistBloc = WatchlistBloc();
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
