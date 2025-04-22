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

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900), // کل انیمیشن 0.9 ثانیه
    );

    // تعریف انیمیشن با TweenSequence برای مراحل مختلف
    _scaleAnimation = TweenSequence<double>([
      // مرحله 1: بزرگ شدن نرم (0 تا 0.3 ثانیه)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOutSine)),
        weight: 33.33, // 300 میلی‌ثانیه
      ),
      // مرحله 2: لرزش ظریف (0.3 تا 0.5 ثانیه)
      TweenSequenceItem(
        tween: TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.4, end: 1.35).chain(CurveTween(curve: Curves.easeInOutSine)),
            weight: 50, // 100 میلی‌ثانیه
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.35, end: 1.4).chain(CurveTween(curve: Curves.easeInOutSine)),
            weight: 50, // 100 میلی‌ثانیه
          ),
        ]),
        weight: 22.22, // 200 میلی‌ثانیه
      ),
      // مرحله 3: بازگشت به حالت اولیه (0.5 تا 0.9 ثانیه)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.easeInSine)),
        weight: 44.45, // 400 میلی‌ثانیه
      ),
    ]).animate(_animationController);

    // ریست انیمیشن بعد از اتمام
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

    // اجرای انیمیشن برای عنصر انتخاب‌شده
    if (isSelected && !_animationController.isAnimating && !_animationController.isCompleted && _isMounted) {
      _animationController.forward();
    } else if (!isSelected && _animationController.isAnimating && _isMounted) {
      _animationController.stop();
      _animationController.reset();
    }

    return GestureDetector(
      onTap: widget.element != null
          ? () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isMounted) {
            provider.selectElement(widget.element);
            _showElementDetails(context, widget.element!);
          }
        });
      }
          : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
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
              Text(
                widget.element!.symbol,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: widget.element!.symbol == 'لانتانیدها' || widget.element!.symbol == 'آکتینیدها' ? 13 : 18,
                  color: Colors.white,
                  overflow: TextOverflow.visible,
                ),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
              Text(
                _getNumberText(widget.element!),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          )
              : null,
        ),
      ),
    );
  }

  String _getNumberText(ElementModel element) {
    if (element.symbol == 'لانتانیدها') {
      return '57-71';
    } else if (element.symbol == 'آکتینیدها') {
      return '89-103';
    } else if (element.number == 0) {
      return '';
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