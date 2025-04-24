import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:periodic_table_app/features/chat_bot/data/models/chat_message_model.dart';
import 'package:periodic_table_app/features/chat_bot/data/services/chat_bot_service.dart';
import 'package:periodic_table_app/features/chat_bot/data/services/chat_storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';

class ChatBotScreen extends StatefulWidget {
  final ElementDetailsModel? element;

  const ChatBotScreen({super.key, this.element});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> with SingleTickerProviderStateMixin {
  final List<types.TextMessage> _messages = [];
  late final ChatBotService _chatBotService;
  final ChatStorageService _storageService = ChatStorageService();
  final types.User _user = const types.User(id: 'user');
  final types.User _bot = const types.User(id: 'bot');
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isTyping = false;
  final Map<String, String> _displayedTexts = {};
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _chatBotService = ChatBotService(element: widget.element);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadConversation();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final isFirstTime = await _storageService.isFirstTime();
    setState(() {
      _isFirstTime = isFirstTime;
    });
    if (_isFirstTime && _messages.isEmpty) {
      _addWelcomeMessage();
      await _storageService.setFirstTime(false);
    }
  }

  Future<void> _loadConversation() async {
    final messages = await _storageService.loadConversation();
    if (messages.isNotEmpty) {
      setState(() {
        _messages.addAll(messages);
        for (final message in messages) {
          _displayedTexts[message.id] = message.text;
        }
      });
    }
  }

  Future<void> _saveConversation() async {
    await _storageService.saveConversation(_messages);
  }

  Future<void> _clearConversation() async {
    await _storageService.clearConversation();
    setState(() {
      _messages.clear();
      _displayedTexts.clear();
    });
    await _storageService.setFirstTime(true);
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    _saveConversation();
    super.dispose();
  }

  void _addWelcomeMessage() {
    if (_messages.isNotEmpty) return; // فقط اگر چت خالی باشد پیام خوش‌آمدگویی اضافه شود
    
    final welcomeMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: widget.element != null
          ? 'سلام! من دستیار هوشمند شیمی شما هستم. می‌بینم که شما در حال بررسی عنصر ${widget.element!.name} هستید. چطور می‌توانم در مورد این عنصر کمکتان کنم؟'
          : 'سلام! من دستیار هوشمند شیمی شما هستم. چطور می‌توانم کمکتان کنم؟',
    );
    setState(() {
      _messages.insert(0, welcomeMessage);
      _displayedTexts[welcomeMessage.id] = '';
    });
    _animateText(welcomeMessage);
  }

  void _animateText(types.TextMessage message) {
    final text = message.text;
    _displayedTexts[message.id] = '';
    
    for (var i = 0; i <= text.length; i++) {
      Future.delayed(Duration(milliseconds: i * 20), () {
        if (mounted) {
          setState(() {
            _displayedTexts[message.id] = text.substring(0, i);
          });
        }
      });
    }
  }

  Future<void> _handleSendPressed() async {
    if (_textController.text.trim().isEmpty) return;

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: _textController.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
      _displayedTexts[textMessage.id] = textMessage.text;
      _isTyping = true;
      _textController.clear();
    });

    final response = await _chatBotService.sendMessage(textMessage.text);
    final botMessage = response.toChatMessage() as types.TextMessage;

    setState(() {
      _messages.insert(0, botMessage);
      _isTyping = false;
      _displayedTexts[botMessage.id] = '';
    });
    
    _animateText(botMessage);
    _saveConversation();
  }

  Widget _buildMessageBubble(types.TextMessage message) {
    final isUser = message.author.id == _user.id;
    final displayedText = _displayedTexts[message.id] ?? '';
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[800],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.science, color: Colors.white),
                ),
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blueGrey[800] : Colors.blueGrey[900],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  displayedText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.science, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'چت بات شیمی',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blueGrey[900],
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      title: const Text(
                        'شروع چت جدید',
                        style: TextStyle(
                          fontFamily: 'Lalezar',
                          fontSize: 24,
                        ),
                      ),
                      content: const Text(
                        'آیا مطمئن هستید که می‌خواهید چت جدیدی شروع کنید؟',
                        style: TextStyle(
                          fontFamily: 'Lalezar',
                          fontSize: 18,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'انصراف',
                            style: TextStyle(
                              fontFamily: 'Lalezar',
                              fontSize: 18,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _clearConversation();
                          },
                          child: const Text(
                            'شروع جدید',
                            style: TextStyle(
                              fontFamily: 'Lalezar',
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0 && _isTyping) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[800],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.science, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[900],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildMessageBubble(_messages[index - (_isTyping ? 1 : 0)]);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[800],
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Vazir',
                        ),
                        decoration: InputDecoration(
                          hintText: 'پیام خود را بنویسید...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontFamily: 'Vazir',
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onSubmitted: (_) => _handleSendPressed(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[800],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _handleSendPressed,
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
} 