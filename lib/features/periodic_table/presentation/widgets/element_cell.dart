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
  late Animation<double> _scaleAnimation;
  bool _isMounted = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOutSine)),
        weight: 33.33,
      ),
      TweenSequenceItem(
        tween: TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.4, end: 1.35).chain(CurveTween(curve: Curves.easeInOutSine)),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.35, end: 1.4).chain(CurveTween(curve: Curves.easeInOutSine)),
            weight: 50,
          ),
        ]),
        weight: 22.22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.easeInSine)),
        weight: 44.45,
      ),
    ]).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isMounted) {
        _animationController.reset();
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

    if (isSelected && !_animationController.isAnimating && !_animationController.isCompleted && _isMounted && _isSearching) {
      _animationController.forward();
    } else if ((!isSelected || !_isSearching) && _animationController.isAnimating && _isMounted) {
      _animationController.stop();
      _animationController.reset();
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
          ? ScaleTransition(
              scale: _scaleAnimation,
              child: _buildElementContainer(isSelected),
            )
          : _buildElementContainer(isSelected),
    );
  }

  Widget _buildElementContainer(bool isSelected) {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: widget.element != null ? _getCategoryColor(widget.element!.category) : Colors.transparent,
        border: Border.all(
          color: isSelected ? Colors.yellow : AppColors.borderColor,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: widget.element != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.element!.number == 0)
                  Text(
                    widget.element!.symbol,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.element!.symbol,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.element!.number.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
              ],
            )
          : null,
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