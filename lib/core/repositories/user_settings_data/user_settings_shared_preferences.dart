import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/repositories/user_settings_data/user_settings_data.dart';
import 'package:yampa/models/user_settings.dart';

import 'package:shared_preferences/shared_preferences.dart';

const defaultSortModeKey = "defaultSortMode";
const lastWindowWidthKey = "lastWindowWidth";
const lastWindowHeightKey = "lastWindowHeight";

class UserSettingsDataSharedPreferences extends UserSettingsData {
  @override
  Future<UserSettings> getUserSettings() async {
    final prefs = SharedPreferencesAsync();

    final defaultSortModeIndex = await prefs.getInt(defaultSortModeKey) ?? 0;
    final lastWindowWidth = await prefs.getDouble(lastWindowWidthKey);
    final lastWindowHeight = await prefs.getDouble(lastWindowHeightKey);
    return UserSettings(
      defaultSortMode: SortMode.values[defaultSortModeIndex], 
      lastWindowSize: lastWindowWidth != null && lastWindowHeight != null ? WindowSize(
        width: lastWindowWidth,
        height: lastWindowHeight,
      ) : null,
    );
  }

  @override
  Future<void> saveUserSettings(UserSettings userSettings) async {
    final prefs = SharedPreferencesAsync();

    await prefs.setInt(defaultSortModeKey, userSettings.defaultSortMode.index);
    if (userSettings.lastWindowSize != null) {
      await saveLastWindowSize(userSettings.lastWindowSize!);
    }
  }

  @override
  Future<void> saveLastWindowSize(WindowSize lastWindowSize) async {
    final prefs = SharedPreferencesAsync();

    await prefs.setDouble(lastWindowWidthKey, lastWindowSize.width);
    await prefs.setDouble(lastWindowHeightKey, lastWindowSize.height);
  }

  @override
  Future<void> close() async {}
}

