import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';
import 'package:periodic_table_app/core/utils/color_utils.dart';
import 'package:periodic_table_app/core/utils/translation_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:periodic_table_app/features/chat_bot/data/services/chat_bot_service.dart';
import 'package:periodic_table_app/core/routes/app_routes.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';

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
  final TextEditingController _questionController = TextEditingController();
  final List<String> _answers = [];
  int _currentAnswerIndex = 0;
  String _displayedAnswer = '';
  bool _isLoading = false;
  final List<String> _hintTexts = [];
  int _currentHintIndex = 0;
  bool _showChatInput = false;
  bool _isFirstAnswer = true;
  bool _isExpanded = false;
  final GlobalKey _answerBoxKey = GlobalKey();
  final GlobalKey _chatInputKey = GlobalKey();
  double _answerBoxHeight = 0.0;
  double _chatInputHeight = 0.0;

  late Animation<double> _boxScaleAnimation;
  late Animation<double> _buttonScaleAnimation;

  double _getHeight(GlobalKey key) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 0.0;
  }

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

    _boxScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _buttonScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
    _initializeHintTexts();
  }

  void _updateHeights() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          final RenderBox? answerBox = _answerBoxKey.currentContext?.findRenderObject() as RenderBox?;
          final RenderBox? chatInputBox = _chatInputKey.currentContext?.findRenderObject() as RenderBox?;
          _answerBoxHeight = answerBox?.size.height ?? 0.0;
          _chatInputHeight = chatInputBox?.size.height ?? 0.0;
        });
      }
    });
  }

  void _initializeHintTexts() {
    _hintTexts.addAll([
      'سوال خود را در مورد ${widget.element.name} بپرسید...',
      'می‌خواهید در مورد ${widget.element.name} چه بدانید؟',
      'درباره ${widget.element.name} سوال دارید؟',
      '${widget.element.name} را بهتر بشناسید...',
    ]);
    _startHintRotation();
  }

  void _startHintRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % _hintTexts.length;
        });
        _startHintRotation();
      }
    });
  }

  void _toggleChatInput() {
    setState(() {
      _showChatInput = !_showChatInput;
      if (!_showChatInput) {
        _answers.clear();
      }
    });
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _animateAnswer(String answer) {
    _displayedAnswer = '';
    if (_isFirstAnswer) {
      for (var i = 0; i <= answer.length; i++) {
        Future.delayed(Duration(milliseconds: i * 20), () {
          if (mounted) {
            setState(() {
              _displayedAnswer = answer.substring(0, i);
            });
          }
        });
      }
      _isFirstAnswer = false;
    } else {
      setState(() {
        _displayedAnswer = answer;
      });
    }
  }

  Future<void> _sendQuestion() async {
    if (_questionController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    FocusScope.of(context).unfocus();

    final chatBotService = ChatBotService(element: widget.element);
    final response = await chatBotService.sendMessage(_questionController.text);

    setState(() {
      _answers.add(response.text);
      _currentAnswerIndex = _answers.length - 1;
      _isLoading = false;
      _questionController.clear();
      _isFirstAnswer = true;
    });

    _animateAnswer(_answers[_currentAnswerIndex]);
    _updateHeights();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('نمی‌توان لینک را باز کرد: $url')),
      );
    }
  }

  bool _shouldShowExpandButton(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Vazir',
        ),
      ),
      maxLines: 6,
      textDirection: TextDirection.rtl,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<PeriodicTableProvider>(context, listen: false).clearSelectedElement();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButton: ScaleTransition(
          scale: _buttonScaleAnimation,
          child: Container(
            width: 60,
            height: 60,
            margin: EdgeInsets.only(
              bottom: !_showChatInput
                  ? 10
                  : _showChatInput && _answers.isEmpty
                      ? _getHeight(_chatInputKey)
                      : _getHeight(_chatInputKey) + _getHeight(_answerBoxKey) + 20,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueGrey[900],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _showChatInput ? Icons.close : Icons.chat_bubble_outline,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  _showChatInput = !_showChatInput;
                  if (!_showChatInput) {
                    _answers.clear();
                    _currentAnswerIndex = 0;
                    _displayedAnswer = '';
                  }
                });
              },
            ),
          ),
        ),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
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
            if (_answers.isNotEmpty)
              Positioned(
                key: _answerBoxKey,
                bottom: 80,
                left: 8,
                right: 8,
                child: ScaleTransition(
                  scale: _boxScaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: _isExpanded
                                ? MediaQuery.of(context).size.height * 0.6
                                : MediaQuery.of(context).size.height * 0.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[900],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey[800]!.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[800],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        color: _currentAnswerIndex > 0 ? Colors.white : Colors.white30,
                                        size: 20,
                                      ),
                                      onPressed: _currentAnswerIndex > 0
                                          ? () {
                                              setState(() {
                                                _currentAnswerIndex--;
                                                _displayedAnswer = _answers[_currentAnswerIndex];
                                              });
                                            }
                                          : null,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey[700],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_currentAnswerIndex + 1}/${_answers.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Vazir',
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color: _currentAnswerIndex < _answers.length - 1
                                                ? Colors.white
                                                : Colors.white30,
                                            size: 20,
                                          ),
                                          onPressed: _currentAnswerIndex < _answers.length - 1
                                              ? () {
                                                  setState(() {
                                                    _currentAnswerIndex++;
                                                    _displayedAnswer = _answers[_currentAnswerIndex];
                                                  });
                                                }
                                              : null,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isExpanded = !_isExpanded;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (_isExpanded)
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Text(
                                        _displayedAnswer,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Vazir',
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (!_isExpanded)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.blueGrey[900]!,
                                        Colors.blueGrey[900]!.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        _displayedAnswer,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'Vazir',
                                          height: 1.4,
                                        ),
                                        maxLines: 6,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (_shouldShowExpandButton(_displayedAnswer))
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _isExpanded = true;
                                              });
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.blueGrey[700],
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.keyboard_arrow_up,
                                                  color: Colors.white.withOpacity(0.9),
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'مشاهده کامل پاسخ',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontSize: 12,
                                                    fontFamily: 'Vazir',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_showChatInput)
              Positioned(
                key: _chatInputKey,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[900],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey[800]!.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, -4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blueGrey[800]!,
                                Colors.blueGrey[700]!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _questionController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Vazir',
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: _hintTexts[_currentHintIndex],
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontFamily: 'Vazir',
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onSubmitted: (_) => _sendQuestion(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blueGrey[800]!,
                                  Colors.blueGrey[700]!,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: _isLoading ? null : _sendQuestion,
                            ),
                          ),
                          if (_isLoading)
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.9)),
                              ),
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
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final categoryColor = ColorUtils.getCategoryColor(widget.element.category).withOpacity(0.6);
    final secondaryCategoryColor = ColorUtils.getCategoryColor(widget.element.category).withOpacity(0.5);

    final categories = widget.element.category.split(',').map((c) => c.trim().toUpperCase()).toList();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SliverAppBar(
        expandedHeight: 300.0,
        floating: false,
        pinned: true,
        stretch: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: IconButton(
              icon: const Icon(Icons.compare_arrows, color: Colors.white),
              onPressed: () {
                final elementModel = ElementModel(
                  number: widget.element.number,
                  symbol: widget.element.symbol,
                  name: widget.element.name,
                  category: widget.element.category,
                  xpos: widget.element.xpos,
                  ypos: widget.element.ypos,
                  atomicMass: double.tryParse(widget.element.atomicMass) ?? 0.0,
                  phase: widget.element.phase,
                );
                AppRoutes.navigateToElementSearch(
                  context,
                  firstElement: elementModel,
                  isForComparison: true,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                _launchURL(widget.element.source);
              },
            ),
          ),
        ],
        flexibleSpace: LayoutBuilder(
          builder: (context, constraints) {
            final isExpanded = constraints.maxHeight > 190;

            return Stack(
              children: [
                FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(
                    bottom: isExpanded ? 0.0 : 0,
                    left: isExpanded ? 0 : 0,
                    right: 12,
                  ),
                  title: FadeTransition(
                    opacity: _fadeAnimation,
                    child: TweenAnimationBuilder<EdgeInsets>(
                      tween: EdgeInsetsTween(
                        begin: isExpanded
                            ? const EdgeInsets.only(bottom: 8, left: 52, right: 4)
                            : const EdgeInsets.only(bottom: 18, left: 18, right: 4),
                        end: isExpanded
                            ? const EdgeInsets.only(bottom: 18, left: 18, right: 4)
                            : const EdgeInsets.only(bottom: 8, left: 52, right: 4),
                      ),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      builder: (context, padding, child) {
                        return Padding(
                          padding: padding,
                          child: child,
                        );
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: isExpanded ? 1 : 0, end: isExpanded ? 1 : 0),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: Transform.scale(
                                        scale: 0.9 + (0.1 * value),
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
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
                                        const SizedBox(height: 2),
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
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: List.generate(categories.length, (index) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: index == 0 && categories.length > 1 ? 4 : 0),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: index == 0
                                                ? categoryColor.withOpacity(0.7)
                                                : secondaryCategoryColor,
                                            borderRadius: BorderRadius.circular(5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.4),
                                                blurRadius: 3,
                                                offset: const Offset(2, 2),
                                              ),
                                            ],
                                          ),
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width * 0.4,
                                          ),
                                          child: Text(
                                            TranslationUtils.translate(categories[index]),
                                            style: const TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'Vazir',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: isExpanded ? 0 : 1, end: isExpanded ? 0 : 1),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: Transform.scale(
                                        scale: 0.9 + (0.1 * value),
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
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
                                    const SizedBox(width: 12),
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
                                            const SizedBox(width: 4),
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
                            ),
                          ),
                        ],
                      ),
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
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return _buildFallbackImage(context);
                                },
                                errorBuilder: (context, error, stackTrace) => _buildFallbackImage(context),
                              )
                            : _buildFallbackImage(context),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black54,
                              Colors.black12,
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
    final categoryColor = ColorUtils.getCategoryColor(widget.element.category);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor,
            categoryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            );
          },
          child: Image.asset(
            'assets/images/atom.png',
            key: const ValueKey('atom_image'),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image_not_supported,
                key: const ValueKey('error_icon'),
                size: 50,
                color: Colors.white.withOpacity(0.8),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    final categoryColor = ColorUtils.getCategoryColor(widget.element.category);

    return ScaleTransition(
      scale: _boxScaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[850]?.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: categoryColor,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) Icon(icon, color: Colors.white70, size: 20),
                  if (icon != null) const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Vazir',
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 24, thickness: 1),
              ...children,
            ],
          ),
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
    return category.split(',').map((c) => c.trim().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')).join(', ');
  }
}