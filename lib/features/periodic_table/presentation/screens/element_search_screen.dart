import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/features/periodic_table/data/repositories/periodic_table_repository.dart';
import 'package:periodic_table_app/core/utils/color_utils.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/search_type.dart';

class ElementSearchScreen extends StatefulWidget {
  final ElementDetailsModel firstElement;

  const ElementSearchScreen({
    Key? key,
    required this.firstElement,
  }) : super(key: key);

  @override
  State<ElementSearchScreen> createState() => _ElementSearchScreenState();
}

class _ElementSearchScreenState extends State<ElementSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<ElementModel> _elements = [];
  List<ElementModel> _filteredElements = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  SearchType _selectedSearchType = SearchType.name;
  final Map<String, ElementDetailsModel> _elementDetailsCache = {};
  final List<String> _categorySuggestions = [
    'فلز قلیایی',
    'فلز قلیایی خاکی',
    'فلز واسطه',
    'فلز پس از انتقال',
    'شبه فلز',
    'نافلز',
    'هالوژن',
    'گاز نجیب',
    'لانتانید',
    'آکتینید',
  ];
  final Map<String, String> _categoryTranslations = {
    'alkali metal': 'فلز قلیایی',
    'alkaline earth metal': 'فلز قلیایی خاکی',
    'transition metal': 'فلز واسطه',
    'post-transition metal': 'فلز پس از انتقال',
    'metalloid': 'شبه فلز',
    'nonmetal': 'نافلز',
    'halogen': 'هالوژن',
    'noble gas': 'گاز نجیب',
    'lanthanide': 'لانتانید',
    'actinide': 'آکتینید',
  };
  final Map<String, String> _phaseTranslations = {
    'solid': 'جامد',
    'liquid': 'مایع',
    'gas': 'گاز',
  };
  final List<String> _phaseSuggestions = [
    'جامد',
    'مایع',
    'گاز',
  ];
  List<String> _currentSuggestions = [];
  bool _showSuggestions = false;
  bool _shouldShowKeyboard = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _searchFocusNode.addListener(_handleFocusChange);
    _loadElements();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ElementSearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firstElement != widget.firstElement) {
      _updateSuggestions(_searchController.text);
    }
  }

  Future<void> _loadElements() async {
    try {
      final elements = await PeriodicTableRepository().getElements();
      setState(() {
        _elements.addAll(elements);
        _filteredElements = List.from(_elements);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری عناصر: $e')),
        );
      }
    }
  }

  Future<ElementDetailsModel?> _getElementDetails(String symbol) async {
    try {
      if (_elementDetailsCache.containsKey(symbol)) {
        return _elementDetailsCache[symbol];
      }
      final details = await PeriodicTableRepository().getElementDetails(symbol);
      if (details != null) {
        _elementDetailsCache[symbol] = details;
      }
      return details;
    } catch (e) {
      debugPrint('خطا در دریافت جزئیات عنصر $symbol: $e');
      return null;
    }
  }

  void _handleFocusChange() {
    if (_searchFocusNode.hasFocus &&
        (_selectedSearchType == SearchType.category || _selectedSearchType == SearchType.phase)) {
      setState(() {
        _showSuggestions = true;
        _shouldShowKeyboard = false;
      });
    }
  }

  void _updateSuggestions(String query) {
    if (_selectedSearchType == SearchType.category) {
      setState(() {
        _currentSuggestions = _categorySuggestions;
        _showSuggestions = true;
        _shouldShowKeyboard = false;
      });
    } else if (_selectedSearchType == SearchType.phase) {
      setState(() {
        _currentSuggestions = _phaseSuggestions;
        _showSuggestions = true;
        _shouldShowKeyboard = false;
      });
    } else {
      setState(() {
        _showSuggestions = false;
        _shouldShowKeyboard = true;
      });
    }
  }

  void _showSearchTypeMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'انتخاب نوع جستجو',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Vazir',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: SearchType.values.map((type) => ListTile(
                    title: Text(
                      type.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Vazir',
                      ),
                    ),
                    trailing: _selectedSearchType == type
                        ? Icon(Icons.check, color: Colors.blue[300])
                        : null,
                    onTap: () {
    setState(() {
                        _selectedSearchType = type;
                        _searchController.clear();
                        _filterElements('');
                      });
                      _updateSuggestions('');
                      Navigator.pop(context);
                    },
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _filterElements(String query) async {
      if (query.isEmpty) {
      setState(() {
        _filteredElements = List.from(_elements);
        if (_selectedSearchType == SearchType.category || _selectedSearchType == SearchType.phase) {
          _updateSuggestions('');
        }
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final filtered = <ElementModel>[];

      switch (_selectedSearchType) {
        case SearchType.name:
        case SearchType.symbol:
        case SearchType.atomicNumber:
        case SearchType.atomicMass:
        case SearchType.category:
        case SearchType.phase:
          filtered.addAll(_elements.where((element) {
            switch (_selectedSearchType) {
              case SearchType.name:
                return element.name.toLowerCase().contains(query.toLowerCase());
              case SearchType.symbol:
                return element.symbol.toLowerCase().contains(query.toLowerCase());
              case SearchType.atomicNumber:
                return element.number.toString().contains(query);
              case SearchType.atomicMass:
                return element.atomicMass.toString().toLowerCase().contains(query.toLowerCase());
              case SearchType.category:
                final category = element.category.toLowerCase();
                final queryLower = query.toLowerCase();
                return category.contains(queryLower) ||
                       (_categoryTranslations[category]?.toLowerCase().contains(queryLower) ?? false);
              case SearchType.phase:
                final phase = element.phase.toLowerCase();
                final queryLower = query.toLowerCase();
                return phase.contains(queryLower) ||
                       (_phaseTranslations[phase]?.toLowerCase().contains(queryLower) ?? false);
              default:
                return false;
            }
          }));
          break;

        case SearchType.meltingPoint:
        case SearchType.boilingPoint:
          for (final element in _elements) {
            final details = await _getElementDetails(element.symbol);
            if (details != null) {
              final value = _selectedSearchType == SearchType.meltingPoint
                  ? details.physicalProperties['melt']?.toString()
                  : details.physicalProperties['boil']?.toString();
              if (value != null && value.contains(query)) {
                filtered.add(element);
              }
            }
          }
          break;
      }

      if (mounted) {
        setState(() {
          _filteredElements = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در جستجو: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'انتخاب عنصر برای مقایسه',
            style: TextStyle(
              fontFamily: 'Vazir',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
            child: TextField(
              controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: (value) {
                              _filterElements(value);
                              _updateSuggestions(value);
                            },
                            onSubmitted: (_) {
                              _searchFocusNode.unfocus();
                              if (_selectedSearchType == SearchType.category ||
                                  _selectedSearchType == SearchType.phase) {
                                setState(() {
                                  _showSuggestions = true;
                                });
                              }
                            },
                            keyboardType: _selectedSearchType == SearchType.atomicNumber ||
                                    _selectedSearchType == SearchType.atomicMass ||
                                    _selectedSearchType == SearchType.meltingPoint ||
                                    _selectedSearchType == SearchType.boilingPoint
                                ? TextInputType.number
                                : TextInputType.text,
                            inputFormatters: _selectedSearchType == SearchType.atomicNumber ||
                                    _selectedSearchType == SearchType.atomicMass ||
                                    _selectedSearchType == SearchType.meltingPoint ||
                                    _selectedSearchType == SearchType.boilingPoint
                                ? [FilteringTextInputFormatter.digitsOnly]
                                : null,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Vazir',
                              fontSize: 16,
                            ),
              decoration: InputDecoration(
                              hintText: 'جستجوی عنصر بر اساس ${_selectedSearchType.title}...',
                              hintStyle: TextStyle(
                                fontFamily: 'Vazir',
                                color: Colors.white.withOpacity(0.6),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white.withOpacity(0.6),
                              ),
                border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                ),
                filled: true,
                              fillColor: Colors.transparent,
                            ),
              ),
            ),
          ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          onPressed: _showSearchTypeMenu,
                        ),
                      ),
                    ],
                  ),
                  if (_showSuggestions)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Scrollbar(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _currentSuggestions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                _currentSuggestions[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Vazir',
                                ),
                              ),
                              onTap: () {
                                _searchController.text = _currentSuggestions[index];
                                _filterElements(_currentSuggestions[index]);
                                _searchFocusNode.unfocus();
                                setState(() {
                                  _showSuggestions = false;
                                });
                              },
                            );
                          },
                              ),
                            ),
                          ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredElements.length,
                        itemBuilder: (context, index) {
                          final element = _filteredElements[index];
                          final categoryColor = ColorUtils.getCategoryColor(element.category);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                          onTap: () async {
                            final secondElement = await PeriodicTableRepository()
                                .getElementDetails(element.symbol);
                            if (secondElement != null && mounted) {
                              Navigator.pushReplacementNamed(
                                context,
                                '/element_comparison',
                                arguments: {
                                  'element1': widget.firstElement,
                                  'element2': secondElement,
                                },
                              );
                            }
                          },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[850],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: categoryColor.withOpacity(0.5),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: categoryColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: categoryColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            element.symbol,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: categoryColor,
                                              fontFamily: 'Vazir',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              element.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontFamily: 'Vazir',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'عدد اتمی: ${element.number}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white.withOpacity(0.7),
                                                fontFamily: 'Vazir',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white.withOpacity(0.5),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ),
                      );
                    },
                      ),
                  ),
          ),
        ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_handleFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}