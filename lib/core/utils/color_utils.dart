import 'package:flutter/material.dart';

class ColorUtils {
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'alkali metal':
        return Colors.red;
      case 'alkaline earth metal':
        return Colors.orange;
      case 'transition metal':
        return Colors.yellow;
      case 'post-transition metal':
        return Colors.green;
      case 'metalloid':
        return Colors.teal;
      case 'nonmetal':
        return Colors.blue;
      case 'halogen':
        return Colors.indigo;
      case 'noble gas':
        return Colors.purple;
      case 'lanthanide':
        return Colors.pink;
      case 'actinide':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
} 