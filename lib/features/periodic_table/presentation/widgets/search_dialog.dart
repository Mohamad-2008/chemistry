import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/search_type.dart';

void showSearchDialog(BuildContext context, {required Function(ElementModel) onElementSelected}) {
  final TextEditingController controller = TextEditingController();
  SearchType selectedSearchType = SearchType.name;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.blueGrey[900]!.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(16.0),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: '${selectedSearchType.title} را وارد کنید',
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.blueGrey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                          ),
                          style: const TextStyle(color: Colors.white),
                          textDirection: TextDirection.rtl,
                          onChanged: (value) {
                            Provider.of<PeriodicTableProvider>(context, listen: false).searchElements(value);
                            setState(() {}); // به‌روزرسانی لیست نتایج
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<SearchType>(
                        icon: const Icon(Icons.filter_list, color: Colors.white),
                        color: Colors.blueGrey[900],
                        onSelected: (SearchType type) {
                          setState(() {
                            selectedSearchType = type;
                            controller.clear();
                            Provider.of<PeriodicTableProvider>(context, listen: false).setSearchType(type);
                            Provider.of<PeriodicTableProvider>(context, listen: false).searchElements('');
                          });
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<SearchType>>[
                          const PopupMenuItem<SearchType>(
                            value: SearchType.name,
                            child: Text('نام', style: TextStyle(color: Colors.white)),
                          ),
                          const PopupMenuItem<SearchType>(
                            value: SearchType.symbol,
                            child: Text('نماد', style: TextStyle(color: Colors.white)),
                          ),
                          const PopupMenuItem<SearchType>(
                            value: SearchType.atomicNumber,
                            child: Text('عدد اتمی', style: TextStyle(color: Colors.white)),
                          ),
                          const PopupMenuItem<SearchType>(
                            value: SearchType.atomicMass,
                            child: Text('جرم اتمی', style: TextStyle(color: Colors.white)),
                          ),
                          const PopupMenuItem<SearchType>(
                            value: SearchType.category,
                            child: Text('دسته', style: TextStyle(color: Colors.white)),
                          ),
                          const PopupMenuItem<SearchType>(
                            value: SearchType.phase,
                            child: Text('فاز', style: TextStyle(color: Colors.white)),
                          ),
                          const PopupMenuItem<SearchType>(
                            value: SearchType.meltingPoint,
                            child: Text('نقطه ذوب', style: TextStyle(color: Colors.white)),
                          ),
                          const PopupMenuItem<SearchType>(
                            value: SearchType.boilingPoint,
                            child: Text('نقطه جوش', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Consumer<PeriodicTableProvider>(
                      builder: (context, provider, _) {
                        return ListView.builder(
                          itemCount: provider.filteredElements.length,
                          itemBuilder: (context, index) {
                            final element = provider.filteredElements[index];
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
                              onTap: () {
                                final selectedElement = element;
                                FocusScope.of(context).unfocus();
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                    controller.dispose();
                                    onElementSelected(selectedElement);
                                  }
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.dispose();
              Provider.of<PeriodicTableProvider>(context, listen: false).clearSearch();
            },
            child: const Text(
              'بستن',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}