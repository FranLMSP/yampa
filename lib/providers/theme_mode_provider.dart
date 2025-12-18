import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/user_settings.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeProviderNotifier, UserThemeMode>(
      () => ThemeModeProviderNotifier(),
    );

class ThemeModeProviderNotifier extends Notifier<UserThemeMode> {
  @override
  UserThemeMode build() {
    return UserThemeMode.system;
  }

  void setThemeMode(UserThemeMode theme) {
    state = theme;
  }
}
