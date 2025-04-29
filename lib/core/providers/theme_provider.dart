import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // شروع با تم تاریک

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // به ویجت هایی که گوش می دهند اطلاع بده
  }
}

// تعریف تم های روشن و تاریک (می توانید این ها را سفارشی کنید)
class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue, // رنگ اصلی تم روشن
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      elevation: 1,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Vazir',
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    fontFamily: 'Kalameh',
    // ... سایر تنظیمات تم روشن
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey, // رنگ اصلی تم تاریک
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey[800],
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Vazir',
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
    ),
    fontFamily: 'Kalameh',
    // ... سایر تنظیمات تم تاریک
  );
} 