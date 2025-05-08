import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/periodic_table_app_bar.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/periodic_table_bottom_nav.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/periodic_table_grid.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/search_dialog.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/custom_snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';
import 'package:periodic_table_app/utils/color_utils.dart';
import 'package:periodic_table_app/features/chat_bot/presentation/screens/chat_bot_screen.dart';
import 'package:periodic_table_app/core/routes/app_routes.dart';

class PeriodicTableScreen extends StatefulWidget {
  const PeriodicTableScreen({super.key});

  @override
  _PeriodicTableScreenState createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends State<PeriodicTableScreen>
    with TickerProviderStateMixin {
  bool _isAppBarVisible = true;
  late AnimationController _arrowController;
  late AnimationController _fadeController;
  Orientation? orientation;
  final TransformationController _transformationController =
      TransformationController();
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      upperBound: 0.5,
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (_isAppBarVisible) {
      _arrowController.forward();
      _fadeController.forward();
    } else {
      _arrowController.reverse();
      _fadeController.reverse();
    }
    Provider.of<PeriodicTableProvider>(context, listen: false)
        .loadUserProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PeriodicTableProvider>(context, listen: false)
          .setCurrentRoute('/main_menu');
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    _arrowController.dispose();
    _fadeController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    if (_isMounted) {
      setState(() {
        _isAppBarVisible = !_isAppBarVisible;
        if (_isAppBarVisible) {
          _arrowController.forward();
          _fadeController.forward();
        } else {
          _arrowController.reverse();
          _fadeController.reverse();
        }
      });
      HapticFeedback.lightImpact();
    }
  }

  void _scrollToElement(ElementModel element) {
    if (!_isMounted) return;

    const cellSize = 68.0;
    const padding = 16.0;
    const zoomScale = 2.0;
    final x = (element.xpos - 1) * cellSize + padding;
    final y = (element.ypos - 1) * cellSize + padding;

    final screenSize = MediaQuery.of(context).size;
    final matrix = Matrix4.identity()
      ..translate(
        -x * zoomScale + screenSize.width / 2 - (cellSize * zoomScale / 2) - 50,
        -y * zoomScale + screenSize.height / 2 - (cellSize * zoomScale / 2),
      )
      ..scale(zoomScale);

    final moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final moveAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: matrix,
    ).animate(CurvedAnimation(
      parent: moveController,
      curve: Curves.easeInOutCubic,
    ));

    moveController.addListener(() {
      if (_isMounted) {
        _transformationController.value = moveAnimation.value;
      }
    });

