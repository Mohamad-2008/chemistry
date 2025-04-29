import 'package:flutter/material.dart';
import 'package:periodic_table_app/features/chat_bot/presentation/screens/chat_bot_screen.dart';

class ChatBotFloatingButton extends StatefulWidget {
  const ChatBotFloatingButton({super.key});

  @override
  State<ChatBotFloatingButton> createState() => _ChatBotFloatingButtonState();
}

class _ChatBotFloatingButtonState extends State<ChatBotFloatingButton> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isExpanded ? 300 : 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_isExpanded)
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'چت بات شیمی',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              _isExpanded ? Icons.close : Icons.chat_bubble_outline,
              color: Colors.white,
            ),
            onPressed: () {
              if (_isExpanded) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatBotScreen(),
                  ),
                );
              } else {
                setState(() {
                  _isExpanded = true;
                });
              }
            },
          ),
        ],
      ),
    );
  }
} 