import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/localization/localization_service.dart';
import 'package:yampa/core/repositories/user_settings_data/factory.dart';

class LocalizationNotifier extends Notifier<String> {
  final LocalizationService _service = LocalizationService();

  @override
  String build() {
    return 'en';
  }

  Future<void> init(String? savedLanguage) async {
    String languageToUse = 'en';
    if (savedLanguage != null) {
      languageToUse = savedLanguage;
    } else {
      // Detect system language
      final systemLocale = PlatformDispatcher.instance.locale.languageCode;
      // We only support 'en' and 'es' for now, default to 'en'
      if (['en', 'es'].contains(systemLocale)) {
        languageToUse = systemLocale;
      }
    }

    await _service.init(languageToUse);
    state = languageToUse;
  }

  Future<void> setLanguage(String languageCode) async {
    await _service.init(languageCode);
    final repo = getUserSettingsDataRepository();
    await repo.saveUserLanguage(languageCode);
    await repo.close();
    state = languageCode;
  }

  String translate(String key) => _service.translate(key);
}

final localizationProvider = NotifierProvider<LocalizationNotifier, String>(() {
  return LocalizationNotifier();
});