    final scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final scaleAnimation = Tween<double>(
      begin: 1.0,
      end: zoomScale,
    ).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeInOutCubic,
    ));

    moveController.forward().then((_) {
      moveController.dispose();
      Future.delayed(const Duration(seconds: 5), () {
        if (_isMounted) {
          scaleController.forward().then((_) {
            scaleController.dispose();
          });
        }
      });
    });
  }

  void _sortElements(String sortBy) {
    final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
    provider.selectCategoryFilter(sortBy);
    HapticFeedback.lightImpact();
  }

  Widget _buildSortButton() {
    return AnimatedScale(
      scale: _isAppBarVisible ? 1.0 : 0.8,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          final RenderBox button = context.findRenderObject() as RenderBox;
          final RenderBox overlay = Navigator.of(context)
              .overlay!
              .context
              .findRenderObject() as RenderBox;
          final RelativeRect position = RelativeRect.fromRect(
            Rect.fromPoints(
              button.localToGlobal(Offset.zero, ancestor: overlay),
              button.localToGlobal(button.size.bottomRight(Offset.zero),
                  ancestor: overlay),
            ),
            Offset.zero & overlay.size,
          );

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: _CategoryMenu(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
        onDoubleTap: () {
          HapticFeedback.mediumImpact();
          CustomSnackBar.show(context, 'فیلترها بازنشانی شدند!');
          Provider.of<PeriodicTableProvider>(context, listen: false)
              .selectCategoryFilter('All');
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.blueAccent.withOpacity(0.3),
                Colors.blueGrey[800]!.withOpacity(0.8)
              ],
              radius: 1.5,
            ),
          ),
          child: const Icon(Icons.category, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildElementCell(ElementModel element) {
    final isActive = _isElementActive(element);
    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: isActive ? () => _showElementDetails(element) : null,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          CustomSnackBar.show(context, 'عنصر: ${element.name}');
        },
        onDoubleTap: () {
          if (isActive) {
            HapticFeedback.mediumImpact();
            _scrollToElement(element);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 68,
          height: 68,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorUtils.getCategoryColor(element.category).withOpacity(0.9),
                ColorUtils.getCategoryColor(element.category).withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isActive ? 0.3 : 0.1),
                blurRadius: isActive ? 6 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                element.symbol,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Vazir',
                ),
              ),
              Text(
                element.number.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontFamily: 'Vazir',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showElementDetails(ElementModel element) {
    HapticFeedback.lightImpact();
    AppRoutes.navigateToElementDetails(context, element);
  }

  void showSearchDialog(BuildContext context,
      {required Function(ElementModel) onElementSelected}) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => SearchDialog(
        onElementSelected: onElementSelected,
      ),
    );
  }

  bool _isElementActive(ElementModel element) {
    final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
    return provider.currentSort == null ||
        (provider.currentSort == 'category' &&
            element.category == provider.currentCategory) ||
        (provider.currentSort == 'name' &&
            element.name.startsWith(provider.currentLetter ?? '')) ||
        (provider.currentSort == 'number' &&
            element.number >= (provider.currentMinNumber ?? 0) &&
            element.number <= (provider.currentMaxNumber ?? 118));
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (this.orientation != orientation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_isMounted) {
              setState(() {
                if (orientation == Orientation.portrait) {
                  _isAppBarVisible = true;
                  _arrowController.forward();
                  _fadeController.forward();
                }
                this.orientation = orientation;
              });
            }
          });
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AnimatedOpacity(
              opacity: _isAppBarVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedSlide(
                offset: _isAppBarVisible ? Offset.zero : const Offset(0, -1),
                duration: const Duration(milliseconds: 300),
                child: PeriodicTableAppBar(
                  isVisible: _isAppBarVisible,
                  orientation: orientation,
                  onSearchPressed: () {
                    HapticFeedback.lightImpact();
                    showSearchDialog(
                      context,
                      onElementSelected: (element) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_isMounted) {
                            Provider.of<PeriodicTableProvider>(context,
                                    listen: false)
                                .selectElement(element);
                            _scrollToElement(element);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          body: FadeTransition(
            opacity: _fadeController,
            child: Consumer<PeriodicTableProvider>(
              builder: (context, provider, _) {
                final currentRoute = provider.currentRoute;
                switch (currentRoute) {
                  case '/':
                  case '/periodic_table':
                    return _buildPeriodicTable();
                  case '/main_menu':
                    return _buildMainMenu();
                  case '/chat_bot':
                    return WillPopScope(
                      onWillPop: () async {
                        final provider = Provider.of<PeriodicTableProvider>(
                            context,
                            listen: false);
                        provider.setCurrentRoute('/main_menu');
                        return false;
                      },
                      child: const ChatBotScreen(),
                    );
                  case '/charts':
                    return _buildCharts();
                  default:
                    return _buildPeriodicTable();
                }
              },
            ),
          ),
          bottomNavigationBar: AnimatedSlide(
            offset: _isAppBarVisible ? Offset.zero : const Offset(0, 1),
            duration: const Duration(milliseconds: 300),
            child: Consumer<PeriodicTableProvider>(
              builder: (context, provider, _) {
                if (provider.currentRoute == '/chat_bot') {
                  return const SizedBox.shrink();
                }
                return PeriodicTableBottomNav(
                  isVisible: _isAppBarVisible,
                  orientation: orientation,
                  contentBuilder: (route) => const SizedBox.shrink(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodicTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Consumer<PeriodicTableProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: provider.loadPeriodicTableData,
                          child: const Text('دوباره امتحان کنید'),
                        ),
                      ],
                    ),
                  );
                }
                return InteractiveViewer(
                  transformationController: _transformationController,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.5,
                  maxScale: 6,
                  panEnabled: true,
                  scaleEnabled: true,
                  onInteractionStart: (details) {
                    if (orientation == Orientation.landscape &&
                        _isAppBarVisible &&
                        details.pointerCount == 1) {
                      _toggleVisibility();
                    }
                  },
                  child: GestureDetector(
                    onTapUp: (details) {
                      HapticFeedback.lightImpact();
                      final RenderBox box =
                          context.findRenderObject() as RenderBox;
                      final localPosition =
                          box.globalToLocal(details.globalPosition);
                      ElementModel? selectedElement;
                      for (final element in provider.elements) {
                        final x = (element.xpos - 1) * 68.0 + 16.0;
                        final y = (element.ypos - 1) * 68.0 + 16.0;
                        if (localPosition.dx >= x &&
                            localPosition.dx <= x + 68.0 &&
                            localPosition.dy >= y &&
                            localPosition.dy <= y + 68.0) {
                          selectedElement = element;
                          break;
                        }
                      }
                      if (selectedElement != null) {
                        final element = selectedElement;
                        provider.selectElement(element);
                        _scrollToElement(element);
                      }
                    },
                    onDoubleTap: () {
                      HapticFeedback.mediumImpact();
                      _transformationController.value = Matrix4.identity();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PeriodicTableGrid(
                        elements: provider.elements,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (orientation == Orientation.landscape)
              Positioned(
                bottom: _isAppBarVisible ? 70 : 16,
                right: 16,
                child: AnimatedScale(
                  scale: _isAppBarVisible ? 1.0 : 0.8,
                  duration: const Duration(milliseconds: 300),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.blueGrey[900]!.withOpacity(0.9),
                    onPressed: _toggleVisibility,
                    child: AnimatedBuilder(
                      animation: _arrowController,
                      builder: (_, child) => Transform.rotate(
                        angle: _arrowController.value * 3.1416,
                        child:
                            const Icon(Icons.arrow_upward, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMainMenu() {
    return WillPopScope(
      onWillPop: () async {
        final provider =
            Provider.of<PeriodicTableProvider>(context, listen: false);
        provider.setCurrentRoute('/main_menu');
        return false;
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.blue[900]!.withOpacity(0.3),
              Colors.purple[900]!.withOpacity(0.2),
              Colors.blueGrey[900]!.withOpacity(0.1),
            ],
            radius: 1.2,
            center: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _fadeController,
                    child: _buildMenuGrid(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      {
        'title': 'چت بات شیمی',
        'icon': Icons.chat_bubble_outline,
        'colors': [
          Colors.deepPurple[400]!.withOpacity(0.8),
          Colors.blue[600]!.withOpacity(0.6)
        ],
        'route': '/chat_bot',
      },
      {
        'title': 'جدول تناوبی',
        'icon': Icons.grid_on,
        'colors': [
          Colors.blue[600]!.withOpacity(0.8),
          Colors.teal[400]!.withOpacity(0.6)
        ],
        'route': '/periodic_table',
      },
      {
        'title': 'کتاب شیمی',
        'icon': Icons.book,
        'colors': [
          Colors.teal[400]!.withOpacity(0.8),
          Colors.green[400]!.withOpacity(0.6)
        ],
        'route': '/chemistry_book',
      },
      {
        'title': 'جستجوی عناصر',
        'icon': Icons.search,
        'colors': [
          Colors.green[400]!.withOpacity(0.8),
          Colors.lime[400]!.withOpacity(0.6)
        ],
        'route': '/element_search',
      },
      {
        'title': 'ماشین حساب',
        'icon': Icons.calculate,
        'colors': [
          Colors.orange[400]!.withOpacity(0.8),
          Colors.amber[400]!.withOpacity(0.6)
        ],
        'route': '/calculator',
      },
      {
        'title': 'فرمول‌های شیمی',
        'icon': Icons.science,
        'colors': [
          Colors.cyan[400]!.withOpacity(0.8),
          Colors.blue[400]!.withOpacity(0.6)
        ],
        'route': '/formulas',
      },
      {
        'title': 'تنظیمات',
        'icon': Icons.settings,
        'colors': [
          Colors.grey[600]!.withOpacity(0.8),
          Colors.blueGrey[400]!.withOpacity(0.6)
        ],
        'route': '/settings',
      },
      {
        'title': 'پروفایل',
        'icon': Icons.person,
        'colors': [
          Colors.pink[400]!.withOpacity(0.8),
          Colors.purple[400]!.withOpacity(0.6)
        ],
        'route': '/profile',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _fadeController,
                curve: Interval(delay, delay + 0.5, curve: Curves.easeOutCubic),
              ),
            );
            return Transform.translate(
              offset: Offset(0, 50 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value,
                child: _buildMenuCard(
                  title: item['title'] as String,
                  icon: item['icon'] as IconData,
                  colors: item['colors'] as List<Color>,
                  route: item['route'] as String,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required List<Color> colors,
    required String route,
  }) {
    bool isTapped = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) {
            setState(() {
              isTapped = true;
            });
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) {
            setState(() {
              isTapped = false;
            });
            try {
              final provider =
                  Provider.of<PeriodicTableProvider>(context, listen: false);
              switch (route) {
                case '/chat_bot':
                  AppRoutes.navigateToChatBot(context).then((_) {
                    if (mounted) setState(() {});
                  });
                  break;
                case '/periodic_table':
                  provider.setCurrentRoute('/periodic_table');
                  if (mounted) setState(() {});
                  break;
                case '/chemistry_book':
                  AppRoutes.navigateToChemistryBook(context).then((_) {
                    if (mounted) setState(() {});
                  });
                  break;
                case '/element_search':
                  if (provider.selectedElement != null) {
                    AppRoutes.navigateToElementSearch(context,
                        firstElement: provider.selectedElement!);
                  } else {
                    AppRoutes.navigateToElementSearch(context);
                  }
                  Future.microtask(() {
                    if (mounted) setState(() {});
                  });
                  break;
                case '/calculator':
                  AppRoutes.navigateToChemistryCalculator(context);
                  if (mounted) setState(() {});
                  break;
                case '/formulas':
                  AppRoutes.navigateToChemistryFormulas(context);
                  if (mounted) setState(() {});
                  break;
                case '/settings':
                  AppRoutes.navigateToProfileSetup(context).then((_) {
                    if (mounted) setState(() {});
                  });
                  break;
                case '/profile':
                  AppRoutes.navigateToProfile(context).then((_) {
                    if (mounted) setState(() {});
                  });
                  break;
              }
            } catch (e) {
              debugPrint('Navigation error: $e');
              CustomSnackBar.show(context, 'خطا در انتقال به صفحه مورد نظر');
            }
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            CustomSnackBar.show(context, 'گزینه: $title');
          },
          onDoubleTap: () {
            HapticFeedback.mediumImpact();
            CustomSnackBar.show(context, '$title به زودی بهبود می‌یابد!');
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(isTapped ? 1.05 : 1.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withOpacity(isTapped ? 0.4 : 0.2),
                  blurRadius: isTapped ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(isTapped ? 14 : 12),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1)
                        ],
                        radius: 1.0,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Vazir',
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCharts() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.blueGrey[900]!.withOpacity(0.3),
              Colors.blue[900]!.withOpacity(0.2),
            ],
            radius: 1.2,
            center: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _fadeController,
                    child: const Text(
                      'نمودارها و جداول',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Vazir',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildChartCard(
                    title: 'نمودار روند تغییرات خواص فیزیکی',
                    description:
                        'مشاهده روند تغییرات نقطه ذوب، جوش و چگالی در جدول تناوبی',
                    icon: Icons.show_chart,
                    colors: [
                      Colors.blue[600]!.withOpacity(0.8),
                      Colors.blue[400]!.withOpacity(0.6)
                    ],
                    onTap: () {
                      CustomSnackBar.show(
                          context, 'این نمودار به زودی اضافه می‌شود!');
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildChartCard(
                    title: 'نمودار روند تغییرات خواص شیمیایی',
                    description:
                        'مشاهده روند تغییرات الکترونگاتیوی، انرژی یونش و شعاع اتمی',
                    icon: Icons.science,
                    colors: [
                      Colors.green[600]!.withOpacity(0.8),
                      Colors.green[400]!.withOpacity(0.6)
                    ],
                    onTap: () {
                      CustomSnackBar.show(
                          context, 'این نمودار به زودی اضافه می‌شود!');
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildChartCard(
                    title: 'نمودار فراوانی عناصر',
                    description: 'مشاهده فراوانی عناصر در پوسته زمین و جهان',
                    icon: Icons.pie_chart,
                    colors: [
                      Colors.orange[600]!.withOpacity(0.8),
                      Colors.orange[400]!.withOpacity(0.6)
                    ],
                    onTap: () {
                      CustomSnackBar.show(
                          context, 'این نمودار به زودی اضافه می‌شود!');
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildChartCard(
                    title: 'نمودار کشف عناصر',
                    description: 'تاریخچه کشف عناصر در طول زمان',
                    icon: Icons.history,
                    colors: [
                      Colors.purple[600]!.withOpacity(0.8),
                      Colors.purple[400]!.withOpacity(0.6)
                    ],
                    onTap: () {
                      CustomSnackBar.show(
                          context, 'این نمودار به زودی اضافه می‌شود!');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String description,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    bool isTapped = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) {
            setState(() {
              isTapped = true;
            });
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) {
            setState(() {
              isTapped = false;
            });
            onTap();
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            CustomSnackBar.show(context, 'نمودار: $title');
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(isTapped ? 1.05 : 1.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withOpacity(isTapped ? 0.4 : 0.2),
                  blurRadius: isTapped ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(isTapped ? 14 : 12),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1)
                        ],
                        radius: 1.0,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Vazir',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isTapped ? 0.1 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryMenu extends StatelessWidget {
  const _CategoryMenu();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'key': 'All', 'display': 'همه'},
      {'key': 'diatomic nonmetal', 'display': 'نافلز دواتمی'},
      {'key': 'noble gas', 'display': 'گاز نجیب'},
      {'key': 'alkali metal', 'display': 'فلز قلیایی'},
      {'key': 'alkaline earth metal', 'display': 'فلز قلیایی خاکی'},
      {'key': 'metalloid', 'display': 'شبه‌فلز'},
      {'key': 'polyatomic nonmetal', 'display': 'نافلز چنداتمی'},
      {'key': 'post-transition metal', 'display': 'فلز پس‌واسطه'},
      {'key': 'transition metal', 'display': 'فلز واسطه'},
      {'key': 'lanthanide', 'display': 'لانتانید'},
      {'key': 'actinide', 'display': 'اکتینید'},
    ];

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueGrey[900]!.withOpacity(0.8),
            Colors.blue[900]!.withOpacity(0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.category,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'دسته‌بندی عناصر',
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
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          ...categories
              .map((category) => _buildCategoryItem(context, category)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, Map<String, String> category) {
    final provider = Provider.of<PeriodicTableProvider>(context);
    final isSelected = category['key'] == provider.selectedCategoryFilter;
    bool isTapped = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) {
            setState(() {
              isTapped = true;
            });
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) {
            setState(() {
              isTapped = false;
            });
            provider.selectCategoryFilter(category['key']!);
            Navigator.pop(context);
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            CustomSnackBar.show(context, 'دسته: ${category['display']}');
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              gradient: isTapped
                  ? LinearGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.3),
                        Colors.blueGrey[800]!.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blueAccent : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              title: Text(
                category['display']!,
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.white,
                  fontFamily: 'Vazir',
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.blueAccent,
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}
