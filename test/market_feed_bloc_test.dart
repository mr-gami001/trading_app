import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/domain/repositories/market_repository.dart';
import 'package:trading_app/features/market/bloc/market_bloc.dart';
import 'package:trading_app/features/market/bloc/market_event.dart';
import 'package:trading_app/injection_container.dart';

void main() {
  group('MarketBloc Tests', () {
    late MarketBloc marketBloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      if (!sl.isRegistered<SharedPreferences>()) {
        await initDependencyInjection();
      }
      marketBloc = sl<MarketBloc>();
    });

    tearDown(() {
      sl<MarketRepository>().stopFeed();
      marketBloc.close();
    });

    test('Initial state contains quotes for stock universe', () {
      expect(marketBloc.state.quotes.length, greaterThan(0));
    });

    test('ToggleStressModeEvent updates stress mode state correctly', () async {
      marketBloc.add(const ToggleStressModeEvent(true));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(marketBloc.state.isStressMode, isTrue);
    });
  });
}
