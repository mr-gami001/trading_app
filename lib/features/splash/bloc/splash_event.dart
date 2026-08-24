import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

class StartSplashTimerEvent extends SplashEvent {
  const StartSplashTimerEvent();
}
