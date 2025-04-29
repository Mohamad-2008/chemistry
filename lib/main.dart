import 'package:flutter/material.dart';
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
import 'package:periodic_table_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:periodic_table_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:periodic_table_app/utils/particle_painter.dart';
import 'package:periodic_table_app/core/providers/theme_provider.dart';
import 'package:periodic_table_app/core/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = PeriodicTableProvider();
            provider.loadPeriodicTableData();
            return provider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) {
        return AppLocalizations.of(context)!.appTitle;
      },
      themeMode: themeProvider.themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      locale: localeProvider.locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) {
            return const PeriodicTableScreen();
          });
        }
        if (settings.name == '/element_details') {
          if (settings.arguments is ElementModel) {
            final element = settings.arguments as ElementModel;
            return MaterialPageRoute(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return FutureBuilder<ElementDetailsModel?>(
                  future: PeriodicTableRepository().getElementDetails(element.symbol),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Scaffold(
                        appBar: AppBar(title: Text(element.name)),
                        body: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return Scaffold(
                        appBar: AppBar(title: Text(element.name)),
                        body: Center(
                          child: Text(
                            snapshot.hasError
                              ? '${l10n.errorLoadingElementDetailsPrefix} ${snapshot.error}'
                              : l10n.elementDetailsNotFound,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }
                    return ElementDetailsScreen(element: snapshot.data!);
                  },
                );
              },
            );
          } else {
            return MaterialPageRoute(builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Scaffold(body: Center(child: Text(l10n.errorInvalidArgsElementDetails)));
            });
          }
        }
        if (settings.name == '/element_search') {
          final firstElement = settings.arguments as ElementDetailsModel;
          return MaterialPageRoute(
            builder: (context) => ElementSearchScreen(firstElement: firstElement),
          );
        }
        if (settings.name == '/element_comparison') {
          final args = settings.arguments as Map<String, ElementDetailsModel>;
          return MaterialPageRoute(
            builder: (context) => ElementComparisonScreen(
              element1: args['element1']!,
              element2: args['element2']!,
            ),
          );
        }
        if (settings.name == '/chat_bot') {
          return MaterialPageRoute(builder: (context) => const ChatBotScreen());
        }
        if (settings.name == '/chemistry_book') {
          return MaterialPageRoute(builder: (context) => const ChemistryBookScreen());
        }
        if (settings.name == '/profile') {
          return MaterialPageRoute(builder: (context) => const ProfileScreen());
        }
        if (settings.name == '/settings') {
          return MaterialPageRoute(builder: (context) => const SettingsScreen());
        }
        final l10n = AppLocalizations.of(context)!;
        return MaterialPageRoute(
           builder: (context) {
             return Scaffold(
               appBar: AppBar(title: Text(l10n.errorTitle)),
               body: Center(child: Text('${l10n.errorPageNotFoundPrefix} ${settings.name}')),
             );
           });
      },
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();

        return Stack(
          children: [
            const IgnorePointer(
              ignoring: true,
              child: Stack(
                children: [
                  ParticleAnimation(
                    numberOfParticles: 40,
                    particleColor: Colors.blue,
                    maxParticleSize: 2,
                    speed: 1,
                  ),
                  ParticleAnimation(
                    numberOfParticles: 40,
                    particleColor: Colors.purple,
                    maxParticleSize: 3,
                    speed: 1.2,
                  ),
                  ParticleAnimation(
                    numberOfParticles: 40,
                    particleColor: Colors.yellow,
                    maxParticleSize: 1.5,
                    speed: 0.8,
                  ),
                ],
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                scaffoldBackgroundColor: Colors.transparent,
              ),
              child: child,
            ),
          ],
        );
      },
    );
  }
}