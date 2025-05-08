import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/custom_snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/search_type.dart';

class SearchDialog extends StatefulWidget {
  final Function(ElementModel) onElementSelected;

  const SearchDialog({
    super.key,
    required this.onElementSelected,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController controller = TextEditingController();
  SearchType selectedSearchType = SearchType.name;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    controller.removeListener(_onSearchChanged);
    controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!_isDisposed) {
      final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
      provider.searchElements(controller.text);
    }
  }

  Future<void> _closeDialog() async {
    // اول کیبورد رو می‌بندیم
    FocusScope.of(context).unfocus();
    
    // کمی صبر می‌کنیم تا انیمیشن کیبورد تمام بشه
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_isDisposed && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blueGrey[900]!.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey[800]!.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'جستجو...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      textDirection: TextDirection.rtl,
                      autofocus: true,
                    ),
                  ),
                  PopupMenuButton<SearchType>(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    color: Colors.blueGrey[900],
                    onSelected: (SearchType type) {
                      if (!_isDisposed) {
                        setState(() {
                          selectedSearchType = type;
                          controller.clear();
                          Provider.of<PeriodicTableProvider>(context, listen: false).setSearchType(type);
                          Provider.of<PeriodicTableProvider>(context, listen: false).searchElements('');
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<SearchType>>[
                      const PopupMenuItem<SearchType>(
                        value: SearchType.name,
                        child: Text('نام', style: TextStyle(color: Colors.white), textDirection: TextDirection.rtl),
                      ),
                      const PopupMenuItem<SearchType>(
                        value: SearchType.symbol,
                        child: Text('نماد', style: TextStyle(color: Colors.white), textDirection: TextDirection.rtl),
                      ),
                      const PopupMenuItem<SearchType>(
                        value: SearchType.atomicNumber,
                        child: Text('عدد اتمی', style: TextStyle(color: Colors.white), textDirection: TextDirection.rtl),
                      ),
                      const PopupMenuItem<SearchType>(
                        value: SearchType.atomicMass,
                        child: Text('جرم اتمی', style: TextStyle(color: Colors.white), textDirection: TextDirection.rtl),
                      ),
                      const PopupMenuItem<SearchType>(
                        value: SearchType.category,
                        child: Text('دسته', style: TextStyle(color: Colors.white), textDirection: TextDirection.rtl),
                      ),
                      const PopupMenuItem<SearchType>(
                        value: SearchType.phase,
                        child: Text('فاز', style: TextStyle(color: Colors.white), textDirection: TextDirection.rtl),
                      ),
                      const PopupMenuItem<SearchType>(
                        value: SearchType.meltingPoint,
                        child: Text('نقطه ذوب', style: TextStyle(color: Colors.white), textDirection: TextDirection.rtl),
                      ),
                      const PopupMenuItem<SearchType>(
                        value: SearchType.boilingPoint,
                        child: Text('نقطه جوش', style: TextStyle(color: Colors.white), textDirection: TextDirection.rtl),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _closeDialog,
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Consumer<PeriodicTableProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (provider.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              provider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                provider.loadPeriodicTableData();
                              },
                              child: const Text('دوباره امتحان کنید'),
                            ),
                          ],
                        ),
                      );
                    }

                    final elements = provider.elements.where((element) {
                      if (element.number == 0) return false;
                      final query = controller.text.toLowerCase();
                      if (query.isEmpty) return true;
                      
                      switch (selectedSearchType) {
                        case SearchType.name:
                          return element.name.toLowerCase().contains(query);
                        case SearchType.symbol:
                          return element.symbol.toLowerCase().contains(query);
                        case SearchType.atomicNumber:
                          return element.number.toString().contains(query);
                        case SearchType.atomicMass:
                          return element.atomicMass.toString().contains(query);
                        case SearchType.category:
                          return element.category.toLowerCase().contains(query);
                        case SearchType.phase:
                          return element.phase.toLowerCase().contains(query);
                        case SearchType.meltingPoint:
                          return element.meltingPoint?.toString().contains(query) ?? false;
                        case SearchType.boilingPoint:
                          return element.boilingPoint?.toString().contains(query) ?? false;
                      }
                    }).toList();

                    if (elements.isEmpty) {
                      return const Center(
                        child: Text(
                          'نتیجه‌ای یافت نشد',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: elements.length,
                      itemBuilder: (context, index) {
                        final element = elements[index];
                        return ListTile(
                          title: Text(
                            '${element.name} (${element.symbol})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Vazir',
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          subtitle: Text(
                            'عدد اتمی: ${element.number} | جرم اتمی: ${element.atomicMass}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          onTap: () async {
                            // اول کیبورد رو می‌بندیم
                            FocusScope.of(context).unfocus();
                            
                            // کمی صبر می‌کنیم تا انیمیشن کیبورد تمام بشه
                            await Future.delayed(const Duration(milliseconds: 100));
                            
                            if (!_isDisposed && mounted) {
                              Navigator.of(context).pop();
                              widget.onElementSelected(element);
                            }
                          },
                        );
                      },
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
}