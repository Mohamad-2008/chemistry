import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';
import 'package:periodic_table_app/core/utils/color_utils.dart';

class ElementComparisonScreen extends StatefulWidget {
  final ElementDetailsModel element1;
  final ElementDetailsModel element2;

  const ElementComparisonScreen({
    Key? key,
    required this.element1,
    required this.element2,
  }) : super(key: key);

  @override
  State<ElementComparisonScreen> createState() => _ElementComparisonScreenState();
}

class _ElementComparisonScreenState extends State<ElementComparisonScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  double _boxHeight = 200.0;
  final double _minBoxHeight = 80.0;
  final double _maxBoxHeight = 150.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
        _boxHeight = _minBoxHeight;
      });
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() {
        _isScrolled = false;
        _boxHeight = _maxBoxHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'مقایسه عناصر',
            style: TextStyle(
              fontFamily: 'Vazir',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildElementBox(widget.element1, true),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildElementBox(widget.element2, false),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildComparisonSection(
                              'اطلاعات کلی',
                              Icons.info_outline,
                              [
                                _buildComparisonRow('عدد اتمی', widget.element1.number.toString(),
                                    widget.element2.number.toString()),
                                _buildComparisonRow('نماد', widget.element1.symbol, widget.element2.symbol),
                                _buildComparisonRow('دسته‌بندی', widget.element1.category,
                                    widget.element2.category),
                                _buildComparisonRow('گروه', widget.element1.xpos.toString(),
                                    widget.element2.xpos.toString()),
                                _buildComparisonRow('دوره', widget.element1.ypos.toString(),
                                    widget.element2.ypos.toString()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildComparisonSection(
                              'خواص فیزیکی',
                              Icons.science,
                              [
                                _buildComparisonRow('جرم اتمی', widget.element1.atomicMass,
                                    widget.element2.atomicMass),
                                _buildComparisonRow('فاز', widget.element1.phase, widget.element2.phase),
                                if (widget.element1.physicalProperties['density'] != null ||
                                    widget.element2.physicalProperties['density'] != null)
                                  _buildComparisonRow(
                                    'چگالی',
                                    '${widget.element1.physicalProperties['density'] ?? 'نامشخص'} g/L',
                                    '${widget.element2.physicalProperties['density'] ?? 'نامشخص'} g/L',
                                  ),
                                if (widget.element1.physicalProperties['melt'] != null ||
                                    widget.element2.physicalProperties['melt'] != null)
                                  _buildComparisonRow(
                                    'نقطه ذوب',
                                    '${widget.element1.physicalProperties['melt'] ?? 'نامشخص'} K',
                                    '${widget.element2.physicalProperties['melt'] ?? 'نامشخص'} K',
                                  ),
                                if (widget.element1.physicalProperties['boil'] != null ||
                                    widget.element2.physicalProperties['boil'] != null)
                                  _buildComparisonRow(
                                    'نقطه جوش',
                                    '${widget.element1.physicalProperties['boil'] ?? 'نامشخص'} K',
                                    '${widget.element2.physicalProperties['boil'] ?? 'نامشخص'} K',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildComparisonSection(
                              'خواص شیمیایی',
                              Icons.biotech,
                              [
                                if (widget.element1.electronegativity != null ||
                                    widget.element2.electronegativity != null)
                                  _buildComparisonRow(
                                    'الکترونگاتیوی',
                                    widget.element1.electronegativity?.toString() ?? 'نامشخص',
                                    widget.element2.electronegativity?.toString() ?? 'نامشخص',
                                  ),
                                if (widget.element1.ionizationEnergy != null ||
                                    widget.element2.ionizationEnergy != null)
                                  _buildComparisonRow(
                                    'انرژی یونش',
                                    widget.element1.ionizationEnergy != null
                                        ? '${widget.element1.ionizationEnergy} kJ/mol'
                                        : 'نامشخص',
                                    widget.element2.ionizationEnergy != null
                                        ? '${widget.element2.ionizationEnergy} kJ/mol'
                                        : 'نامشخص',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildElementBox(ElementDetailsModel element, bool isFirst) {
    final categoryColor = ColorUtils.getCategoryColor(element.category);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _boxHeight,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isScrolled
          ? Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: categoryColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  element.symbol,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: categoryColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      element.symbol,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    element.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'عدد اتمی: ${element.number}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildComparisonSection(String title, IconData icon, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[800],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value1, String value2) {
    final color1 = ColorUtils.getCategoryColor(widget.element1.category);
    final color2 = ColorUtils.getCategoryColor(widget.element2.category);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: color1.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color1.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    value1,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: color2.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color2.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    value2,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}