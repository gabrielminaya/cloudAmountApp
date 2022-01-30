part of 'theme_mode_bloc.dart';

@immutable
abstract class ThemeModeState {}

class ThemeModeInitial extends ThemeModeState {}

class ThemeModeLight extends ThemeModeState {}

class ThemeModeDark extends ThemeModeState {}
