import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class ChatMessageModel {
  final String id;
  final String text;
  final DateTime createdAt;
  final String authorId;
  final types.MessageType type;

  ChatMessageModel({
    String? id,
    required this.text,
    required this.createdAt,
    required this.authorId,
    this.type = types.MessageType.text,
  }) : id = id ?? const Uuid().v4();

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      authorId: json['authorId'],
      type: types.MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => types.MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'authorId': authorId,
      'type': type.toString(),
    };
  }

  types.TextMessage toChatMessage() {
    return types.TextMessage(
      author: types.User(id: authorId),
      createdAt: createdAt.millisecondsSinceEpoch,
      id: id,
      text: text,
    );
  }
} 