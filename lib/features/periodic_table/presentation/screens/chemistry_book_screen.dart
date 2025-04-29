import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';

class ChemistryBookScreen extends StatefulWidget {
  const ChemistryBookScreen({super.key});

  @override
  State<ChemistryBookScreen> createState() => _ChemistryBookScreenState();
}

class _ChemistryBookScreenState extends State<ChemistryBookScreen> {
  List<dynamic> _timelineData = [];
  Map<String, dynamic> _metadata = {};
  int _currentStep = 0;
  bool _isLoading = true;
  bool _showPodmanSelection = true;
  late ScrollController _timelineController;

  final List<Map<String, dynamic>> _podmans = [
    {
      'id': 1,
      'title': 'پودمان یک',
      'subtitle': 'ساختار اتم',
      'isAvailable': true,
    },
    {
      'id': 2,
      'title': 'پودمان دو',
      'subtitle': 'فرایندهای شیمیایی',
      'isAvailable': true,
    },
    {
      'id': 3,
      'title': 'پودمان سه',
      'subtitle': 'پیوند یونی',
      'isAvailable': false,
    },
    {
      'id': 4,
      'title': 'پودمان چهار',
      'subtitle': 'پیوند کووالانسی',
      'isAvailable': false,
    },
    {
      'id': 5,
      'title': 'پودمان پنج',
      'subtitle': 'مولکول‌های قطبی و ناقطبی',
      'isAvailable': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _timelineController = ScrollController();
  }

  @override
  void dispose() {
    _timelineController.dispose();
    super.dispose();
  }

  Future<void> _loadTimelineData(int podmanId) async {
    try {
      final String response = await rootBundle.loadString('assets/data/podman$podmanId.json');
      final data = json.decode(response);
      setState(() {
        _timelineData = data['timeline'];
        _metadata = data['metadata'];
        _isLoading = false;
        _showPodmanSelection = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading timeline data: $e');
    }
  }

  void _handleBack(BuildContext context) {
    if (_showPodmanSelection) {
      Navigator.pop(context);
    } else {
      setState(() {
        _showPodmanSelection = true;
        _currentStep = 0;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < _timelineData.length - 1) {
      setState(() {
        _currentStep++;
      });
      _scrollToCurrentStep();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _scrollToCurrentStep();
    }
  }

  void _scrollToCurrentStep() {
    const double itemWidth = 60.0; // عرض تقریبی هر آیتم در تایم‌لاین
    final double targetPosition = _currentStep * itemWidth;
    
    _timelineController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'مقدمه':
        return Colors.blue;
      case 'مبحث اصلی':
        return Colors.amber;
      case 'نکته':
        return Colors.green;
      case 'کار در کلاس':
        return Colors.purple;
      case 'تحقیق کنید':
        return Colors.orange;
      case 'آزمایش':
        return Colors.red;
      case 'پیوند یونی':
      case 'پیوند کووالانسی':
        return Colors.indigo;
      case 'بیشتر بدانید':
        return Colors.teal;
      case 'ارزشیابی':
        return Colors.deepOrange;
      default:
        return Colors.amber;
    }
  }

  Widget _buildPodmanSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.amber,
                size: 28,
              ),
              onPressed: () => _handleBack(context),
            ),
            const Spacer(),
            const Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'انتخاب پودمان',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._podmans.map((podman) => GestureDetector(
          onTap: podman['isAvailable'] ? () => _loadTimelineData(podman['id']) : null,
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[900]!.withOpacity(0.95),
                    Colors.grey[800]!.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    podman['isAvailable'] ? Icons.lock_open : Icons.lock,
                    color: podman['isAvailable'] ? Colors.amber : Colors.grey,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        podman['title'],
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        podman['subtitle'],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBack(context);
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // پس‌زمینه با دونه‌های رنگی متحرک
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.shade100,
                    Colors.amber.shade50,
                  ],
                ),
              ),
              child: CustomPaint(
                painter: DotsPainter(),
              ),
            ),
            // محتوای اصلی
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _showPodmanSelection
                      ? _buildPodmanSelection()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.chevron_left,
                                        color: Colors.amber,
                                        size: 28,
                                      ),
                                      onPressed: () => _handleBack(context),
                                    ),
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                        _metadata['title'] ?? 'پودمان اول',
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'صفحات: ${_metadata['pages'] ?? ''}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            if (_isLoading)
                              const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.amber,
                                ),
                              )
                            else if (_timelineData.isNotEmpty) ...[
                              // تایم‌لاین
                              SizedBox(
                                width: double.infinity,
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  controller: _timelineController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                  itemCount: _timelineData.length,
                                  itemBuilder: (context, index) {
                                    final item = _timelineData[index];
                                    final isActive = index <= _currentStep;
                                    final typeColor = _getTypeColor(item['type']);
                                    
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: index == 0 ? 0 : 0,
                                        right: index == _timelineData.length - 1 ? 0 : 0,
                                        
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (index > 0) ...[
                                            Container(
                                              width: 30,
                                              height: 2,
                                              color: isActive ? typeColor : Colors.grey,
                                              margin: const EdgeInsets.only(bottom: 20),
                                            ),
                                          ],
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _currentStep = index;
                                              });
                                              _scrollToCurrentStep();
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: isActive ? typeColor : Colors.grey,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: typeColor.withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'ص ${item['page']}',
                                                  style: TextStyle(
                                                    color: isActive ? typeColor : Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              // دکمه‌های ناوبری
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios, color: Colors.amber),
                                    onPressed: _previousStep,
                                  ),
                                  Text(
                                    'مرحله ${_currentStep + 1} از ${_timelineData.length}',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.amber),
                                    onPressed: _nextStep,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // محتوای مرحله فعلی
                              _buildTimelineItem(_timelineData[_currentStep]),
                            ],
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

  Widget _buildTimelineItem(Map<String, dynamic> item) {
    final typeColor = _getTypeColor(item['type']);
    
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey[900]!.withOpacity(0.95),
              Colors.grey[800]!.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['type'] ?? '',
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item['title'] ?? '',
                style: TextStyle(
                  color: typeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item['content'] ?? '',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
                textAlign: TextAlign.right,
              ),
              if (item['components'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'اجزاء',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...(item['components'] as Map<String, dynamic>).entries.map((entry) => Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                    ),
                  ),
                )).toList(),
              ],
              if (item['activity'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'فعالیت',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['activity']['مسئله'] ?? '',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                      if (item['activity']['پاسخ'] != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'پاسخ: ${item['activity']['پاسخ']}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (item['questions'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'سوالات',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...(item['questions'] as List).map<Widget>((question) => Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    question['text'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                    ),
                  ),
                )).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 5 + 2;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 