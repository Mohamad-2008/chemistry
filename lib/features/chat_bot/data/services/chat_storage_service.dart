import 'dart:convert';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:periodic_table_app/features/chat_bot/data/models/chat_conversation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatStorageService {
  static const String _conversationKey = 'chat_conversation';
  static const String _firstTimeKey = 'chat_first_time';

  Future<void> saveConversation(List<types.TextMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final conversation = ChatConversationModel(
      messages: messages,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await prefs.setString(_conversationKey, jsonEncode(conversation.toJson()));
  }

  Future<List<types.TextMessage>> loadConversation() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationJson = prefs.getString(_conversationKey);
    
    if (conversationJson != null) {
      final conversation = ChatConversationModel.fromJson(jsonDecode(conversationJson));
      return conversation.messages;
    }
    
    return [];
  }

  Future<void> clearConversation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_conversationKey);
  }

  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }

  Future<void> setFirstTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, value);
  }
} 