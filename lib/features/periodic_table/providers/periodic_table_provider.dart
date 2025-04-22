import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/features/periodic_table/data/periodic_table_repository.dart';

class PeriodicTableProvider with ChangeNotifier {
  List<ElementModel> _elements = [];
  bool _isLoading = false;
  String? _errorMessage;
  ElementModel? _selectedElement;
  List<ElementModel> _filteredElements = [];

  List<ElementModel> get elements => _elements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ElementModel? get selectedElement => _selectedElement;
  List<ElementModel> get filteredElements => _filteredElements;

  void selectElement(ElementModel? element) {
    if (_selectedElement != element) {
      _selectedElement = element;
      notifyListeners();
    }
  }

  void searchElements(String query) {
    if (query.isEmpty) {
      _filteredElements = _elements;
    } else {
      _filteredElements = _elements.where((element) {
        return element.name.toLowerCase().contains(query.toLowerCase()) ||
            element.symbol.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> loadPeriodicTableData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final repository = PeriodicTableRepository();
      _elements = await repository.loadPeriodicTableData();
      _filteredElements = _elements; // مقداردهی اولیه
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'خطا در بارگذاری داده‌ها: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}