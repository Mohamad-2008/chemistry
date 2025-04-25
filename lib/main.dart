import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/periodic_table_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/element_details_screen.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';
import 'package:periodic_table_app/features/periodic_table/data/periodic_table_repository.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';
import 'package:periodic_table_app/features/chat_bot/presentation/screens/chat_bot_screen.dart';
import 'package:periodic_table_app/features/splash_screen/presentation/screens/splash_screen.dart';

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
        title: 'جدول تناوبی عناصر',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF1A1A1A),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black.withOpacity(0.7),
            elevation: 0,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lalezar',
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lalezar',
            ),
            bodyMedium: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Lalezar',
            ),
          ),
          dialogTheme: DialogTheme(
            backgroundColor: Colors.black.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lalezar',
            ),
            contentTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Lalezar',
            ),
          ),
        ),
        home: const SplashScreen(),
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
          if (settings.name == '/chat_bot') {
            return MaterialPageRoute(builder: (_) => const ChatBotScreen());
          }
          return null;
        },
      ),
    );
  }
}