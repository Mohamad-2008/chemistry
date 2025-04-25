import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/features/periodic_table/data/repositories/periodic_table_repository.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/search_type.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/settings_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

// مپ ترجمه دسته بندی ها
const Map<String, String> categoryTranslations = {
  'diatomic nonmetal': 'نافلز دواتمی',
  'noble gas': 'گاز نجیب',
  'alkali metal': 'فلز قلیایی',
  'alkaline earth metal': 'فلز قلیایی خاکی',
  'metalloid': 'شبه‌فلز',
  'polyatomic nonmetal': 'نافلز چنداتمی',
  'post-transition metal': 'فلز پس‌واسطه',
  'transition metal': 'فلز واسطه',
  'lanthanide': 'لانتانید',
  'actinide': 'اکتینید',
  // افزودن سایر دسته بندی ها در صورت نیاز
};

class PeriodicTableProvider with ChangeNotifier {
  List<ElementModel> _allElements = [];
  List<ElementModel> _elementsToDisplay = [];
  bool _isLoading = false;
  String? _errorMessage;
  ElementModel? _selectedElement;
  SearchType _searchType = SearchType.name;
  ThirdItemType _thirdItemType = ThirdItemType.name;
  String _selectedCategoryFilter = 'All';
  String _currentSearchQuery = '';
  String? _currentSort;
  String? _currentCategory;
  String? _currentLetter;
  int? _currentMinNumber;
  int? _currentMaxNumber;

  List<ElementModel> get elements => _elementsToDisplay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ElementModel? get selectedElement => _selectedElement;
  SearchType get searchType => _searchType;
  ThirdItemType get thirdItemType => _thirdItemType;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  String? get currentSort => _currentSort;
  String? get currentCategory => _currentCategory;
  String? get currentLetter => _currentLetter;
  int? get currentMinNumber => _currentMinNumber;
  int? get currentMaxNumber => _currentMaxNumber;

  // تغییر Getter برای برگرداندن لیست مپ ها با کلید و متن نمایشی
  List<Map<String, String>> get categories {
    if (_allElements.isEmpty) return [{'key': 'All', 'display': 'همه انواع (All)'}];

    final categoriesSet = <String>{}; // فقط کلیدهای انگلیسی
    for (var element in _allElements) {
      if (element.number != 0 && 
          !element.category.toLowerCase().contains('unknown') && 
          !element.category.toLowerCase().contains('predicted') && 
          !element.category.toLowerCase().contains('probably') && 
          element.category != 'n/a') {
        categoriesSet.add(element.category);
      }
    }

    // تبدیل به لیست مپ ها
    final categoryList = categoriesSet.map((key) {
       final translation = categoryTranslations[key] ?? key; // اگر ترجمه نبود، خود کلید انگلیسی
       return {'key': key, 'display': '$translation ($key)'};
     }).toList();

    // مرتب سازی بر اساس کلید انگلیسی (اختیاری)
    categoryList.sort((a, b) => a['key']!.compareTo(b['key']!));

    // اضافه کردن گزینه "همه"
    categoryList.insert(0, {'key': 'All', 'display': 'همه انواع (All)'});

    return categoryList;
  }

  void setSearchType(SearchType type) {
    _searchType = type;
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

  void _applyFilters() {
    List<ElementModel> result = _allElements;

    if (_selectedCategoryFilter != 'All') {
      result = result.where((element) => element.category == _selectedCategoryFilter).toList();
    }

    if (_currentSearchQuery.isNotEmpty) {
      final queryLower = _currentSearchQuery.toLowerCase();
      result = result.where((element) {
        if (element.number == 0) return false;
        switch (_searchType) {
          case SearchType.name:
            return element.name.toLowerCase().contains(queryLower);
          case SearchType.symbol:
            return element.symbol.toLowerCase().contains(queryLower);
          case SearchType.atomicNumber:
            return element.number.toString().contains(_currentSearchQuery);
          case SearchType.atomicMass:
            return element.atomicMass.toString().contains(_currentSearchQuery);
          case SearchType.category:
            return element.category.toLowerCase().contains(queryLower);
          case SearchType.phase:
            return element.phase.toLowerCase().contains(queryLower);
          case SearchType.meltingPoint:
            return element.meltingPoint?.toString().contains(_currentSearchQuery) ?? false;
          case SearchType.boilingPoint:
            return element.boilingPoint?.toString().contains(_currentSearchQuery) ?? false;
        }
      }).toList();
    }

    if (_selectedCategoryFilter == 'All' && _currentSearchQuery.isEmpty) {
      final placeholders = _allElements.where((el) => el.number == 0).toList();
      ElementModel? lanthanidePlaceholder;
      ElementModel? actinidePlaceholder;
      for (final p in placeholders) {
           if (p.symbol == '57-71') {
               lanthanidePlaceholder = p;
           } else if (p.symbol == '89-103') {
               actinidePlaceholder = p;
           }
           if (lanthanidePlaceholder != null && actinidePlaceholder != null) {
               break; // هر دو پیدا شدند، نیازی به ادامه حلقه نیست
           }
       }

      final lanthanumIndex = result.indexWhere((el) => el.symbol == 'La');
      if (lanthanumIndex != -1 && lanthanidePlaceholder != null) {
        result.insert(lanthanumIndex + 1, lanthanidePlaceholder);
      }
      final actiniumIndex = result.indexWhere((el) => el.symbol == 'Ac');
      if (actiniumIndex != -1 && actinidePlaceholder != null) {
        result.insert(actiniumIndex + 1, actinidePlaceholder);
      }
    }

    _elementsToDisplay = result;
    notifyListeners();
  }

  void selectCategoryFilter(String category) {
    _selectedCategoryFilter = category;
    _applyFilters();
  }

  void searchElements(String query) {
    _currentSearchQuery = query;
    _applyFilters();
  }

  void clearSearch() {
    _currentSearchQuery = '';
    _selectedElement = null;
    _applyFilters();
  }

  Future<void> loadPeriodicTableData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final repository = PeriodicTableRepository();
      _allElements = await repository.getElements();
      await _loadSettings();
      _applyFilters();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'خطا در بارگذاری داده‌ها: $e';
      _elementsToDisplay = [];
      _allElements = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void sortElements(String sortBy) {
    _currentSort = sortBy;
    
    switch (sortBy) {
      case 'name':
        _elementsToDisplay.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'number':
        _elementsToDisplay.sort((a, b) => a.number.compareTo(b.number));
        break;
      case 'category':
        _elementsToDisplay.sort((a, b) => a.category.compareTo(b.category));
        break;
    }
    
    notifyListeners();
  }

  void setCurrentCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }

  void setCurrentLetter(String letter) {
    _currentLetter = letter;
    notifyListeners();
  }

  void setCurrentNumberRange(int min, int max) {
    _currentMinNumber = min;
    _currentMaxNumber = max;
    notifyListeners();
  }

  void resetSort() {
    _currentSort = null;
    _currentCategory = null;
    _currentLetter = null;
    _currentMinNumber = null;
    _currentMaxNumber = null;
    notifyListeners();
  }
}