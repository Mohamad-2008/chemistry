import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/periodic_table_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/element_details_screen.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';
import 'package:periodic_table_app/features/periodic_table/data/periodic_table_repository.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = PeriodicTableProvider();
            provider.loadPeriodicTableData();
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Periodic Table',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[900],
          textTheme: const TextTheme(
            titleLarge: TextStyle(color: Colors.white, fontSize: 20),
            bodyMedium: TextStyle(color: Colors.white),
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(builder: (_) => const PeriodicTableScreen());
          }
          if (settings.name == '/element_details') {
            final element = settings.arguments as ElementModel;
            return MaterialPageRoute(
              builder: (_) => FutureBuilder<ElementDetailsModel?>(
                future: PeriodicTableRepository().getElementDetails(element.symbol),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Text('خطا در بارگذاری جزئیات عنصر: ${snapshot.error}'),
                      ),
                    );
                  }
                  if (snapshot.data == null) {
                    return const Scaffold(
                      body: Center(
                        child: Text('جزئیات عنصر یافت نشد'),
                      ),
                    );
                  }
                  return ElementDetailsScreen(element: snapshot.data!);
                },
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}