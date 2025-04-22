import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/constants/app_colors.dart';
import 'package:periodic_table_app/core/models/element_model.dart';

class ElementCell extends StatelessWidget {
  final ElementModel? element;

  const ElementCell({super.key, this.element});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: element != null
          ? () => _showElementDetails(context, element!)
          : null,
      child: Container(
        width: 64,
        height: 64,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: element != null ? _getCategoryColor(element!.category) : Colors.transparent,
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: element != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              element!.symbol,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: element!.symbol == 'لانتانیدها' || element!.symbol == 'آکتینیدها' ? 13   : 18,
                color: Colors.white,
                overflow: TextOverflow.visible,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            Text(
              _getNumberText(element!),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        )
            : null,
      ),
    );
  }

  String _getNumberText(ElementModel element) {
    if (element.symbol == 'لانتانیدها') {
      return '57-71'; // بازه اعداد برای لانتانیدها
    } else if (element.symbol == 'آکتینیدها') {
      return '89-103'; // بازه اعداد برای آکتینیدها
    } else if (element.number == 0) {
      return ''; // اگر عدد 0 بود، چیزی نمایش نده
    }
    return element.number.toString();
  }

  void _showElementDetails(BuildContext context, ElementModel element) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.scaffoldBackground,
        title: Text(
          element.name,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نماد: ${element.symbol}', style: const TextStyle(color: Colors.white)),
            Text('عدد اتمی: ${_getNumberText(element)}', style: const TextStyle(color: Colors.white)),
            Text('جرم اتمی: ${element.atomicMass}', style: const TextStyle(color: Colors.white)),
            Text('فاز: ${element.phase}', style: const TextStyle(color: Colors.white)),
            Text('دسته‌بندی: ${element.category}', style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'diatomic nonmetal':
        return AppColors.diatomicNonmetal;
      case 'noble gas':
        return AppColors.nobleGas;
      case 'alkali metal':
        return AppColors.alkaliMetal;
      case 'alkaline earth metal':
        return AppColors.alkalineEarthMetal;
      case 'metalloid':
        return AppColors.metalloid;
      case 'polyatomic nonmetal':
        return AppColors.polyatomicNonmetal;
      case 'post-transition metal':
        return AppColors.postTransitionMetal;
      case 'transition metal':
        return AppColors.transitionMetal;
      case 'lanthanide':
        return AppColors.lanthanide;
      case 'actinide':
        return AppColors.actinide;
      default:
        return AppColors.unknown;
    }
  }
}