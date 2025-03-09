import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  static const String _defaultLanguage = 'en';

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<void> load() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/lang/${locale.languageCode}.json',
      );

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map<String, String>(
            (key, value) => MapEntry(key, value.toString()),
      );
    } catch (e) {
      // Fallback to default language if needed
      if (locale.languageCode != _defaultLanguage) {
        await _loadDefaultLanguage();
      } else {
        _localizedStrings = {}; // Consider throwing an error here
      }
    }
  }

  Future<void> _loadDefaultLanguage() async {
    final String defaultJson = await rootBundle.loadString(
      'assets/lang/$_defaultLanguage.json',
    );
    _localizedStrings = json.decode(defaultJson).map<String, String>(
          (key, value) => MapEntry(key, value.toString()),
    );
  }

  String translate(String key) {
    return _localizedStrings[key] ?? _handleMissingTranslation(key);
  }

  String _handleMissingTranslation(String key) {
    debugPrint('Warning: Missing translation for key: "$key" in ${locale.languageCode}');
    return key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}