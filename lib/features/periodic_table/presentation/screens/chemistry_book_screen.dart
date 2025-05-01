import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:periodic_table_app/features/chat_bot/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

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
  Map<int, double> _podmanProgress = {};
  late TtsService _ttsService;
  final TextEditingController _textController = TextEditingController();

  final List<Map<String, dynamic>> _podmans = [
    {
      'id': 1,
      'title': 'پودمان یک',
      'subtitle': 'ساختار اتم و مفاهیم پایه شیمی',
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
      'subtitle': 'محلول و کلوئید',
      'isAvailable': true,
    },
    {
      'id': 4,
      'title': 'پودمان چهار',
      'subtitle': 'الکتروشیمی',
      'isAvailable': true,
    },
    {
      'id': 5,
      'title': 'پودمان پنج',
      'subtitle': 'ترکیب‌های کربن‌دار',
      'isAvailable': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _timelineController = ScrollController();
    _ttsService = TtsService();
    _ttsService.addListener(() {
      setState(() {});
    });
    _loadProgress();
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _ttsService.removeListener(() {
      setState(() {});
    });
    _ttsService.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Start teaching with user input and current topic
  void _startTeaching() {
    if (_ttsService.isPlaying || _ttsService.isProcessing) return;

    String teachingText = '';
    if (_timelineData.isNotEmpty) {
      final currentTopic = _timelineData[_currentStep];
      final topicTitle = currentTopic['title'] ?? '';
      final topicContent = currentTopic['content'] ?? '';
      teachingText = '$topicTitle: $topicContent';
    }

    final userInput = _textController.text.trim();
    if (userInput.isNotEmpty) {
      teachingText = teachingText.isNotEmpty
          ? 'مبحث: $teachingText\nورودی کاربر: $userInput'
          : userInput;
    }

    _ttsService.textToSpeech(teachingText.isNotEmpty ? teachingText : 'محتوایی برای آموزش یافت نشد.');
    setState(() {});
  }

  // Stop the current playback
  void _stopTeaching() {
    _ttsService.stop();
    setState(() {});
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var podman in _podmans) {
        final progress = prefs.getDouble('podman_${podman['id']}_progress') ?? 0.0;
        _podmanProgress[podman['id']] = progress;
      }
    });
  }

  Future<void> _saveProgress(int podmanId) async {
    final prefs = await SharedPreferences.getInstance();
    final progress = _timelineData.isNotEmpty
        ? (_currentStep + 1) / _timelineData.length
        : 0.0;
    await prefs.setDouble('podman_${podmanId}_progress', progress);
    setState(() {
      _podmanProgress[podmanId] = progress;
    });
  }

  Future<void> _loadTimelineData(int podmanId) async {
    try {
      final String response = await rootBundle.loadString('assets/data/podman$podmanId.json');
      final data = json.decode(response);
      List<dynamic> timeline = data['timeline'] ?? [];
      final pedagogicalFeatures = data['pedagogical_features'] ?? {};

      if (pedagogicalFeatures['نکات کناری'] != null && (pedagogicalFeatures['نکات کناری'] as List).isNotEmpty) {
        timeline.add({
          'id': timeline.length + 1,
          'type': 'نکات کناری',
          'title': 'نکات کناری',
          'content': (pedagogicalFeatures['نکات کناری'] as List).join('\n'),
        });
      }
      if (pedagogicalFeatures['خود را بیازمایید'] != null && (pedagogicalFeatures['خود را بیازمایید'] as List).isNotEmpty) {
        timeline.add({
          'id': timeline.length + 1,
          'type': 'خود را بیازمایید',
          'title': 'خود را بیازمایید',
          'content': (pedagogicalFeatures['خود را بیازمایید'] as List).join('\n'),
        });
      }
      if (pedagogicalFeatures['مثال‌های حل شده'] != null && (pedagogicalFeatures['مثال‌های حل شده'] as List).isNotEmpty) {
        timeline.add({
          'id': timeline.length + 1,
          'type': 'مثال‌های حل شده',
          'title': 'مثال‌های حل شده',
          'content': (pedagogicalFeatures['مثال‌های حل شده'] as List).join('\n'),
        });
      }

      setState(() {
        _timelineData = timeline;
        _metadata = {...data['metadata'] ?? {}, 'podman_id': podmanId};
        _isLoading = false;
        _showPodmanSelection = false;
      });

      final prefs = await SharedPreferences.getInstance();
      final savedStep = prefs.getInt('podman_${podmanId}_step') ?? 0;
      if (savedStep < timeline.length) {
        setState(() {
          _currentStep = savedStep;
        });
        _scrollToCurrentStep();
      }

      await _saveProgress(podmanId);
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

  void _nextStep(int podmanId) {
    if (_currentStep < _timelineData.length - 1) {
      setState(() {
        _currentStep++;
      });
      _scrollToCurrentStep();
      _saveProgress(podmanId);
      _saveCurrentStep(podmanId);
    }
  }

  void _previousStep(int podmanId) {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _scrollToCurrentStep();
      _saveProgress(podmanId);
      _saveCurrentStep(podmanId);
    }
  }

  Future<void> _saveCurrentStep(int podmanId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('podman_${podmanId}_step', _currentStep);
  }

  void _scrollToCurrentStep() {
    final double itemWidth = 75;
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
        return Colors.blue.shade300;
      case 'مبحث اصلی':
        return Colors.amber;
      case 'نکته':
      case 'نکات کناری':
        return Colors.green;
      case 'کار در کلاس':
        return Colors.deepOrangeAccent;
      case 'تحقیق کنید':
        return Colors.orange;
      case 'آزمایش':
        return Colors.red;
      case 'پیوند یونی':
      case 'پیوند کووالانسی':
        return Colors.blueAccent.shade200;
      case 'بیشتر بدانید':
        return Colors.teal;
      case 'ارزشیابی':
        return Colors.deepOrange;
      case 'تمرین':
        return Colors.purpleAccent;
      case 'کاربرد':
        return Colors.cyan;
      case 'مثال کاربردی':
        return Colors.indigo;
      case 'مفهومی پیشرفته':
      case 'مبحث پیشرفته':
        return Colors.blueGrey;
      case 'مفهوم سبز':
        return Colors.greenAccent;
      case 'خود را بیازمایید':
        return Colors.orange;
      case 'مثال‌های حل شده':
        return Colors.teal;
      default:
        return Colors.amber;
    }
  }

  Widget _buildPodmanSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._podmans.map((podman) => GestureDetector(
          onTap: () => _loadTimelineData(podman['id']),
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
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _podmanProgress[podman['id']] ?? 0.0,
                          backgroundColor: Colors.grey[400],
                          color: Colors.amber,
                          strokeWidth: 4,
                        ),
                        Text(
                          '${((_podmanProgress[podman['id']] ?? 0.0) * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      ],
                    ),
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
                          fontFamily: 'Vazir',
                        ),
                      ),
                      Text(
                        podman['subtitle'],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontFamily: 'Vazir',
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
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () => _handleBack(context),
                          ),
                          Column(
                            textDirection: TextDirection.rtl,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  _metadata['title'] ?? 'پودمان اول',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Vazir',
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              if (_metadata['author'] != null)
                                Text(
                                  'نویسنده: ${_metadata['author']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontFamily: 'Vazir',
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                ),
                              Text(
                                'صفحات: ${_metadata['pages'] ?? ''}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontFamily: 'Vazir',
                                ),
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.amber,
                          ),
                        )
                      else if (_timelineData.isNotEmpty) ...[
                        Container(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            controller: _timelineController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: _timelineData.length,
                            itemBuilder: (context, index) {
                              final item = _timelineData[index];
                              final isActive = index <= _currentStep;
                              final typeColor = _getTypeColor(item['type']);

                              return Padding(
                                padding: EdgeInsets.only(
                                  left: index == 0 ? 10 : 0,
                                  right: index == _timelineData.length - 1 ? 10 : 0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (index > 0) ...[
                                      Container(
                                        width: 30,
                                        height: 2,
                                        color: isActive ? typeColor : Colors.grey,
                                        margin: const EdgeInsets.only(bottom: 20, right: 5, left: 5),
                                      ),
                                    ],
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _currentStep = index;
                                        });
                                        _scrollToCurrentStep();
                                        _saveProgress(_metadata['podman_id'] ?? 1);
                                        _saveCurrentStep(_metadata['podman_id'] ?? 1);
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
                                                  color: isActive ? typeColor.withOpacity(0.9) : Colors.grey,
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 0),
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
                                            item['page'] != null ? 'ص ${item['page']}' : '',
                                            style: TextStyle(
                                              color: isActive ? typeColor : Colors.grey,
                                              fontSize: 12,
                                              fontFamily: 'Vazir',
                                            ),
                                            textDirection: TextDirection.rtl,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: _currentStep == 0 ? Colors.grey : Colors.amber,
                              ),
                              onPressed: () => _previousStep(_metadata['podman_id'] ?? 1),
                            ),
                            Text(
                              'مرحله ${_currentStep + 1} از ${_timelineData.length}',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 16,
                                fontFamily: 'Vazir',
                              ),
                              textAlign: TextAlign.right,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: _currentStep == _timelineData.length - 1 ? Colors.grey : Colors.amber,
                              ),
                              onPressed: () => _nextStep(_metadata['podman_id'] ?? 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildTimelineItem(_timelineData[_currentStep]),
                        // Chatbot Section
                        const SizedBox(height: 16),
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
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
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    'آموزش صوتی',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Vazir',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: TextField(
                                    controller: _textController,
                                    textDirection: TextDirection.rtl,
                                    decoration: InputDecoration(
                                      hintText: 'متن خود را وارد کنید یا برای مبحث جاری خالی بگذارید',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontFamily: 'Vazir',
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[850],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Vazir',
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: _ttsService.isProcessing
                                      ? Column(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        child: Lottie.asset(
                                          'assets/lottie/loading.json',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      if (_ttsService.currentText.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[850],
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: Text(
                                              _ttsService.currentText,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontFamily: 'Vazir',
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  )
                                      : _ttsService.isPlaying
                                      ? Column(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        child: Lottie.asset(
                                          'assets/lottie/speaking.json',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: _stopTeaching,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.red,
                                                Colors.red.shade700,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red.withOpacity(0.5),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.stop,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'توقف',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Vazir',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (_ttsService.currentText.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[850],
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: Text(
                                              _ttsService.currentText,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontFamily: 'Vazir',
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  )
                                      : GestureDetector(
                                    onTap: _startTeaching,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.amber,
                                            Colors.amber.shade700,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.amber.withOpacity(0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      transform: Matrix4.identity(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'شروع آموزش',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Vazir',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    'وضعیت: ${_ttsService.status}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                      fontFamily: 'Vazir',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
    final typeColor = _getTypeColor(item['type'] ?? '');

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
              color: typeColor.withOpacity(0.7),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item['type'] != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      item['type'] ?? '',
                      style: TextStyle(
                        color: typeColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Vazir',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (item['title'] != null) ...[
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    item['title'] ?? '',
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (item['content'] != null) ...[
                Text(
                  item['content'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    fontFamily: 'Vazir',
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
              ],
              if (item['components'] != null && (item['components'] as Map<String, dynamic>).isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    textDirection: TextDirection.rtl,
                    'اجزاء',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
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
                    textDirection: TextDirection.rtl,
                    '${entry.key}: ${entry.value}',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      fontFamily: 'Vazir',
                    ),
                  ),
                )).toList(),
              ],
              if (item['activity'] != null && (item['activity']['مسئله'] != null || item['activity']['پاسخ'] != null)) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'فعالیت',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
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
                      if (item['activity']['مسئله'] != null) ...[
                        Text(
                          item['activity']['مسئله'],
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                            fontFamily: 'Vazir',
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                      ],
                      if (item['activity']['پاسخ'] != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            textDirection: TextDirection.rtl,
                            'پاسخ: ${item['activity']['پاسخ']}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              fontFamily: 'Vazir',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (item['questions'] != null && (item['questions'] as List).isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    textDirection: TextDirection.rtl,
                    'سوالات',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
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
                    textDirection: TextDirection.rtl,
                    question['text'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      fontFamily: 'Vazir',
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