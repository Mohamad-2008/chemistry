import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';

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

  Future<ElementDetailsModel?> getElementDetails(String symbol) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/periodic_table.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // جستجو در کل داده‌ها برای یافتن عنصر با نماد مورد نظر
      for (final key in jsonData.keys) {
        if (key != 'order') { // از فیلد order صرف نظر می‌کنیم
          final elementData = jsonData[key];
          if (elementData['symbol']?.toString().toLowerCase() == symbol.toLowerCase()) {
            return ElementDetailsModel.fromJson(elementData);
          }
        }
      }
      
      return null;
    } catch (e) {
      print('Error loading element details: $e');
      return null;
    }
  }
}