import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, String> _translations = {};
  Map<String, String> _fallbackTranslations = {};
  String _currentLanguageCode = 'en';

  static const String _delimiter = ';';

  Future<void> init(String languageCode) async {
    _currentLanguageCode = languageCode;
    await _loadFallback();
    if (languageCode != 'en') {
      _translations = await _loadCsv(languageCode);
    } else {
      _translations = {};
    }
  }

  Future<void> _loadFallback() async {
    _fallbackTranslations = await _loadCsv('en');
  }

  Future<Map<String, String>> _loadCsv(String languageCode) async {
    try {
      final String content = await rootBundle.loadString(
        'assets/translations/$languageCode.csv',
      );
      final Map<String, String> result = {};
      final List<String> lines = const LineSplitter().convert(content);
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        final parts = line.split(_delimiter);
        if (parts.length >= 2) {
          final key = parts[0].trim();
          // Join the rest in case the value itself contains delimiters (though less likely with semicolon)
          final value = parts.sublist(1).join(_delimiter).trim();
          result[key] = value;
        }
      }
      return result;
    } catch (e) {
      print('Error loading translations for $languageCode: $e');
      return {};
    }
  }

  String translate(String key) {
    if (_translations.containsKey(key)) {
      return _translations[key]!;
    }
    if (_fallbackTranslations.containsKey(key)) {
      return _fallbackTranslations[key]!;
    }
    return key;
  }

  String get currentLanguageCode => _currentLanguageCode;
}
