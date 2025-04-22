import 'dart:async';
import 'package:flutter/material.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/custom_snack_bar.dart';
import 'package:periodic_table_app/features/periodic_table/presentation/widgets/periodic_table_grid.dart.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';

class PeriodicTableScreen extends StatefulWidget {
  const PeriodicTableScreen({super.key});

  @override
  _PeriodicTableScreenState createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends State<PeriodicTableScreen>
    with SingleTickerProviderStateMixin {
  bool _isAppBarVisible = true;
  late AnimationController _arrowController;
  Orientation _lastOrientation = Orientation.portrait;

  @override
  void initState() {
    super.initState();
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
    _arrowController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _isAppBarVisible = !_isAppBarVisible;
      if (_isAppBarVisible) {
        _arrowController.forward();
      } else {
        _arrowController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_lastOrientation != orientation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              if (orientation == Orientation.portrait) {
                _isAppBarVisible = true;
                _arrowController.forward();
              }
              _lastOrientation = orientation;
            });
          });
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: orientation == Orientation.portrait || _isAppBarVisible
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut, // انیمیشن نرم‌تر
                    transform: Matrix4.translationValues(
                      0,
                      _isAppBarVisible ? 0 : -56,
                      0,
                    ),
                    child: AnimatedOpacity(
                      opacity: _isAppBarVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 500), // هماهنگ با AnimatedContainer
                      curve: Curves.easeInOut, // انیمیشن نرم‌تر
                      child: AppBar(
                        backgroundColor: Colors.blueGrey[900]!.withOpacity(0.7),
                        elevation: 0,
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blueGrey[900]!.withOpacity(0.7),
                                Colors.black.withOpacity(0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () {
                            CustomSnackBar.show(context, 'بازگشت به زودی اضافه می‌شود!');
                          },
                        ),
                        title: const Text(
                          'جدول تناوبی',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Vazir',
                          ),
                        ),
                        centerTitle: true,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              CustomSnackBar.show(context, 'جستجو به زودی اضافه می‌شود!');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              CustomSnackBar.show(context, 'منو به زودی اضافه می‌شود!');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
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
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: PeriodicTableGrid(elements: provider.elements),
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
          bottomNavigationBar: orientation == Orientation.portrait || _isAppBarVisible
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut, // انیمیشن نرم‌تر
                  transform: Matrix4.translationValues(
                    0,
                    _isAppBarVisible ? 0 : 100,
                    0,
                  ),
                  child: AnimatedOpacity(
                    opacity: _isAppBarVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 500), // هماهنگ با AnimatedContainer
                    curve: Curves.easeInOut, // انیمیشن نرم‌تر
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
                              _buildNavItem(icon: Icons.search, isActive: false, onTap: () {
                                CustomSnackBar.show(context, 'جستجو به زودی اضافه می‌شود!');
                              }),
                              _buildNavItem(icon: Icons.format_list_bulleted, isActive: false, onTap: () {
                                CustomSnackBar.show(context, 'لیست اتم‌ها به زودی اضافه می‌شود!');
                              }),
                              _buildNavItem(icon: Icons.bar_chart, isActive: false, onTap: () {
                                CustomSnackBar.show(context, 'جدول‌ها و نمودارها به زودی اضافه می‌شود!');
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
                )
              : null,
        );
      },
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