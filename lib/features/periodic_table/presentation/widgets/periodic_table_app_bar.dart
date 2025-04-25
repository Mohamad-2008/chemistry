import 'package:flutter/material.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/custom_snack_bar.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/settings_menu.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';

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

  @override
  Size get preferredSize => const Size.fromHeight(56);

  void _showSettingsMenu(BuildContext context) {
    final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: SettingsMenu(initialType: provider.thirdItemType),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ).then((value) {
      if (value != null) {
        provider.setThirdItemType(value as ThirdItemType);
      }
    });
  }

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
            title: const Text(
              'جدول تناوبی',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => _showSettingsMenu(context),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: onSearchPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}