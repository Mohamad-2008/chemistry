import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/utils/color_utils.dart';

class PeriodicTableGrid extends StatelessWidget {
  final List<ElementModel> elements;
  final bool Function(ElementModel) isElementActive;

  const PeriodicTableGrid({
    super.key,
    required this.elements,
    required this.isElementActive,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 18,
        childAspectRatio: 1,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: elements.length,
      itemBuilder: (context, index) {
        final element = elements[index];
        final isActive = isElementActive(element);
        
        return Opacity(
          opacity: isActive ? 1.0 : 0.3,
          child: Container(
            width: 68,
            height: 68,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: ColorUtils.getCategoryColor(element.category),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  element.symbol,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Vazir',
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  element.number.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontFamily: 'Vazir',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 