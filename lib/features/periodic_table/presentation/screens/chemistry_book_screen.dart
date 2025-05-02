import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:periodic_table_app/features/chat_bot/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';

class ChemistryBookScreen extends StatefulWidget {
  final int? initialPodmanId;
  const ChemistryBookScreen({super.key, this.initialPodmanId});

  @override
  State<ChemistryBookScreen> createState() => _ChemistryBookScreenState();
}

class _ChemistryBookScreenState extends State<ChemistryBookScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _timelineData = [];
  Map<String, dynamic> _metadata = {};
  int _currentStep = 0;
  bool _isLoading = true;
  bool _showPodmanSelection = true;
  late ScrollController _timelineController;
  Map<int, double> _podmanProgress = {};
  late TtsService _ttsService;
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;

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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _ttsService.addListener(() {
      setState(() {});
    });
    _loadProgress();
    if (widget.initialPodmanId != null) {
      _showPodmanSelection = false;
      _loadTimelineData(widget.initialPodmanId!);
    } else {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _animationController.dispose();
    _ttsService.removeListener(() {
      setState(() {});
    });
    _ttsService.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_ttsService.isPlaying || _ttsService.isProcessing) return;

    String inputText = '';
    if (_timelineData.isNotEmpty) {
      final currentTopic = _timelineData[_currentStep];
      final topicTitle = currentTopic['title'] ?? '';
      final topicContent = currentTopic['content'] ?? '';
      inputText = '$topicTitle: $topicContent';
    }

    final userInput = _textController.text.trim();
    if (userInput.isNotEmpty) {
      inputText = inputText.isNotEmpty
          ? 'مبحث: $inputText\nورودی کاربر: $userInput'
          : userInput;
    }

    // Get user profile from PeriodicTableProvider
    final userProfile = Provider.of<PeriodicTableProvider>(context, listen: false).getUserProfileForAI();

    if (_ttsService.selectedMode == 'teaching') {
      _ttsService.textToSpeech(
        inputText.isNotEmpty ? inputText : 'محتوایی برای آموزش یافت نشد.',
        userProfile: userProfile,
      );
    } else {
      _ttsService.generateImage(
        inputText.isNotEmpty ? inputText : 'تصویری از یک آزمایش شیمی',
        userProfile: userProfile,
      );
    }
    _textController.clear();
    setState(() {});
  }

  void _stopTeaching() {
    _ttsService.stop();
    setState(() {});
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var podman in _podmans) {
        final progress =
            prefs.getDouble('podman_${podman['id']}_progress') ?? 0.0;
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
      final String response =
      await rootBundle.loadString('assets/data/podman$podmanId.json');
      final data = json.decode(response);
      List<dynamic> timeline = data['timeline'] ?? [];
      final pedagogicalFeatures = data['pedagogical_features'] ?? {};

      if (pedagogicalFeatures['نکات کناری'] != null &&
          (pedagogicalFeatures['نکات کناری'] as List).isNotEmpty) {
        timeline.add({
          'id': timeline.length + 1,
          'type': 'نکات کناری',
          'title': 'نکات کناری',
          'content': (pedagogicalFeatures['نکات کناری'] as List).join('\n'),
        });
      }
      if (pedagogicalFeatures['خود را بیازمایید'] != null &&
          (pedagogicalFeatures['خود را بیازمایید'] as List).isNotEmpty) {
        timeline.add({
          'id': timeline.length + 1,
          'type': 'خود را بیازمایید',
          'title': 'خود را بیازمایید',
          'content':
          (pedagogicalFeatures['خود را بیازمایید'] as List).join('\n'),
        });
      }
      if (pedagogicalFeatures['مثال‌های حل شده'] != null &&
          (pedagogicalFeatures['مثال‌های حل شده'] as List).isNotEmpty) {
        timeline.add({
          'id': timeline.length + 1,
          'type': 'مثال‌های حل شده',
          'title': 'مثال‌های حل شده',
          'content':
          (pedagogicalFeatures['مثال‌های حل شده'] as List).join('\n'),
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
    return FadeTransition(
      opacity: _animationController,
      child: Column(
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
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ..._podmans
              .map((podman) => GestureDetector(
            onTap: () => _loadTimelineData(podman['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey[900]!.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _podmanProgress[podman['id']] ?? 0.0,
                          backgroundColor: Colors.grey[600],
                          color: Colors.amber,
                          strokeWidth: 5,
                        ),
                        Text(
                          '${((_podmanProgress[podman['id']] ?? 0.0) * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: _podmanProgress[podman['id']] == 1
                                ? 11
                                : 14,
                            fontWeight: FontWeight.w600,
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
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Vazir',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        podman['subtitle'],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Vazir',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildAIInputBar() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.85),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
            BoxShadow(
              color: Colors.amber.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: _textController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'سوال خود را بپرسید یا مبحث را خالی بگذارید',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Vazir',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.grey[850]!.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.amber.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.amber.shade400,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: _ttsService.isProcessing
                      ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.amber,
                      ),
                    ),
                  )
                      : null,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Vazir',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 0.95).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _ttsService.setMode('teaching');
                              _animationController
                                  .forward()
                                  .then((_) => _animationController.reverse());
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: _ttsService.selectedMode == 'teaching'
                                    ? Colors.amber.withOpacity(0.3)
                                    : Colors.grey[800]!.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _ttsService.selectedMode == 'teaching'
                                      ? Colors.amber.shade400
                                      : Colors.grey[700]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mic,
                                    color:
                                    _ttsService.selectedMode == 'teaching'
                                        ? Colors.amber.shade200
                                        : Colors.grey[300],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'صوتی',
                                    style: TextStyle(
                                      color:
                                      _ttsService.selectedMode == 'teaching'
                                          ? Colors.amber.shade200
                                          : Colors.grey[300],
                                      fontSize: 13,
                                      fontFamily: 'Vazir',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 0.95).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _ttsService.setMode('image');
                              _animationController
                                  .forward()
                                  .then((_) => _animationController.reverse());
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: _ttsService.selectedMode == 'image'
                                    ? Colors.amber.withOpacity(0.3)
                                    : Colors.grey[800]!.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _ttsService.selectedMode == 'image'
                                      ? Colors.amber.shade400
                                      : Colors.grey[700]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: _ttsService.selectedMode == 'image'
                                        ? Colors.amber.shade200
                                        : Colors.grey[300],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'تصویر',
                                    style: TextStyle(
                                      color: _ttsService.selectedMode == 'image'
                                          ? Colors.amber.shade200
                                          : Colors.grey[300],
                                      fontSize: 13,
                                      fontFamily: 'Vazir',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 0.95).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _handleSubmit();
                      _animationController
                          .forward()
                          .then((_) => _animationController.reverse());
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade400,
                            Colors.amber.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ارسال',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Vazir',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _animationController.forward();
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
                    Colors.amber.shade50,
                    Colors.amber.shade100,
                  ],
                ),
              ),
              child: CustomPaint(
                painter: DotsPainter(),
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: _showPodmanSelection
                            ? _buildPodmanSelection()
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_rounded,
                                    color: Colors.amber,
                                    size: 32,
                                  ),
                                  onPressed: () => _handleBack(context),
                                ),
                                Expanded(
                                  child: Column(
                                    textDirection: TextDirection.rtl,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _metadata['title'] ??
                                            'پودمان اول',
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'Vazir',
                                        ),
                                      ),
                                      if (_metadata['author'] != null)
                                        Text(
                                          'نویسنده: ${_metadata['author']}',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Vazir',
                                          ),
                                          textDirection:
                                          TextDirection.rtl,
                                        ),
                                      Text(
                                        'صفحات: ${_metadata['pages'] ?? ''}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Vazir',
                                        ),
                                        textDirection:
                                        TextDirection.rtl,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (_isLoading)
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900]!
                                        .withOpacity(0.9),
                                    borderRadius:
                                    BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const CircularProgressIndicator(
                                    color: Colors.amber,
                                    strokeWidth: 5,
                                  ),
                                ),
                              )
                            else if (_timelineData.isNotEmpty) ...[
                              Container(
                                height: 90,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  controller: _timelineController,
                                  physics:
                                  const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  itemCount: _timelineData.length,
                                  itemBuilder: (context, index) {
                                    final item = _timelineData[index];
                                    final isActive =
                                        index <= _currentStep;
                                    final typeColor =
                                    _getTypeColor(item['type']);

                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: index == 0 ? 8 : 0,
                                        right: index ==
                                            _timelineData.length - 1
                                            ? 8
                                            : 0,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (index > 0) ...[
                                            Container(
                                              width: 30,
                                              height: 3,
                                              color: isActive
                                                  ? typeColor
                                                  : Colors.grey[600],
                                              margin:
                                              const EdgeInsets.only(
                                                  bottom: 28,
                                                  right: 6,
                                                  left: 6),
                                            ),
                                          ],
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _currentStep = index;
                                              });
                                              _scrollToCurrentStep();
                                              _saveProgress(_metadata[
                                              'podman_id'] ??
                                                  1);
                                              _saveCurrentStep(_metadata[
                                              'podman_id'] ??
                                                  1);
                                            },
                                            child: ScaleTransition(
                                              scale: Tween<double>(
                                                  begin: 1.0,
                                                  end: 1.2)
                                                  .animate(
                                                CurvedAnimation(
                                                  parent:
                                                  _animationController,
                                                  curve: Curves.easeInOut,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize:
                                                MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 35,
                                                    height: 35,
                                                    decoration:
                                                    BoxDecoration(
                                                      color: isActive
                                                          ? typeColor
                                                          : Colors
                                                          .grey[600],
                                                      shape:
                                                      BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: isActive
                                                              ? typeColor
                                                              .withOpacity(
                                                              0.8)
                                                              : Colors
                                                              .grey
                                                              .withOpacity(
                                                              0.5),
                                                          blurRadius: 10,
                                                          offset:
                                                          const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${index + 1}',
                                                        style:
                                                        const TextStyle(
                                                          color: Colors
                                                              .white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                          FontWeight
                                                              .w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      height: 6),
                                                  Text(
                                                    item['page'] != null
                                                        ? 'ص ${item['page']}'
                                                        : '',
                                                    style: TextStyle(
                                                      color: isActive
                                                          ? typeColor
                                                          : Colors
                                                          .grey[500],
                                                      fontSize: 12,
                                                      fontFamily: 'Vazir',
                                                      fontWeight:
                                                      FontWeight.w600,
                                                    ),
                                                    textDirection:
                                                    TextDirection.rtl,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: _currentStep == 0
                                          ? Colors.grey[500]
                                          : Colors.amber,
                                      size: 24,
                                    ),
                                    onPressed: () => _previousStep(
                                        _metadata['podman_id'] ?? 1),
                                  ),
                                  Text(
                                    'مرحله ${_currentStep + 1} از ${_timelineData.length}',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Vazir',
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: _currentStep ==
                                          _timelineData.length - 1
                                          ? Colors.grey[500]
                                          : Colors.amber,
                                      size: 24,
                                    ),
                                    onPressed: () => _nextStep(
                                        _metadata['podman_id'] ?? 1),
                                  ),
                                ],
                              ),
                              _buildTimelineItem(
                                  _timelineData[_currentStep]),
                              SizedBox(
                                height: 10,
                              ),
                              if (_ttsService.isProcessing)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: SizedBox(
                                        height: 150,
                                        child: Lottie.asset(
                                          'assets/lottie/loading.json',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              else if (_ttsService.selectedMode ==
                                  'teaching' &&
                                  _ttsService.isPlaying)
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.greenAccent.shade400,
                                        Colors.blueAccent.shade400,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        Colors.red.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: [
                                      ScaleTransition(
                                        scale: Tween<double>(
                                            begin: 1.0, end: 1.50)
                                            .animate(
                                          CurvedAnimation(
                                            parent: _animationController,
                                            curve: Curves.easeInOut,
                                          ),
                                        ),
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          child: Lottie.asset(
                                            'assets/lottie/speaking.json',
                                            fit: BoxFit.contain,
                                            repeat: true,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                              begin: 1.0, end: 0.95)
                                              .animate(
                                            CurvedAnimation(
                                              parent:
                                              _animationController,
                                              curve: Curves.easeInOut,
                                            ),
                                          ),
                                          child: GestureDetector(
                                            onTap: _stopTeaching,
                                            child: Container(
                                              padding:
                                              const EdgeInsets.all(
                                                  12),
                                              decoration: BoxDecoration(
                                                color:
                                                Colors.red.shade700,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red
                                                        .withOpacity(0.5),
                                                    blurRadius: 10,
                                                    offset: const Offset(
                                                        0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.stop,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (_ttsService.selectedMode ==
                                    'image' &&
                                    _ttsService.generatedImageUrl != null)
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            child: Image.network(
                                              _ttsService
                                                  .generatedImageUrl!,
                                              height: 220,
                                              width: 220,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                  stackTrace) {
                                                return Container(
                                                  height: 220,
                                                  width: 220,
                                                  color: Colors.grey[850],
                                                  child: const Center(
                                                    child: Text(
                                                      'خطا در بارگذاری تصویر',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontFamily: 'Vazir',
                                                        fontWeight:
                                                        FontWeight.w500,
                                                      ),
                                                      textDirection:
                                                      TextDirection.rtl,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: _buildAIInputBar(),
                              )
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey[900]!.withOpacity(0.9),
              Colors.grey[850]!.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: typeColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (item['type'] != null) ...[
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    item['type'] ?? '',
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Vazir',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (item['type'] != null) ...[
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  item['title'] ?? '',
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Vazir',
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (item['content'] != null) ...[
              Text(
                item['content'] ?? '',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Vazir',
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
            ],
            if (item['components'] != null &&
                (item['components'] as Map<String, dynamic>).isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  textDirection: TextDirection.rtl,
                  'اجزاء',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...(item['components'] as Map<String, dynamic>)
                  .entries
                  .map((entry) => Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  textDirection: TextDirection.rtl,
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Vazir',
                  ),
                ),
              ))
                  .toList(),
            ],
            if (item['activity'] != null &&
                (item['activity']['مسئله'] != null ||
                    item['activity']['پاسخ'] != null)) ...[
              const SizedBox(height: 20),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'فعالیت',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item['activity']['مسئله'] != null) ...[
                      Text(
                        item['activity']['مسئله'],
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Vazir',
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                    ],
                    if (item['activity']['پاسخ'] != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          textDirection: TextDirection.rtl,
                          'پاسخ: ${item['activity']['پاسخ']}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (item['questions'] != null &&
                (item['questions'] as List).isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  textDirection: TextDirection.rtl,
                  'سوالات',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...(item['questions'] as List)
                  .map<Widget>((question) => Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  textDirection: TextDirection.rtl,
                  question['text'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Vazir',
                  ),
                ),
              ))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }
}

class DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 6 + 3;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WaveformPainter extends CustomPainter {
  final AnimationController controller;

  WaveformPainter(this.controller) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final double barWidth = 4;
    final double spacing = 2;
    final int barCount = (size.width / (barWidth + spacing)).floor();
    final double maxHeight = size.height;

    for (int i = 0; i < barCount; i++) {
      final double t = (controller.value + i / barCount) % 1.0;
      final double height = maxHeight * (0.3 + 0.7 * sin(t * 2 * pi).abs());
      final double x = i * (barWidth + spacing);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, (size.height - height) / 2, barWidth, height),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}