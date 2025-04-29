import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/core/providers/theme_provider.dart'; // <--- به زودی ایجاد می شود
import 'package:periodic_table_app/core/providers/locale_provider.dart'; // <--- اضافه شد
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // <--- اضافه شد

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // دسترسی به ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context); // <--- دریافت LocaleProvider
    final l10n = AppLocalizations.of(context)!; // <--- دسترسی به متن های ترجمه شده

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle), // <--- استفاده از متن ترجمه شده
        // رنگ اپ بار متناسب با تم تغییر می کند
        // backgroundColor: Colors.blueGrey[900], // دیگر نیازی نیست ثابت باشد
        elevation: 0,
      ),
      // بدنه هم با تم تغییر می کند
      body: ListView( // استفاده از ListView برای افزودن تنظیمات بیشتر در آینده
        children: [
          SwitchListTile(
            title: Text(l10n.darkMode), // <--- استفاده از متن ترجمه شده
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            // رنگ ها متناسب با تم تنظیم می شوند
          ),
          const Divider(), // <--- جداکننده
          // --- بخش انتخاب زبان ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              l10n.language, // <--- استفاده از متن ترجمه شده
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
          // Wrap RadioListTiles in a Center and Column
          Center(
            child: Column(
              // You might want to constrain the width if they look too wide
              // constraints: const BoxConstraints(maxWidth: 300),
              children: [
                RadioListTile<Locale>(
                  title: const Text('English'),
                  value: const Locale('en'),
                  groupValue: localeProvider.locale,
                  onChanged: (Locale? value) {
                    if (value != null) localeProvider.setLocale(value);
                  },
                ),
                RadioListTile<Locale>(
                  title: const Text('فارسی'),
                  value: const Locale('fa'),
                  groupValue: localeProvider.locale,
                  onChanged: (Locale? value) {
                    if (value != null) localeProvider.setLocale(value);
                  },
                ),
              ],
            ),
          ),
          // ----------------------
          // می توانید تنظیمات بیشتری اینجا اضافه کنید
          // مثلا:
          // ListTile(
          //   title: Text('اعلان ها', style: TextStyle(fontFamily: 'Vazir')),
          //   leading: Icon(Icons.notifications),
          //   onTap: () { /* ... */ },
          // ),
          // ListTile(
          //   title: Text('زبان', style: TextStyle(fontFamily: 'Vazir')),
          //   leading: Icon(Icons.language),
          //   onTap: () { /* ... */ },
          // ),
        ],
      ),
    );
  }
} 