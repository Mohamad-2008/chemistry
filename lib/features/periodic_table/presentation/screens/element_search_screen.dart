import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/features/periodic_table/data/repositories/periodic_table_repository.dart';
import 'package:periodic_table_app/core/utils/color_utils.dart';

class ElementSearchScreen extends StatefulWidget {
  final ElementDetailsModel firstElement;

  const ElementSearchScreen({
    Key? key,
    required this.firstElement,
  }) : super(key: key);

  @override
  State<ElementSearchScreen> createState() => _ElementSearchScreenState();
}

class _ElementSearchScreenState extends State<ElementSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<ElementModel> _elements = [];
  List<ElementModel> _filteredElements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadElements();
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

  void _filterElements(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredElements = List.from(_elements);
      } else {
        _filteredElements = _elements
            .where((element) =>
                element.name.toLowerCase().contains(query.toLowerCase()) ||
                element.symbol.toLowerCase().contains(query.toLowerCase()) ||
                element.number.toString().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('انتخاب عنصر برای مقایسه', style: TextStyle(fontFamily: 'Vazir')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterElements,
              decoration: InputDecoration(
                hintText: 'جستجوی عنصر...',
                hintStyle: const TextStyle(fontFamily: 'Vazir'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredElements.length,
                    itemBuilder: (context, index) {
                      final element = _filteredElements[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: ColorUtils.getCategoryColor(element.category)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ColorUtils.getCategoryColor(element.category),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                element.symbol,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ColorUtils.getCategoryColor(element.category),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            element.name,
                            style: const TextStyle(fontFamily: 'Vazir'),
                          ),
                          subtitle: Text(
                            'عدد اتمی: ${element.number}',
                            style: const TextStyle(fontFamily: 'Vazir'),
                          ),
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 