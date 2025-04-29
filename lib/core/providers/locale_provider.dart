import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('fa'); // شروع با زبان فارسی
  static const String _languageCodeKey = 'language_code';

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return; // فقط زبان های پشتیبانی شده

    _locale = locale;
    _saveLocale(locale);
    notifyListeners();
  }

  // بارگذاری زبان ذخیره شده از SharedPreferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  // ذخیره زبان انتخاب شده در SharedPreferences
  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_languageCodeKey, locale.languageCode);
  }
}

// کلاس کمکی برای دسترسی آسان به زبان های پشتیبانی شده
class L10n {
  static final all = [
    const Locale('en'),
    const Locale('fa'),
  ];
} 