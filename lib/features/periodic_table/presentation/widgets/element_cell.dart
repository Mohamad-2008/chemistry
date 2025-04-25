import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/constants/app_colors.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';

class ElementCell extends StatefulWidget {
  final ElementModel? element;

  const ElementCell({super.key, this.element});

  @override
  _ElementCellState createState() => _ElementCellState();
}

class _ElementCellState extends State<ElementCell> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  bool _isMounted = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isMounted) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed && _isMounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PeriodicTableProvider>(context);
    final isSelected = widget.element != null && widget.element == provider.selectedElement;

    if (isSelected && !_animationController.isAnimating && _isMounted && _isSearching) {
      _animationController.forward();
    } else if ((!isSelected || !_isSearching) && _animationController.isAnimating && _isMounted) {
      _animationController.stop();
      _animationController.reset();
    }

    // برای لانتانیدها و آکتینیدها هیچ عملی انجام نده
    if (widget.element != null && widget.element!.number == 0) {
      return _buildCellContent();
    }

    return GestureDetector(
      onTap: widget.element != null
          ? () {
              setState(() {
                _isSearching = false;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_isMounted) {
                  provider.selectElement(widget.element);
                  Navigator.pushNamed(
                    context,
                    '/element_details',
                    arguments: widget.element,
                  );
                }
              });
            }
          : null,
      child: _isSearching && isSelected
          ? AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.5 * _glowAnimation.value),
                        blurRadius: 15 * _glowAnimation.value,
                        spreadRadius: 5 * _glowAnimation.value,
                      ),
                    ],
                  ),
                  child: _buildCellContent(),
                );
              },
            )
          : _buildCellContent(),
    );
  }

  Widget _buildCellContent() {
    if (widget.element == null) {
      return Container(
        width: 64,
        height: 64,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    // برای لانتانیدها و آکتینیدها
    if (widget.element!.number == 0) {
      return Container(
        width: 64,
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
            widget.element!.symbol,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Vazir',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final provider = Provider.of<PeriodicTableProvider>(context);
    final thirdItemValue = provider.getThirdItemValue(widget.element!);
    final isSelected = widget.element == provider.selectedElement;
    final categoryColor = _getCategoryColor(widget.element!.category);

    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: categoryColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: Text(
              widget.element!.number.toString(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
            ),
          ),
          Center(
            child: Text(
              widget.element!.symbol,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Text(
              widget.element!.category,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontFamily: 'Vazir',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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