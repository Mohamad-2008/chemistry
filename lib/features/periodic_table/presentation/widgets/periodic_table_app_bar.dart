import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/constants/app_colors.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';
import 'package:provider/provider.dart';
import 'custom_snack_bar.dart';

class PeriodicTableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isVisible;
  final Orientation orientation;
  final VoidCallback onSearchPressed;

  const PeriodicTableAppBar({
    super.key,
    required this.isVisible,
    required this.orientation,
    required this.onSearchPressed,
  });

  // لیست دسته‌بندی‌ها به‌صورت دستی تعریف شده
  static const List<String> _categories = [
    'diatomic_nonmetal',
    'noble_gas',
    'alkali_metal',
    'alkaline_earth_metal',
    'metalloid',
    'polyatomic_nonmetal',
    'post-transition_metal',
    'transition_metal',
    'lanthanide',
    'actinide',
    'unknown',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    if (orientation != Orientation.portrait && !isVisible) {
      return const SizedBox.shrink();
    }

    return PreferredSize(
      preferredSize: preferredSize,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(
          0,
          isVisible ? 0 : -56,
          0,
        ),
        child: AnimatedOpacity(
          opacity: isVisible ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: AppBar(
            backgroundColor: Colors.blueGrey[900]!.withOpacity(0.7),
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blueGrey[900]!.withOpacity(0.7),
                    Colors.black.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                CustomSnackBar.show(context, 'بازگشت به زودی اضافه می‌شود!');
              },
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'جدول تناوبی',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazir',
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<ThirdField>(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  tooltip: 'انتخاب فیلد سوم',
                  onSelected: (ThirdField field) {
                    context.read<PeriodicTableProvider>().setThirdField(field);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<ThirdField>>[
                    const PopupMenuItem<ThirdField>(
                      value: ThirdField.atomicMass,
                      child: Text('جرم اتمی'),
                    ),
                    const PopupMenuItem<ThirdField>(
                      value: ThirdField.name,
                      child: Text('نام کامل'),
                    ),
                    const PopupMenuItem<ThirdField>(
                      value: ThirdField.phase,
                      child: Text('فاز'),
                    ),
                    const PopupMenuItem<ThirdField>(
                      value: ThirdField.electronegativity,
                      child: Text('الکترونگاتیوی'),
                    ),
                  ],
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: onSearchPressed,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort, color: Colors.white),
                tooltip: 'سورت بر اساس دسته‌بندی',
                onSelected: (String? category) {
                  context.read<PeriodicTableProvider>().setCategory(category);
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: null,
                    child: Text('همه دسته‌ها'),
                  ),
                  ..._categories.map((category) => PopupMenuItem<String>(
                    value: category,
                    child: Text(category.replaceAll('_', ' ').toUpperCase()),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}