import 'package:yampa/core/repositories/user_settings_data/user_settings_data.dart';
import 'package:yampa/core/repositories/user_settings_data/user_settings_shared_preferences.dart';

UserSettingsData getUserSettingsDataRepository() {
  return UserSettingsDataSharedPreferences();
}
