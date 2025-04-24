import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';
import 'package:periodic_table_app/core/utils/color_utils.dart';
import 'package:periodic_table_app/core/utils/translation_utils.dart';

class ElementDetailsScreen extends StatefulWidget {
  final ElementDetailsModel element;

  const ElementDetailsScreen({Key? key, required this.element}) : super(key: key);

  @override
  _ElementDetailsScreenState createState() => _ElementDetailsScreenState();
}

class _ElementDetailsScreenState extends State<ElementDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                        context,
                        'اطلاعات کلی',
                        Icons.info_outline,
                        [
                          _buildInfoRow('عدد اتمی', widget.element.number.toString(), Icons.numbers),
                          _buildInfoRow('نماد', widget.element.symbol, Icons.science),
                          _buildInfoRow('دسته‌بندی', _formatCategory(widget.element.category), Icons.category),
                          _buildInfoRow('گروه', widget.element.xpos.toString(), Icons.grid_view),
                          _buildInfoRow('دوره', widget.element.ypos.toString(), Icons.timeline),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        'خواص فیزیکی',
                        Icons.thermostat,
                        [
                          _buildInfoRow('جرم اتمی', widget.element.atomicMass, Icons.scale),
                          _buildInfoRow('فاز', widget.element.phase, Icons.water_drop),
                          _buildInfoRow(
                            'ظاهر',
                            widget.element.appearance.isNotEmpty ? widget.element.appearance : 'نامشخص',
                            Icons.visibility,
                          ),
                          if (widget.element.physicalProperties['density'] != null)
                            _buildInfoRow(
                              'چگالی',
                              '${widget.element.physicalProperties['density']} g/L',
                              Icons.density_medium,
                            ),
                          if (widget.element.physicalProperties['melt'] != null)
                            _buildInfoRow(
                              'نقطه ذوب',
                              '${widget.element.physicalProperties['melt']} K',
                              Icons.whatshot,
                            ),
                          if (widget.element.physicalProperties['boil'] != null)
                            _buildInfoRow(
                              'نقطه جوش',
                              '${widget.element.physicalProperties['boil']} K',
                              Icons.local_fire_department,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        'خواص شیمیایی',
                        Icons.biotech,
                        [
                          if (widget.element.electronegativity != null)
                            _buildInfoRow(
                              'الکترونگاتیوی',
                              widget.element.electronegativity.toString(),
                              Icons.electric_bolt,
                            ),
                          if (widget.element.ionizationEnergy != null)
                            _buildInfoRow(
                              'انرژی یونش',
                              '${widget.element.ionizationEnergy} kJ/mol',
                              Icons.energy_savings_leaf,
                            ),
                          if (widget.element.oxidationStates != null)
                            _buildInfoRow(
                              'حالت اکسایش',
                              widget.element.oxidationStates!.join(', '),
                              Icons.swap_horiz,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        'خواص اتمی',
                        Icons.scatter_plot,
                        [
                          if (widget.element.electronConfiguration != null)
                            _buildInfoRow(
                              'پیکربندی الکترونی',
                              widget.element.electronConfiguration!,
                              Icons.electrical_services,
                            ),
                          if (widget.element.atomicRadius != null)
                            _buildInfoRow(
                              'شعاع اتمی',
                              '${widget.element.atomicRadius} pm',
                              Icons.circle,
                            ),
                          if (widget.element.covalentRadius != null)
                            _buildInfoRow(
                              'شعاع کووالانسی',
                              '${widget.element.covalentRadius} pm',
                              Icons.link,
                            ),
                          if (widget.element.halfLife != null)
                            _buildInfoRow(
                              'نیمه‌عمر',
                              widget.element.halfLife!,
                              Icons.hourglass_bottom,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        'اطلاعات تاریخی',
                        Icons.history,
                        [
                          _buildInfoRow(
                            'کاشف',
                            widget.element.discoveredBy.isNotEmpty ? widget.element.discoveredBy : 'نامشخص',
                            Icons.person_search,
                          ),
                          _buildInfoRow(
                            'نام‌گذاری شده توسط',
                            widget.element.namedBy.isNotEmpty ? widget.element.namedBy : 'نامشخص',
                            Icons.edit,
                          ),
                          _buildInfoRow('منبع', widget.element.source, Icons.source),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        'خلاصه',
                        Icons.description,
                        [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: _buildInfoRow(
                              'توضیحات',
                              widget.element.summary.isNotEmpty ? widget.element.summary : 'خلاصه‌ای موجود نیست.',
                              Icons.text_fields,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final categoryColor = ColorUtils.getCategoryColor(widget.element.category);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SliverAppBar(
        // collapsedHeight: 60,
        expandedHeight: 300.0,
        floating: false,
        pinned: true,
        stretch: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                // لینک به ویکی‌پدیا
                // می‌توانید اینجا کد مربوط به باز کردن لینک ویکی‌پدیا را اضافه کنید
              },
            ),
          ),
        ],
        flexibleSpace: LayoutBuilder(
          builder: (context, constraints) {
            final isExpanded = constraints.maxHeight > 180;

            return Stack(
              children: [
                FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(
                    bottom: isExpanded ? 18.0 : 8,
                    left: isExpanded ? 18 : 52,
                    right: 12,
                  ),
                  title: FadeTransition(
                    opacity: _fadeAnimation,
                    child: isExpanded
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    TranslationUtils.translate(widget.element.name),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontFamily: 'Vazir',
                                      shadows: [
                                        Shadow(
                                          blurRadius: 6,
                                          color: Colors.black54,
                                          offset: Offset(-1, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        widget.element.symbol,
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Vazir',
                                          shadows: [
                                            Shadow(
                                              blurRadius: 6,
                                              color: Colors.black54,
                                              offset: Offset(-1, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        widget.element.number.toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Vazir',
                                          shadows: [
                                            Shadow(
                                              blurRadius: 6,
                                              color: Colors.black54,
                                              offset: Offset(-1, 2),
                                            ),
                                          ],
                                        ),
                                      ),                                      
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${widget.element.atomicMass} (g/mol)',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Vazir',
                                      shadows: [
                                        Shadow(
                                          blurRadius: 6,
                                          color: Colors.black54,
                                          offset: Offset(-2, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 2,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  TranslationUtils.translate(widget.element.category.toUpperCase()),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Vazir',
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    widget.element.symbol,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Vazir',
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                              
                                    children: [
                                      Text(
                                    TranslationUtils.translate(widget.element.name),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Vazir',
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4.0,
                                          color: Colors.black54,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 4,),
                                  Text(
                                    TranslationUtils.translate('${widget.element.number}'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Vazir',
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4.0,
                                          color: Colors.black54,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.element.atomicMass} (g/mol)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontFamily: 'Vazir',
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4.0,
                                          color: Colors.black54,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'element_${widget.element.number}',
                        child: widget.element.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.element.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildFallbackImage(context),
                              )
                            : _buildFallbackImage(context),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    color: categoryColor,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallbackImage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorUtils.getCategoryColor(widget.element.category),
            ColorUtils.getCategoryColor(widget.element.category).withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.element.symbol,
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(blurRadius: 10.0, color: Colors.black54),
                ],
              ),
            ),
            Text(
              TranslationUtils.translate(widget.element.name),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                fontFamily: 'Vazir',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[850]!,
              Colors.grey[900]!,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 28),
                const SizedBox(width: 8),
                Text(
                  TranslationUtils.translate(title),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Vazir',
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationUtils.translate(label),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Vazir',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TranslationUtils.translateValue(value),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.4,
                    fontFamily: 'Vazir',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCategory(String category) {
    return category.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}