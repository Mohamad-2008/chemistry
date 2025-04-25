import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';
import 'package:periodic_table_app/core/utils/color_utils.dart';

class ElementComparisonScreen extends StatelessWidget {
  final ElementDetailsModel element1;
  final ElementDetailsModel element2;

  const ElementComparisonScreen({
    Key? key,
    required this.element1,
    required this.element2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مقایسه عناصر', style: TextStyle(fontFamily: 'Vazir')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildElementHeaders(),
              const SizedBox(height: 16),
              _buildComparisonSection('اطلاعات کلی', [
                _buildComparisonRow('عدد اتمی', element1.number.toString(), element2.number.toString()),
                _buildComparisonRow('نماد', element1.symbol, element2.symbol),
                _buildComparisonRow('دسته‌بندی', element1.category, element2.category),
                _buildComparisonRow('گروه', element1.xpos.toString(), element2.xpos.toString()),
                _buildComparisonRow('دوره', element1.ypos.toString(), element2.ypos.toString()),
              ]),
              _buildComparisonSection('خواص فیزیکی', [
                _buildComparisonRow('جرم اتمی', element1.atomicMass, element2.atomicMass),
                _buildComparisonRow('فاز', element1.phase, element2.phase),
                if (element1.physicalProperties['density'] != null || element2.physicalProperties['density'] != null)
                  _buildComparisonRow(
                    'چگالی',
                    '${element1.physicalProperties['density'] ?? 'نامشخص'} g/L',
                    '${element2.physicalProperties['density'] ?? 'نامشخص'} g/L',
                  ),
                if (element1.physicalProperties['melt'] != null || element2.physicalProperties['melt'] != null)
                  _buildComparisonRow(
                    'نقطه ذوب',
                    '${element1.physicalProperties['melt'] ?? 'نامشخص'} K',
                    '${element2.physicalProperties['melt'] ?? 'نامشخص'} K',
                  ),
                if (element1.physicalProperties['boil'] != null || element2.physicalProperties['boil'] != null)
                  _buildComparisonRow(
                    'نقطه جوش',
                    '${element1.physicalProperties['boil'] ?? 'نامشخص'} K',
                    '${element2.physicalProperties['boil'] ?? 'نامشخص'} K',
                  ),
              ]),
              _buildComparisonSection('خواص شیمیایی', [
                if (element1.electronegativity != null || element2.electronegativity != null)
                  _buildComparisonRow(
                    'الکترونگاتیوی',
                    element1.electronegativity?.toString() ?? 'نامشخص',
                    element2.electronegativity?.toString() ?? 'نامشخص',
                  ),
                if (element1.ionizationEnergy != null || element2.ionizationEnergy != null)
                  _buildComparisonRow(
                    'انرژی یونش',
                    element1.ionizationEnergy != null ? '${element1.ionizationEnergy} kJ/mol' : 'نامشخص',
                    element2.ionizationEnergy != null ? '${element2.ionizationEnergy} kJ/mol' : 'نامشخص',
                  ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElementHeaders() {
    return Row(
      children: [
        Expanded(
          child: _buildElementHeader(element1),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildElementHeader(element2),
        ),
      ],
    );
  }

  Widget _buildElementHeader(ElementDetailsModel element) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorUtils.getCategoryColor(element.category).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorUtils.getCategoryColor(element.category),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            element.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Vazir',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            element.symbol,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Vazir',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(String title, List<Widget> rows) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
            ),
            const SizedBox(height: 16),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value1, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value1,
              style: const TextStyle(fontSize: 16, fontFamily: 'Vazir'),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              value2,
              style: const TextStyle(fontSize: 16, fontFamily: 'Vazir'),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 