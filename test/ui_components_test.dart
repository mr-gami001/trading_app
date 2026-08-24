import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/core/widgets/market_depth_widget.dart';
import 'package:trading_app/core/widgets/mini_price_chart.dart';
import 'package:trading_app/domain/repositories/market_repository.dart';
import 'package:trading_app/features/holdings/bloc/holdings_bloc.dart';
import 'package:trading_app/features/market/bloc/market_bloc.dart';
import 'package:trading_app/features/trading/pages/buy_sell_ticket_page.dart';
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

  group('UI Components Layout & Overflow Verification Tests', () {
    testWidgets('MiniPriceChart renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniPriceChart(
              currentPrice: Decimal.parse('2950.50'),
              previousClose: Decimal.parse('2900.00'),
              isGain: true,
            ),
          ),
        ),
      );
      expect(find.byType(MiniPriceChart), findsOneWidget);
    });

    testWidgets('MarketDepthWidget renders 5-depth ladder cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MarketDepthWidget(ltp: Decimal.parse('4120.00')),
            ),
          ),
        ),
      );
      expect(find.text('Market Depth (5 Bids / 5 Asks)'), findsOneWidget);
    });

    testWidgets('BuySellTicketPage form renders cleanly inside Bloc providers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<MarketBloc>(create: (_) => sl<MarketBloc>()),
            BlocProvider<HoldingsBloc>(create: (_) => sl<HoldingsBloc>()),
          ],
          child: const MaterialApp(
            home: BuySellTicketPage(initialSymbol: 'RELIANCE'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Delivery (CNC)'), findsOneWidget);
      expect(find.text('Intraday (MIS)'), findsOneWidget);

      sl<MarketRepository>().stopFeed();
    });

    testWidgets('Full TradingApp navigation between tabs works cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(const TradingApp());
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pumpAndSettle();

      // 1. Explore tab
      expect(find.text('Market Overview'), findsOneWidget);

      // 2. Tap Watchlist tab icon
      await tester.tap(find.byIcon(Icons.bookmark_outline));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Watchlist'), findsWidgets);

      // 3. Tap Holdings tab icon
      await tester.tap(find.byIcon(Icons.pie_chart_outline));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Portfolio'), findsOneWidget);

      // 4. Tap Orders tab icon
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Funds & Orders'), findsOneWidget);

      sl<MarketRepository>().stopFeed();
    });
  });
}
