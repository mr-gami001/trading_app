import 'package:flutter/material.dart';

abstract class ThemeEvent {
  const ThemeEvent();
}

class ToggleThemeEvent extends ThemeEvent {}

class SetThemeEvent extends ThemeEvent {
  final ThemeMode mode;
  const SetThemeEvent(this.mode);
}
