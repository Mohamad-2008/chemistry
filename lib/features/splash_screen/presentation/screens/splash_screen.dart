import 'package:flutter/material.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/screens/periodic_table_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PeriodicTableScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF1A1A1A), // حذف رنگ پس زمینه برای شفافیت
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/heisenberg_logo_minimal.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'شیمی با هیزنبرگ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lalezar',
              ),
            ),
          ],
        ),
      ),
    );
  }
} 