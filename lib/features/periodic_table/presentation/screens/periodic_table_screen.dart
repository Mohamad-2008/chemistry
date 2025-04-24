import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/periodic_table_app_bar.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/periodic_table_bottom_nav.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/periodic_table_grid.dart.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/search_dialog.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';

class PeriodicTableScreen extends StatefulWidget {
  const PeriodicTableScreen({super.key});

  @override
  _PeriodicTableScreenState createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends State<PeriodicTableScreen>
    with TickerProviderStateMixin {
  bool _isAppBarVisible = true;
  late AnimationController _arrowController;
  Orientation _lastOrientation = Orientation.portrait;
  final TransformationController _transformationController = TransformationController();
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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

    // محاسبه موقعیت عنصر در جدول
    const cellSize = 68.0;
    const padding = 16.0;
    const zoomScale = 2.0;
    final x = (element.xpos - 1) * cellSize + padding;
    final y = (element.ypos - 1) * cellSize + padding;

    // محاسبه مرکز صفحه با تنظیم موقعیت افقی
    final screenSize = MediaQuery.of(context).size;
    final matrix = Matrix4.identity()
      ..translate(
        -x * zoomScale + screenSize.width / 2 - (cellSize * zoomScale / 2) - 50,
        -y * zoomScale + screenSize.height / 2 - (cellSize * zoomScale / 2),
      )
      ..scale(zoomScale);

    // انیمیشن جابجایی
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

    // انیمیشن بزرگ و کوچک شدن
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

    // شروع انیمیشن جابجایی
    moveController.forward().then((_) {
      moveController.dispose();

      // تأخیر 400 میلی‌ثانیه‌ای قبل از شروع انیمیشن بزرگ و کوچک شدن
      Future.delayed(const Duration(seconds: 5), () {
        if (_isMounted) {
          scaleController.forward().then((_) {
            scaleController.dispose();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_lastOrientation != orientation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_isMounted) {
              setState(() {
                if (orientation == Orientation.portrait) {
                  _isAppBarVisible = true;
                  _arrowController.forward();
                }
                _lastOrientation = orientation;
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
          body: LayoutBuilder(
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
                            child: PeriodicTableGrid(elements: provider.elements),
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
          ),
          bottomNavigationBar: PeriodicTableBottomNav(
            isVisible: _isAppBarVisible,
            orientation: orientation,
          ),
        );
      },
    );
  }
}