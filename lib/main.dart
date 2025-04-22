import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/themes/app_theme.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/periodic_table_screen.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';

void main() {
  runApp(const PeriodicTableApp());
}

class PeriodicTableApp extends StatelessWidget {
  const PeriodicTableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PeriodicTableProvider()..loadPeriodicTableData(),
      child: MaterialApp(
        title: 'Periodic Table',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const PeriodicTableScreen(),
      ),
    );
  }
}