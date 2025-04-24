import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatConversationModel {
  final List<types.TextMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversationModel({
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      messages: (json['messages'] as List)
          .map((m) => types.TextMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
} 