import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/blocs/market_feed/market_feed_bloc.dart';
import 'package:trading_app/blocs/market_feed/market_feed_event.dart';

void main() {
  group('MarketFeedBloc Tests', () {
    late MarketFeedBloc marketFeedBloc;

    setUp(() {
      marketFeedBloc = MarketFeedBloc();
    });

    tearDown(() {
      marketFeedBloc.close();
    });

    test('Initial state contains all 10 stocks', () {
      expect(marketFeedBloc.state.quotes.length, equals(10));
      expect(marketFeedBloc.state.quotes.containsKey('RELIANCE'), isTrue);
      expect(marketFeedBloc.state.quotes.containsKey('TCS'), isTrue);
    });

    test('SetTickIntervalEvent updates interval and stress mode', () async {
      marketFeedBloc.add(const SetTickIntervalEvent(20));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(marketFeedBloc.state.tickIntervalMs, equals(20));
      expect(marketFeedBloc.state.isStressMode, isTrue);
    });

    test('ToggleStressModeEvent updates stress mode state correctly', () async {
      marketFeedBloc.add(const ToggleStressModeEvent(true));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(marketFeedBloc.state.isStressMode, isTrue);
      expect(marketFeedBloc.state.tickIntervalMs, equals(20));
    });
  });
}
