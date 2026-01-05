import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/repositories/user_settings_data/user_settings_data.dart';
import 'package:yampa/models/user_settings.dart';

import 'package:shared_preferences/shared_preferences.dart';

const defaultSortModeKey = "defaultSortMode";
const lastWindowWidthKey = "lastWindowWidth";
const lastWindowHeightKey = "lastWindowHeight";
const userThemeModeKey = "userThemeModeKey";
const userLanguageKey = "userLanguageKey";

SharedPreferencesAsync _getPrefs() {
  // change preferences here if necessary
  return SharedPreferencesAsync();
}

class UserSettingsDataSharedPreferences extends UserSettingsData {
  @override
  Future<UserSettings> getUserSettings() async {
    return UserSettings(
      defaultSortMode: await getDefaultSortMode(),
      lastWindowSize: await getLastWindowSize(),
      themeMode: await getUserTheme(),
      languageCode: await getUserLanguage(),
    );
  }

  @override
  Future<void> saveUserSettings(UserSettings userSettings) async {
    final prefs = _getPrefs();

    await prefs.setInt(defaultSortModeKey, userSettings.defaultSortMode.index);
    if (userSettings.lastWindowSize != null) {
      await saveLastWindowSize(userSettings.lastWindowSize!);
    }
  }

  @override
  Future<void> saveLastWindowSize(WindowSize lastWindowSize) async {
    final prefs = _getPrefs();

    await prefs.setDouble(lastWindowWidthKey, lastWindowSize.width);
    await prefs.setDouble(lastWindowHeightKey, lastWindowSize.height);
  }

  @override
  Future<void> saveUserTheme(UserThemeMode userTheme) async {
    final prefs = _getPrefs();

    await prefs.setInt(userThemeModeKey, userTheme.index);
  }

  @override
  Future<void> saveDefaultSortMode(SortMode sortMode) async {
    final prefs = _getPrefs();

    await prefs.setInt(defaultSortModeKey, sortMode.index);
  }

  @override
  Future<void> saveUserLanguage(String? languageCode) async {
    final prefs = _getPrefs();

    if (languageCode != null) {
      await prefs.setString(userLanguageKey, languageCode);
    } else {
      await prefs.remove(userLanguageKey);
    }
  }

  @override
  Future<SortMode> getDefaultSortMode() async {
    final prefs = _getPrefs();

    final defaultSortModeIndex = await prefs.getInt(defaultSortModeKey);
    if (defaultSortModeIndex != null &&
        defaultSortModeIndex <= SortMode.values.length - 1) {
      return SortMode.values[defaultSortModeIndex];
    }
    return SortMode.titleAtoZ;
  }

  @override
  Future<UserThemeMode> getUserTheme() async {
    final prefs = _getPrefs();

    final themeIndex = await prefs.getInt(userThemeModeKey);
    if (themeIndex != null && themeIndex <= UserThemeMode.values.length - 1) {
      return UserThemeMode.values[themeIndex];
    }
    return UserThemeMode.system;
  }

  @override
  Future<WindowSize?> getLastWindowSize() async {
    final prefs = _getPrefs();

    final lastWindowWidth = await prefs.getDouble(lastWindowWidthKey);
    final lastWindowHeight = await prefs.getDouble(lastWindowHeightKey);
    if (lastWindowWidth != null && lastWindowHeight != null) {
      return WindowSize(width: lastWindowWidth, height: lastWindowHeight);
    }
    return null;
  }

  @override
  Future<String?> getUserLanguage() async {
    final prefs = _getPrefs();

    return await prefs.getString(userLanguageKey);
  }

  @override
  Future<void> close() async {}
}
