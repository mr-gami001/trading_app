import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/domain/repositories/market_repository.dart';
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

  testWidgets('TradingApp renders Splash and transitions to MainNavigationShell', (WidgetTester tester) async {
    await tester.pumpWidget(const TradingApp());
    expect(find.text('GROWW'), findsOneWidget);

    // Advance 2.1 seconds past Splash timer
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    expect(find.text('Watchlist'), findsWidgets);

    // Stop market feed timer before ending widget test
    sl<MarketRepository>().stopFeed();
  });
}
