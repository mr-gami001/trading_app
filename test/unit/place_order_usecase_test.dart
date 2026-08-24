import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/data/datasources/local/portfolio_local_datasource.dart';
import 'package:trading_app/data/repositories/portfolio_repository_impl.dart';
import 'package:trading_app/domain/entities/trade_order.dart';
import 'package:trading_app/domain/usecases/trading/place_order_usecase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PlaceOrderUseCase Integration Tests', () {
    late PlaceOrderUseCase placeOrderUseCase;
    late PortfolioRepositoryImpl repository;

    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      final localDataSource = PortfolioLocalDataSourceImpl(sharedPreferences: prefs);
      repository = PortfolioRepositoryImpl(localDataSource: localDataSource);
      placeOrderUseCase = PlaceOrderUseCase(repository: repository);
    });

    test('Executing valid Buy order updates wallet balance and creates holding', () async {
      final initialBalance = await repository.getWalletBalance();

      final failure = await placeOrderUseCase.execute(
        PlaceOrderParams(
          symbol: 'INFY',
          side: OrderSide.buy,
          quantity: 10,
          executionLtp: Decimal.parse('2000.00'),
        ),
      );

      expect(failure, isNull);

      final newBalance = await repository.getWalletBalance();
      expect(newBalance, equals(initialBalance - Decimal.parse('20000.00')));

      final holdings = await repository.getHoldings();
      expect(holdings.any((h) => h.symbol == 'INFY'), isTrue);
    });

    test('Executing Buy order with insufficient balance returns InsufficientBalanceFailure', () async {
      final failure = await placeOrderUseCase.execute(
        PlaceOrderParams(
          symbol: 'RELIANCE',
          side: OrderSide.buy,
          quantity: 100000,
          executionLtp: Decimal.parse('5000.00'),
        ),
      );

      expect(failure, isNotNull);
      expect(failure!.message, contains('Insufficient margin balance'));
    });
  });
}
