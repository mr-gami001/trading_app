import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashInitialState()) {
    on<StartSplashTimerEvent>(_onStartTimer);
  }

  Future<void> _onStartTimer(StartSplashTimerEvent event, Emitter<SplashState> emit) async {
    await Future.delayed(const Duration(milliseconds: 2000));
    emit(const SplashCompletedState());
  }
}
