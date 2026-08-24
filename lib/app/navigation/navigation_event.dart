import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class SelectTabEvent extends NavigationEvent {
  final int tabIndex;

  const SelectTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}
