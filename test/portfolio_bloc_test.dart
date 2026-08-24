import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/domain/repositories/market_repository.dart';
import 'package:trading_app/features/holdings/bloc/holdings_bloc.dart';
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

  group('PortfolioBloc Tests', () {
    late HoldingsBloc holdingsBloc;

    setUp(() {
      holdingsBloc = sl<HoldingsBloc>();
    });

    tearDown(() {
      holdingsBloc.close();
    });

    test('Initial wallet balance is ₹10,00,000.00', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      expect(holdingsBloc.state.walletBalance, equals(StockConstants.defaultWalletBalance));
    });
  });
}
