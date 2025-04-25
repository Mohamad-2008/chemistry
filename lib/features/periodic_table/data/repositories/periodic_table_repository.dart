import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class PeriodicTableRepository {
  static final PeriodicTableRepository _instance = PeriodicTableRepository._internal();

  factory PeriodicTableRepository() {
    return _instance;
  }

  PeriodicTableRepository._internal();

  Future<List<ElementModel>> getElements() async {
    try {
      final String response = await rootBundle.loadString('assets/data/periodic_table.json');
      final data = await json.decode(response) as Map<String, dynamic>;
      final order = List<String>.from(data['order']);
      return order.map((key) => ElementModel.fromJson(data[key])).toList();
    } catch (e) {
      throw Exception('خطا در بارگذاری اطلاعات عناصر: $e');
    }
  }

  Future<ElementDetailsModel?> getElementDetails(String symbol) async {
    try {
      final String response = await rootBundle.loadString('assets/data/periodic_table.json');
      final data = await json.decode(response) as Map<String, dynamic>;
      
      // جستجو در کل داده‌ها برای یافتن عنصر با نماد مورد نظر
      for (final key in data.keys) {
        if (key != 'order') { // از فیلد order صرف نظر می‌کنیم
          final elementData = data[key];
          if (elementData['symbol']?.toString().toLowerCase() == symbol.toLowerCase()) {
            return ElementDetailsModel.fromJson(elementData);
          }
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('خطا در بارگذاری جزئیات عنصر: $e');
    }
  }
} 