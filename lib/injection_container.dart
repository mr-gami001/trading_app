import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/theme/theme_bloc.dart';
import 'data/datasources/local/portfolio_local_datasource.dart';
import 'data/datasources/local/watchlist_local_datasource.dart';
import 'data/datasources/market/live_websocket_market_data_datasource.dart';
import 'data/datasources/market/market_data_datasource.dart';
import 'data/repositories/market_repository_impl.dart';
import 'data/repositories/portfolio_repository_impl.dart';
import 'data/repositories/watchlist_repository_impl.dart';
import 'domain/repositories/market_repository.dart';
import 'domain/repositories/portfolio_repository.dart';
import 'domain/repositories/watchlist_repository.dart';
import 'domain/usecases/holdings/get_portfolio_summary_usecase.dart';
import 'domain/usecases/trading/place_order_usecase.dart';
import 'domain/usecases/watchlist/get_watchlists_usecase.dart';
import 'features/holdings/bloc/holdings_bloc.dart';
import 'features/market/bloc/market_bloc.dart';
import 'features/trading/bloc/trading_bloc.dart';
import 'features/watchlist/bloc/watchlist_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencyInjection() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Data Sources - Live Free Open WebSocket Stream
  sl.registerLazySingleton<MarketDataDataSource>(() => LiveWebSocketMarketDataDataSource());
  sl.registerLazySingleton<WatchlistLocalDataSource>(
    () => WatchlistLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<PortfolioLocalDataSource>(
    () => PortfolioLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<MarketRepository>(
    () => MarketRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetWatchlistsUseCase(repository: sl()));
  sl.registerLazySingleton(() => SaveWatchlistsUseCase(repository: sl()));
  sl.registerLazySingleton(() => PlaceOrderUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetPortfolioSummaryUseCase());

  // BLoCs
  sl.registerFactory(() => ThemeBloc(sharedPreferences: sl()));
  sl.registerFactory(() => MarketBloc(repository: sl()));
  sl.registerFactory(
    () => WatchlistBloc(
      getWatchlistsUseCase: sl(),
      saveWatchlistsUseCase: sl(),
    ),
  );
  sl.registerFactory(() => HoldingsBloc(repository: sl()));
  sl.registerFactory(() => TradingBloc(placeOrderUseCase: sl()));
}
