import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:periodic_table_app/core/models/element_model.dart';

class PeriodicTableRepository {
  Future<List<ElementModel>> loadPeriodicTableData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/periodic_table.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final order = List<String>.from(jsonData['order']);

      return order.map((key) => ElementModel.fromJson(jsonData[key])).toList();
    } catch (e) {
      print('Error loading periodic table data: $e');
      return [];
    }
  }
}