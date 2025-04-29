import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/element_cell.dart';

class PeriodicTableGrid extends StatelessWidget {
  final List<ElementModel> elements;

  const PeriodicTableGrid({super.key, required this.elements});

  @override
  Widget build(BuildContext context) {
    List<List<ElementModel?>> grid = List.generate(10, (_) => List.filled(18, null));

    for (var element in elements) {
      if (element.ypos <= 10 && element.xpos <= 18) {
        grid[element.ypos - 1][element.xpos - 1] = element;
      }
    }

    // اضافه کردن ارجاع به لانتانیدها و آکتینیدها
    grid[5][2] = ElementModel(
      name: 'لانتانیدها',
      symbol: 'لانتانیدها', // تغییر از * به لانتانیدها
      number: 0, // عدد صفر برای نمایش ندادن (در ElementCell تنظیم می‌کنیم که نمایش داده نشود)
      xpos: 3,
      ypos: 6,
      category: 'lanthanide',
      atomicMass: 0.0,
      phase: '',
    );

    grid[6][2] = ElementModel(
      name: 'آکتینیدها',
      symbol: 'آکتینیدها', // تغییر از * به آکتینیدها
      number: 0, // عدد صفر برای نمایش ندادن (در ElementCell تنظیم می‌کنیم که نمایش داده نشود)
      xpos: 3,
      ypos: 7,
      category: 'actinide',
      atomicMass: 0.0,
      phase: '',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // نوار گروه‌ها (بالا)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 42), // فضای خالی برای ستون دوره‌ها (عرض کمتر)
            ...List.generate(18, (index) {
              return Container(
                width: 64,
                height: 35,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900]!.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        // جدول اصلی با نوار دوره‌ها (کنار)
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نوار دوره‌ها (کنار)
            Column(
              children: [
                // دوره‌های 1 تا 7
                ...List.generate(7, (index) {
                  return Container(
                    width: 40, // عرض کمتر
                    height: 64,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900]!.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (index + 1).toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                // لانتانیدها و آکتینیدها
                Container(
                  width: 40, // عرض کمتر
                  height: 64,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[900]!.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'لانتانیدها',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 40, // عرض کمتر
                  height: 64,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[900]!.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'آکتینیدها',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // جدول اصلی
            Column(
              children: [
                // جدول اصلی (ردیف‌های 1 تا 7)
                ...List.generate(7, (rowIndex) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(18, (colIndex) {
                      final element = grid[rowIndex][colIndex];
                      return ElementCell(element: element);
                    }),
                  );
                }),
                const SizedBox(height: 16),
                // لانتانیدها و آکتینیدها (ردیف‌های 8 و 9)
                ...List.generate(2, (rowIndex) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 70),
                      ...List.generate(15, (colIndex) {
                        final element = grid[rowIndex + 8][colIndex + 2];
                        return ElementCell(element: element);
                      }),
                    ],
                  );
                }),
                const SizedBox(height: 80),
              ],
            ),
          ],
        ),
      ],
    );
  }
}