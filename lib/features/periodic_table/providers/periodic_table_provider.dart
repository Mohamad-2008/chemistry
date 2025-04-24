import 'package:flutter/material.dart';
import '../data/periodic_table_repository.dart';
import '../../../core/models/element_model.dart';
import '../../../core/models/element_details_model.dart';

enum ThirdField { atomicMass, name, phase, electronegativity }

class PeriodicTableProvider with ChangeNotifier {
  final PeriodicTableRepository _repository;
  List<ElementModel> _elements = [];
  bool _isLoading = false;
  String? _errorMessage;
  ElementModel? _selectedElement;
  List<ElementModel> _filteredElements = [];
  ThirdField _selectedThirdField = ThirdField.atomicMass; // فیلد سوم پیش‌فرض
  String? _selectedCategory; // دسته‌بندی انتخاب‌شده

  PeriodicTableProvider() : _repository = PeriodicTableRepository() {
    loadPeriodicTableData();
  }

  List<ElementModel> get elements => _elements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ElementModel? get selectedElement => _selectedElement;
  List<ElementModel> get filteredElements => _filteredElements;
  ThirdField get selectedThirdField => _selectedThirdField;
  String? get selectedCategory => _selectedCategory;

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
      _elements = await _repository.loadPeriodicTableData();
      _filteredElements = _elements; // مقداردهی اولیه
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'خطا در بارگذاری داده‌ها: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setThirdField(ThirdField field) {
    _selectedThirdField = field;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }
}