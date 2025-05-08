import 'package:flutter/material.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/periodic_table_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/profile_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/profile_setup_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/element_details_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/element_search_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/element_comparison_screen.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/chemistry_book_screen.dart';
import 'package:periodic_table_app/features/chat_bot/presentation/screens/chat_bot_screen.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';
import 'package:periodic_table_app/features/periodic_table/data/periodic_table_repository.dart';
import 'package:periodic_table_app/features/chemistry_calculator/presentation/screens/chemistry_calculator_screen.dart';
import 'package:periodic_table_app/features/chemistry_calculator/presentation/screens/chemistry_formulas_screen.dart';

// Route argument classes for type safety
class ElementDetailsArgs {
  final ElementModel element;
  ElementDetailsArgs(this.element);
}

class ElementSearchArgs {
  final ElementModel? firstElement;
  final bool isForComparison;
  ElementSearchArgs({this.firstElement, this.isForComparison = false});
}

class ElementComparisonArgs {
  final ElementDetailsModel element1;
  final ElementDetailsModel element2;
  ElementComparisonArgs(this.element1, this.element2);
}

class ChemistryBookArgs {
  final int? podmanId;
  ChemistryBookArgs({this.podmanId});
}

class AppRoutes {
  static const String home = '/';
  static const String mainMenu = '/main_menu';
  static const String chatBot = '/chat_bot';
  static const String profileSetup = '/profile_setup';
  static const String profile = '/profile';
  static const String elementDetails = '/element_details';
  static const String elementSearch = '/element_search';
  static const String elementComparison = '/element_comparison';
  static const String chemistryBook = '/chemistry_book';
  static const String chemistryCalculator = '/chemistry_calculator';
  static const String chemistryFormulas = '/chemistry_formulas';

  // Helper methods for navigation
  static Future<T?> navigateToHome<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, home);
  }

  static Future<T?> navigateToMainMenu<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, mainMenu);
  }

  static Future<T?> navigateToChatBot<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, chatBot);
  }

  static Future<T?> navigateToProfileSetup<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, profileSetup);
  }

  static Future<T?> navigateToProfile<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, profile);
  }

  static Future<T?> navigateToElementDetails<T>(
      BuildContext context, ElementModel element) {
    return Navigator.pushNamed<T>(context, elementDetails,
        arguments: ElementDetailsArgs(element));
  }

  static void navigateToElementSearch(
    BuildContext context, {
    ElementModel? firstElement,
    bool isForComparison = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElementSearchScreen(
          firstElement: firstElement,
          isForComparison: isForComparison,
        ),
      ),
    );
  }

  static Future<T?> navigateToElementComparison<T>(BuildContext context,
      ElementModel element1, ElementModel element2) async {
    final details1 =
        await PeriodicTableRepository().getElementDetails(element1.symbol);
    final details2 =
        await PeriodicTableRepository().getElementDetails(element2.symbol);
    if (details1 != null && details2 != null) {
      return Navigator.pushNamed<T>(context, elementComparison,
          arguments: ElementComparisonArgs(details1, details2));
    }
    return null;
  }

  static Future<T?> navigateToChemistryBook<T>(BuildContext context,
      {int? podmanId}) {
    return Navigator.pushNamed<T>(
      context,
      chemistryBook,
      arguments: ChemistryBookArgs(podmanId: podmanId),
    );
  }

  static Future<void> navigateToChemistryCalculator(
      BuildContext context) async {
    await Navigator.pushNamed(context, chemistryCalculator);
  }

  static Future<void> navigateToChemistryFormulas(BuildContext context) async {
    await Navigator.pushNamed(context, chemistryFormulas);
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const PeriodicTableScreen());
      case mainMenu:
        return MaterialPageRoute(builder: (_) => const PeriodicTableScreen());
      case chatBot:
        return MaterialPageRoute(builder: (_) => const ChatBotScreen());
      case profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case elementDetails:
        final args = settings.arguments as ElementDetailsArgs;
        return MaterialPageRoute(
          builder: (_) => FutureBuilder<ElementDetailsModel?>(
            future: PeriodicTableRepository()
                .getElementDetails(args.element.symbol),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Scaffold(
                    body: Center(child: Text('خطا: ${snapshot.error}')));
              }
              if (snapshot.data == null) {
                return const Scaffold(
                    body: Center(child: Text('عنصری یافت نشد')));
              }
              return ElementDetailsScreen(element: snapshot.data!);
            },
          ),
        );
      case elementSearch:
        final args = settings.arguments as ElementSearchArgs;
        return MaterialPageRoute(
            builder: (_) => ElementSearchScreen(
                  firstElement: args.firstElement,
                  isForComparison: args.isForComparison,
                ));
      case elementComparison:
        final args = settings.arguments as ElementComparisonArgs;
        return MaterialPageRoute(
          builder: (_) => ElementComparisonScreen(
            element1: args.element1,
            element2: args.element2,
          ),
        );
      case chemistryBook:
        final args = settings.arguments as ChemistryBookArgs;
        return MaterialPageRoute(
          builder: (_) => ChemistryBookScreen(initialPodmanId: args.podmanId),
        );
      case chemistryCalculator:
        return MaterialPageRoute(
          builder: (_) => const ChemistryCalculatorScreen(),
        );
      case chemistryFormulas:
        return MaterialPageRoute(
          builder: (_) => const ChemistryToolsScreen(),
        );
      default:
        return null;
    }
  }
}
