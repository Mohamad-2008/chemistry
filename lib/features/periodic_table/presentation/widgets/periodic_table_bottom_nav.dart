import 'package:flutter/material.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/custom_snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';
import 'package:periodic_table_app/features/chat_bot/presentation/screens/chat_bot_screen.dart';

class PeriodicTableBottomNav extends StatefulWidget {
  final bool isVisible;
  final Orientation orientation;
  final Widget Function(String route) contentBuilder;

  const PeriodicTableBottomNav({
    super.key,
    required this.isVisible,
    required this.orientation,
    required this.contentBuilder,
  });

  @override
  State<PeriodicTableBottomNav> createState() => _PeriodicTableBottomNavState();
}

class _PeriodicTableBottomNavState extends State<PeriodicTableBottomNav> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<String> _routes = ['/', '/list', '/charts', '/chat_bot', '/main_menu'];
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orientation != Orientation.portrait && !widget.isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(
        0,
        widget.isVisible ? 0 : 100,
        0,
      ),
      child: AnimatedOpacity(
        opacity: widget.isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.blueGrey[900]!.withOpacity(0.95),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_on),
              _buildNavItem(1, Icons.format_list_bulleted),
              _buildNavItem(2, Icons.bar_chart),
              _buildNavItem(3, Icons.chat_bubble_outline),
              _buildNavItem(4, Icons.home),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          CustomSnackBar.show(context, 'لیست اتم‌ها به زودی اضافه می‌شود!');
          return;
        }
        if (index == 2) {
          CustomSnackBar.show(context, 'جدول‌ها و نمودارها به زودی اضافه می‌شود!');
          return;
        }
        setState(() {
          _selectedIndex = index;
          _animationController.reset();
          _animationController.forward();
        });
        final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatBotScreen(),
            ),
          ).then((_) {
            setState(() {
              _selectedIndex = 0;
              _animationController.reset();
              _animationController.forward();
            });
            final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
            provider.setCurrentRoute('/');
          });
        } else {
          provider.setCurrentRoute(_routes[index]);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueGrey[800]!.withOpacity(0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              size: 24,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}