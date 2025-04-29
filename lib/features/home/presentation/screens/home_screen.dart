import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using transparent background to let the main theme's background (with particles) show through
      backgroundColor: Colors.transparent,
      body: Center(
        child: GestureDetector(
          onTap: () {
            // Navigate to the periodic table screen
            Navigator.pushNamed(context, '/periodic-table');
          },
          child: Card(
            elevation: 8.0, // Add some shadow for depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            color: Colors.white.withOpacity(0.1), // Semi-transparent card background
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Make the card size fit its content
                children: [
                  Icon(
                    Icons.table_chart_outlined, // Icon representing a table
                    size: 64.0,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'ورود به جدول تناوبی',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 