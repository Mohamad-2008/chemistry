import 'package:flutter/material.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/profile_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/profile_setup_screen.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/periodic_table_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/element_details_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/element_search_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/element_comparison_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/chemistry_book_screen.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';
import 'package:periodic_table_app/features/periodic_table/data/periodic_table_repository.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';
import 'package:periodic_table_app/features/chat_bot/presentation/screens/chat_bot_screen.dart';
import 'package:periodic_table_app/utils/particle_painter.dart';
import 'package:periodic_table_app/core/routes/app_routes.dart';

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
            backgroundColor: Colors.black.withAlpha((255 * 0.7).round()),
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
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.black.withAlpha((255 * 0.8).round()),
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
        initialRoute: AppRoutes.home,
        routes: {
          AppRoutes.home: (context) => const PeriodicTableScreen(),
          AppRoutes.mainMenu: (context) => const PeriodicTableScreen(),
          AppRoutes.chatBot: (context) => const ChatBotScreen(),
          AppRoutes.profileSetup: (context) => const ProfileSetupScreen(),
          AppRoutes.profile: (context) => const ProfileScreen(),
        },
        onGenerateRoute: AppRoutes.generateRoute,
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();

          return Stack(
            children: [
              // لایه 1: پس زمینه ذرات
              const IgnorePointer(
                ignoring: true,
                child: Stack(
                  children: [
                    // ذرات آبی
                    ParticleAnimation(
                      numberOfParticles: 40,
                      particleColor: Colors.blue,
                      maxParticleSize: 2,
                      speed: 1,
                    ),
                    // ذرات بنفش
                    ParticleAnimation(
                      numberOfParticles: 40,
                      particleColor: Colors.purple,
                      maxParticleSize: 3,
                      speed: 1.2,
                    ),
                    // ذرات زرد
                    ParticleAnimation(
                      numberOfParticles: 40,
                      particleColor: Colors.yellow,
                      maxParticleSize: 1.5,
                      speed: 0.8,
                    ),
                  ],
                ),
              ),
              // لایه 2: محتوای صفحه با پس زمینه شفاف
              Theme(
                data: Theme.of(context).copyWith(
                  scaffoldBackgroundColor: Colors.transparent,
                ),
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }
}
