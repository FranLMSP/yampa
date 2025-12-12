import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/repositories/user_settings_data/user_settings_data.dart';
import 'package:yampa/models/user_settings.dart';

import 'package:shared_preferences/shared_preferences.dart';

const defaultSortModeKey = "defaultSortMode";
const lastWindowWidthKey = "lastWindowWidth";
const lastWindowHeightKey = "lastWindowHeight";

SharedPreferencesAsync _getPrefs() {
  // change preferences here if necessary
  return SharedPreferencesAsync();
}

class UserSettingsDataSharedPreferences extends UserSettingsData {
  @override
  Future<UserSettings> getUserSettings() async {
    final prefs = _getPrefs();

    final defaultSortModeIndex = await prefs.getInt(defaultSortModeKey) ?? 0;
    return UserSettings(
      defaultSortMode: SortMode.values[defaultSortModeIndex], 
      lastWindowSize: await getLastWindowSize(),
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
  Future<WindowSize?> getLastWindowSize() async {
    final prefs = _getPrefs();

    final lastWindowWidth = await prefs.getDouble(lastWindowWidthKey);
    final lastWindowHeight = await prefs.getDouble(lastWindowHeightKey);
    if (lastWindowWidth != null && lastWindowHeight != null) {
      return WindowSize(
        width: lastWindowWidth,
        height: lastWindowHeight,
      );
    }
    return null;
  }

  @override
  Future<void> close() async {}
}
