import 'package:flutter/material.dart';

class ColorUtils {
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'diatomic nonmetal':
        return Colors.blue;
      case 'noble gas':
        return Colors.purple;
      case 'alkali metal':
        return Colors.red;
      case 'alkaline earth metal':
        return Colors.orange;
      case 'metalloid':
        return Colors.green;
      case 'polyatomic nonmetal':
        return Colors.lightBlue;
      case 'post-transition metal':
        return Colors.teal;
      case 'transition metal':
        return Colors.pink;
      case 'lanthanide':
        return Colors.deepPurple;
      case 'actinide':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }
} 