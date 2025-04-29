import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        backgroundColor: Colors.blueGrey[900], // تنظیم رنگ پس‌زمینه اپ‌بار
        elevation: 0, // حذف سایه اپ‌بار
      ),
      body: Container( // اضافه کردن پس‌زمینه مشابه منوی اصلی
        child: Center(
          child: Text(
            l10n.profilePageMessage,
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
} 