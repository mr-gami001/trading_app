import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences sharedPreferences;
  static const String _keyThemeMode = 'key_theme_mode_v1';

  ThemeBloc({required this.sharedPreferences}) : super(const ThemeState()) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);

    _loadThemeFromPrefs();
  }

  void _loadThemeFromPrefs() {
    final String? savedMode = sharedPreferences.getString(_keyThemeMode);
    if (savedMode == 'light') {
      add(const SetThemeEvent(ThemeMode.light));
    } else {
      add(const SetThemeEvent(ThemeMode.dark));
    }
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) {
    final newMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    emit(state.copyWith(themeMode: newMode));
    sharedPreferences.setString(_keyThemeMode, newMode == ThemeMode.light ? 'light' : 'dark');
  }

  void _onSetTheme(SetThemeEvent event, Emitter<ThemeState> emit) {
    emit(state.copyWith(themeMode: event.mode));
    sharedPreferences.setString(_keyThemeMode, event.mode == ThemeMode.light ? 'light' : 'dark');
  }
}
