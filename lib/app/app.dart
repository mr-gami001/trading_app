import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/holdings/bloc/holdings_bloc.dart';
import '../features/holdings/pages/holdings_page.dart';
import '../features/holdings/pages/orders_wallet_page.dart';
import '../features/market/bloc/market_bloc.dart';
import '../features/market/pages/market_page.dart';
import '../features/splash/pages/splash_page.dart';
import '../features/watchlist/bloc/watchlist_bloc.dart';
import '../features/watchlist/pages/watchlist_page.dart';
import '../injection_container.dart';
import 'navigation/navigation_bloc.dart';
import 'navigation/navigation_state.dart';
import 'theme/app_theme.dart';
import 'theme/theme_bloc.dart';
import 'theme/theme_state.dart';
import 'widgets/custom_bottom_nav_bar.dart';

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => sl<ThemeBloc>(),
        ),
        BlocProvider<MarketBloc>(
          create: (context) => sl<MarketBloc>(),
        ),
        BlocProvider<WatchlistBloc>(
          create: (context) => sl<WatchlistBloc>(),
        ),
        BlocProvider<HoldingsBloc>(
          create: (context) => sl<HoldingsBloc>(),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Groww Trading',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  final List<Widget> _pages = const [
    MarketPage(),
    WatchlistPage(),
    HoldingsPage(),
    OrdersWalletPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navState) {
        return Scaffold(
          body: IndexedStack(
            index: navState.currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: const CustomBottomNavBar(),
        );
      },
    );
  }
}
