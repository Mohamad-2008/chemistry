import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';

void showSearchDialog(BuildContext context, {required Function(ElementModel) onElementSelected}) {
  final TextEditingController controller = TextEditingController();

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
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'نام یا نماد عنصر را وارد کنید',
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
                                element.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Vazir',
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              subtitle: Text(
                                element.symbol,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                onElementSelected(element);
                                controller.dispose();
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