import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitialState extends SplashState {
  const SplashInitialState();
}

class SplashCompletedState extends SplashState {
  const SplashCompletedState();
}
