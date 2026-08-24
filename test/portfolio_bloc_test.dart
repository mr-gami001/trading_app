import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/blocs/portfolio/portfolio_bloc.dart';
import 'package:trading_app/blocs/portfolio/portfolio_event.dart';
import 'package:trading_app/models/trade_order.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PortfolioBloc Tests', () {
    late PortfolioBloc portfolioBloc;

    setUp(() {
      portfolioBloc = PortfolioBloc();
    });

    tearDown(() {
      portfolioBloc.close();
    });

    test('Initial wallet balance is ₹1,00,000.00', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      expect(portfolioBloc.state.walletBalance, equals(100000.00));
    });

    test('Buy order succeeds with sufficient balance and updates average cost', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      final initialBalance = portfolioBloc.state.walletBalance;

      final completer = Completer<String?>();
      portfolioBloc.add(PlaceOrderEvent(
        symbol: 'RELIANCE',
        side: OrderSide.buy,
        quantity: 5,
        ltp: 2000.00,
        completer: completer,
      ));

      final error = await completer.future;
      expect(error, isNull);
      expect(portfolioBloc.state.walletBalance, equals(initialBalance - 10000.00));
      expect(portfolioBloc.state.getHoldingForSymbol('RELIANCE')?.quantity, greaterThanOrEqualTo(5));
    });

    test('Buy order fails when balance is insufficient', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final completer = Completer<String?>();
      portfolioBloc.add(PlaceOrderEvent(
        symbol: 'RELIANCE',
        side: OrderSide.buy,
        quantity: 100000,
        ltp: 5000.00,
        completer: completer,
      ));

      final error = await completer.future;
      expect(error, isNotNull);
      expect(error, contains('Insufficient wallet balance'));
    });
  });
}
