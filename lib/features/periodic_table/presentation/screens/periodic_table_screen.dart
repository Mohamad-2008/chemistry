import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/periodic_table_app_bar.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/periodic_table_bottom_nav.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/periodic_table_grid.dart.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/search_dialog.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/custom_snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';
import 'package:periodic_table_app/utils/color_utils.dart';
import 'package:periodic_table_app/features/chat_bot/presentation/screens/chat_bot_screen.dart';
import 'package:periodic_table_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PeriodicTableScreen extends StatefulWidget {
  const PeriodicTableScreen({super.key});

  @override
  _PeriodicTableScreenState createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends State<PeriodicTableScreen>
    with TickerProviderStateMixin {
  bool _isAppBarVisible = true;
  late AnimationController _arrowController;
  Orientation? orientation;
  final TransformationController _transformationController = TransformationController();
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
    if (_isAppBarVisible) {
      _arrowController.forward();
    } else {
      _arrowController.reverse();
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _arrowController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    if (_isMounted) {
      setState(() {
        _isAppBarVisible = !_isAppBarVisible;
        if (_isAppBarVisible) {
          _arrowController.forward();
        } else {
          _arrowController.reverse();
        }
      });
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
    provider.sortElements(sortBy);
  }

  Widget _buildSortButton() {
    return IconButton(
      icon: const Icon(Icons.sort, color: Colors.white),
      onPressed: () {
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
            content: const _SortMenu(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildElementCell(ElementModel element) {
    final isActive = _isElementActive(element);
    return Opacity(
      opacity: isActive ? 1.0 : 0.3,
      child: GestureDetector(
        onTap: isActive ? () => _showElementDetails(element) : null,
        child: Container(
          width: 68,
          height: 68,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: ColorUtils.getCategoryColor(element.category),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
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
                ),
              ),
              Text(
                element.number.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showElementDetails(ElementModel element) {
    Navigator.pushNamed(
      context,
      '/element_details',
      arguments: element,
    );
  }

  bool _isElementActive(ElementModel element) {
    final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
    return provider.currentSort == null ||
        (provider.currentSort == 'category' && element.category == provider.currentCategory) ||
        (provider.currentSort == 'name' && element.name.startsWith(provider.currentLetter ?? '')) ||
        (provider.currentSort == 'number' && element.number >= (provider.currentMinNumber ?? 0) && element.number <= (provider.currentMaxNumber ?? 118));
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
                }
                this.orientation = orientation;
              });
            }
          });
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: PeriodicTableAppBar(
            isVisible: _isAppBarVisible,
            orientation: orientation,
            onSearchPressed: () {
              showSearchDialog(
                context,
                onElementSelected: (element) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_isMounted) {
                      Provider.of<PeriodicTableProvider>(context, listen: false).selectElement(element);
                      _scrollToElement(element);
                    }
                  });
                },
              );
            },
          ),
          body: Consumer<PeriodicTableProvider>(
            builder: (context, provider, _) {
              final currentRoute = provider.currentRoute;
              switch (currentRoute) {
                case '/':
                  return _buildPeriodicTable();
                case '/main_menu':
                  return _buildMainMenu();
                case '/chat_bot':
                  return WillPopScope(
                    onWillPop: () async {
                      final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
                      provider.setCurrentRoute('/');
                      return true;
                    },
                    child: const ChatBotScreen(),
                  );
                case '/profile':
                  return const ProfileScreen();
                default:
                  return _buildPeriodicTable();
              }
            },
          ),
          bottomNavigationBar: Consumer<PeriodicTableProvider>(
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
                          child: Text(AppLocalizations.of(context)!.tryAgainButton),
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
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final localPosition = box.globalToLocal(details.globalPosition);
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
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.blueGrey[900]!.withOpacity(0.9),
                  onPressed: _toggleVisibility,
                  child: AnimatedBuilder(
                    animation: _arrowController,
                    builder: (_, child) => Transform.rotate(
                      angle: _arrowController.value * 3.1416,
                      child: const Icon(Icons.arrow_upward, color: Colors.white),
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
        final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
        provider.setCurrentRoute('/main_menu');
        return false;
      },
      child: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildMenuGrid(),
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
    final l10n = AppLocalizations.of(context)!;
    final menuItems = [
      {
        'title': l10n.chatBotTitle,
        'icon': Icons.chat_bubble_outline,
        'color': Colors.purple,
        'route': '/chat_bot',
        'isWide': false,
      },
      {
        'title': l10n.periodicTableTitle,
        'icon': Icons.grid_on,
        'color': Colors.blue,
        'route': '/periodic_table',
        'isWide': true,
      },
      {
        'title': l10n.chemistryBookTitle,
        'icon': Icons.book,
        'color': Colors.amber,
        'route': '/chemistry_book',
        'isWide': true,
      },
      {
        'title': l10n.elementSearchTitle,
        'icon': Icons.search,
        'color': Colors.green,
        'route': '/element_search',
        'isWide': false,
      },
      {
        'title': l10n.calculatorTitle,
        'icon': Icons.calculate,
        'color': Colors.orange,
        'route': '/calculator',
        'isWide': false,
      },
      {
        'title': l10n.formulasTitle,
        'icon': Icons.science,
        'color': Colors.teal,
        'route': '/formulas',
        'isWide': false,
      },
      {
        'title': l10n.settingsTitle,
        'icon': Icons.settings,
        'color': Colors.indigo,
        'route': '/settings',
        'isWide': false,
      },
      {
        'title': l10n.profileTitle,
        'icon': Icons.person,
        'color': Colors.pink,
        'route': '/profile',
        'isWide': false,
      },
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildWideCard(menuItems[1]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildWideCard(menuItems[2]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMenuCard(
                title: menuItems[0]['title'] as String,
                icon: menuItems[0]['icon'] as IconData,
                color: menuItems[0]['color'] as Color,
                onTap: () {
                  Navigator.pushNamed(context, menuItems[0]['route'] as String).then((_) {
                    final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
                    provider.setCurrentRoute('/main_menu');
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMenuCard(
                title: menuItems[3]['title'] as String,
                icon: menuItems[3]['icon'] as IconData,
                color: menuItems[3]['color'] as Color,
                onTap: () {
                  Navigator.pushNamed(context, menuItems[3]['route'] as String).then((_) {
                    final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
                    provider.setCurrentRoute('/main_menu');
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMenuCard(
                title: menuItems[4]['title'] as String,
                icon: menuItems[4]['icon'] as IconData,
                color: menuItems[4]['color'] as Color,
                onTap: () {
                  Navigator.pushNamed(context, menuItems[4]['route'] as String).then((_) {
                    final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
                    provider.setCurrentRoute('/main_menu');
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMenuCard(
                title: menuItems[5]['title'] as String,
                icon: menuItems[5]['icon'] as IconData,
                color: menuItems[5]['color'] as Color,
                onTap: () {
                  Navigator.pushNamed(context, menuItems[5]['route'] as String).then((_) {
                    final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
                    provider.setCurrentRoute('/main_menu');
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMenuCard(
                title: menuItems[6]['title'] as String,
                icon: menuItems[6]['icon'] as IconData,
                color: menuItems[6]['color'] as Color,
                onTap: () {
                  Navigator.pushNamed(context, menuItems[6]['route'] as String).then((_) {
                    final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
                    provider.setCurrentRoute('/main_menu');
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMenuCard(
                title: menuItems[7]['title'] as String,
                icon: menuItems[7]['icon'] as IconData,
                color: menuItems[7]['color'] as Color,
                onTap: () {
                  Navigator.pushNamed(context, menuItems[7]['route'] as String).then((_) {
                    final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
                    provider.setCurrentRoute('/main_menu');
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWideCard(Map<String, dynamic> item) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          try {
            Navigator.pushNamed(context, item['route'] as String).then((_) {
              final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
              provider.setCurrentRoute('/main_menu');
            });
          } catch (e) {
            debugPrint('Navigation error: $e');
            CustomSnackBar.show(
              context,
              AppLocalizations.of(context)!.navigationErrorSnackbar,
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (item['color'] as Color).withOpacity(0.9),
                (item['color'] as Color).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (item['color'] as Color).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    item['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          try {
            onTap();
          } catch (e) {
            debugPrint('Navigation error: $e');
            CustomSnackBar.show(
              context,
              AppLocalizations.of(context)!.navigationErrorSnackbar,
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New SortMenu widget for the floating dialog
class _SortMenu extends StatelessWidget {
  const _SortMenu();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sort,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.sortElementsTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
          _buildSortItem(context, 'name', l10n.sortByName, Icons.sort_by_alpha),
          _buildSortItem(context, 'number', l10n.sortByAtomicNumber, Icons.numbers),
          _buildSortItem(context, 'category', l10n.sortByCategory, Icons.category),
        ],
      ),
    );
  }

  Widget _buildSortItem(BuildContext context, String sortBy, String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white70,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        onTap: () {
          final provider = Provider.of<PeriodicTableProvider>(context, listen: false);
          provider.sortElements(sortBy);
          Navigator.pop(context);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}