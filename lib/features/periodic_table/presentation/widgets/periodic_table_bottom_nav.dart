import 'package:flutter/material.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/custom_snack_bar.dart';

class PeriodicTableBottomNav extends StatelessWidget {
  final bool isVisible;
  final Orientation orientation;

  const PeriodicTableBottomNav({
    super.key,
    required this.isVisible,
    required this.orientation,
  });

  @override
  Widget build(BuildContext context) {
    if (orientation != Orientation.portrait && !isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(
        0,
        isVisible ? 0 : 100,
        0,
      ),
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.blueGrey[900]!.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 5;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(icon: Icons.grid_on, isActive: true, onTap: () {}),

                  _buildNavItem(icon: Icons.format_list_bulleted, isActive: false, onTap: () {
                    CustomSnackBar.show(context, 'لیست اتم‌ها به زودی اضافه می‌شود!');
                  }),
                  _buildNavItem(icon: Icons.bar_chart, isActive: false, onTap: () {
                    CustomSnackBar.show(context, 'جدول‌ها و نمودارها به زودی اضافه می‌شود!');
                  }),
                  _buildNavItem(icon: Icons.chat_bubble_outline, isActive: false, onTap: () {
                    Navigator.pushNamed(context, '/chat_bot');
                  }),
                  _buildNavItem(icon: Icons.home, isActive: false, onTap: () {
                    CustomSnackBar.show(context, 'منوی اصلی به زودی اضافه می‌شود!');
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0, isActive ? -4 : 0),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
              size: 28,
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.blueAccent : Colors.transparent,
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}