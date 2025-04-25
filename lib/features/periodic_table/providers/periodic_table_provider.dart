import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/features/periodic_table/data/periodic_table_repository.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/search_type.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/settings_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeriodicTableProvider with ChangeNotifier {
  List<ElementModel> _elements = [];
  bool _isLoading = false;
  String? _errorMessage;
  ElementModel? _selectedElement;
  List<ElementModel> _filteredElements = [];
  SearchType _searchType = SearchType.name;
  ThirdItemType _thirdItemType = ThirdItemType.name;

  List<ElementModel> get elements => _elements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ElementModel? get selectedElement => _selectedElement;
  List<ElementModel> get filteredElements => _filteredElements;
  SearchType get searchType => _searchType;
  ThirdItemType get thirdItemType => _thirdItemType;

  void setSearchType(SearchType type) {
    _searchType = type;
    notifyListeners();
  }

  void setThirdItemType(ThirdItemType type) {
    _thirdItemType = type;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('thirdItemType', _thirdItemType.index);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedType = prefs.getInt('thirdItemType');
    if (savedType != null) {
      _thirdItemType = ThirdItemType.values[savedType];
    }
  }

  String getThirdItemValue(ElementModel element) {
    switch (_thirdItemType) {
      case ThirdItemType.name:
        return element.name;
      case ThirdItemType.atomicMass:
        return element.atomicMass.toString();
      case ThirdItemType.category:
        return element.category;
      case ThirdItemType.phase:
        return element.phase;
      case ThirdItemType.meltingPoint:
        return element.meltingPoint?.toString() ?? '-';
      case ThirdItemType.boilingPoint:
        return element.boilingPoint?.toString() ?? '-';
    }
  }

  void selectElement(ElementModel? element) {
    if (_selectedElement != element) {
      _selectedElement = element;
      notifyListeners();
    }
  }

  void clearSearch() {
    _filteredElements = _elements;
    _searchType = SearchType.name;
    notifyListeners();
  }

  void searchElements(String query) {
    if (query.isEmpty) {
      _filteredElements = _elements;
    } else {
      _filteredElements = _elements.where((element) {
        final queryLower = query.toLowerCase();
        switch (_searchType) {
          case SearchType.name:
            return element.name.toLowerCase().contains(queryLower);
          case SearchType.symbol:
            return element.symbol.toLowerCase().contains(queryLower);
          case SearchType.atomicNumber:
            return element.number.toString().contains(query);
          case SearchType.atomicMass:
            return element.atomicMass.toString().contains(query);
          case SearchType.category:
            return element.category.toLowerCase().contains(queryLower);
          case SearchType.phase:
            return element.phase.toLowerCase().contains(queryLower);
          case SearchType.meltingPoint:
            return element.meltingPoint?.toString().contains(query) ?? false;
          case SearchType.boilingPoint:
            return element.boilingPoint?.toString().contains(query) ?? false;
        }
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
      _filteredElements = _elements;
      await _loadSettings();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'خطا در بارگذاری داده‌ها: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}