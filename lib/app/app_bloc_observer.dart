import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      // Avoid spamming log during high frequency market ticks
      if (!bloc.runtimeType.toString().contains('MarketBloc')) {
        debugPrint('[BlocChange] ${bloc.runtimeType}: $change');
      }
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (kDebugMode) {
      debugPrint('[BlocError] ${bloc.runtimeType}: $error');
    }
  }
}
