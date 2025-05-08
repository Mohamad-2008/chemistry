import 'package:flutter/material.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/custom_snack_bar.dart';

enum ThirdItemType {
  name,
  atomicMass,
  category,
  phase,
  meltingPoint,
  boilingPoint,
}

extension ThirdItemTypeExtension on ThirdItemType {
  String get title {
    switch (this) {
      case ThirdItemType.name:
        return 'نام عنصر';
      case ThirdItemType.atomicMass:
        return 'جرم مولی';
      case ThirdItemType.category:
        return 'دسته';
      case ThirdItemType.phase:
        return 'فاز';
      case ThirdItemType.meltingPoint:
        return 'نقطه ذوب';
      case ThirdItemType.boilingPoint:
        return 'نقطه جوش';
    }
  }

  IconData get icon {
    switch (this) {
      case ThirdItemType.name:
        return Icons.text_fields;
      case ThirdItemType.atomicMass:
        return Icons.scale;
      case ThirdItemType.category:
        return Icons.category;
      case ThirdItemType.phase:
        return Icons.science;
      case ThirdItemType.meltingPoint:
        return Icons.whatshot;
      case ThirdItemType.boilingPoint:
        return Icons.local_fire_department;
    }
  }
}

class SettingsMenu extends StatefulWidget {
  final ThirdItemType initialType;

  const SettingsMenu({
    super.key,
    required this.initialType,
  });

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  late ThirdItemType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900]!.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'تنظیمات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazir',
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            ...ThirdItemType.values.map((type) => _buildMenuItem(type)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(ThirdItemType type) {
    final isSelected = type == _selectedType;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blueAccent : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          type.icon,
          color: isSelected ? Colors.blueAccent : Colors.white70,
          size: 24,
        ),
        title: Text(
          type.title,
          style: TextStyle(
            color: isSelected ? Colors.blueAccent : Colors.white,
            fontFamily: 'Vazir',
            fontSize: 16,
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle,
                color: Colors.blueAccent,
                size: 24,
              )
            : null,
        onTap: () {
          setState(() {
            _selectedType = type;
          });
          CustomSnackBar.show(context, 'تنظیمات با موفقیت ذخیره شد');
          Navigator.pop(context, type);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
} 