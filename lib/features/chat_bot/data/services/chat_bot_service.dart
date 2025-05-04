import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:periodic_table_app/features/chat_bot/data/models/chat_message_model.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';

class ChatBotService {
  static const String _baseUrl = 'https://text.pollinations.ai/';
  final ElementDetailsModel? element;
  late Dio _dio;

  ChatBotService({this.element}) {
    _dio = Dio();
  }

  Future<ChatMessageModel> sendMessage(String message, {Map<String, dynamic>? userProfile}) async {
    try {
      // ساخت پرامپت با استفاده از تابع جداگانه
      final prompt = _buildPersonalizedPrompt(message, userProfile);
      // محدود کردن طول پرامپت به 1000 کاراکتر
      final trimmedPrompt = prompt.length > 1000 ? prompt.substring(0, 1000) : prompt;

      print('Sending request to Pollinations AI... Prompt: $trimmedPrompt');
      print('UserProfile: $userProfile');
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true,
        ),
        data: jsonEncode({
          'messages': [
            {
              'role': 'user',
              'content': trimmedPrompt,
            }
          ],
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.data}');

      if (response.statusCode == 200) {
        String text;
        if (response.data is String) {
          text = response.data;
        } else if (response.data is Map && response.data['text'] != null) {
          text = response.data['text'];
        } else if (response.data is Map &&
            response.data['messages'] != null &&
            response.data['messages'] is List &&
            response.data['messages'].isNotEmpty) {
          text = response.data['messages'].last['content'] ?? 'متاسفم، پاسخی دریافت نشد.';
        } else {
          text = 'متاسفم، پاسخی دریافت نشد.';
        }

        return ChatMessageModel(
          text: text.trim(),
          createdAt: DateTime.now(),
          authorId: 'bot',
        );
      } else {
        throw Exception('خطا در ارتباط با سرور: ${response.statusCode}, جزئیات: ${response.data}');
      }
    } catch (e) {
      print('Error: $e');
      return ChatMessageModel(
        text: 'خطا در ارتباط با سرور: ${e.toString()}',
        createdAt: DateTime.now(),
        authorId: 'bot',
      );
    }
  }

  String _buildPersonalizedPrompt(String message, Map<String, dynamic>? userProfile) {
    // ساخت اطلاعات کاربر با مقادیر پیش‌فرض
    String userInfo = userProfile != null
        ? '''
اطلاعات کاربر:
- نام: ${userProfile['userName'] ?? 'کاربر ناشناس'}
- رشته تحصیلی: ${userProfile['fieldOfStudy'] ?? 'نامشخص'}
- مقطع تحصیلی: ${userProfile['educationLevel'] ?? 'نامشخص'}
- سطح دانش شیمی: ${userProfile['chemistryKnowledgeLevel'] ?? 'مبتدی'}
- هدف آموزشی: ${userProfile['educationalGoal'] ?? 'یادگیری عمومی'}
- علاقه‌مندی‌های علمی: ${userProfile['scientificInterests'] ?? 'هیچ‌کدام'}
'''
        : 'اطلاعات کاربر در دسترس نیست.';

    // ساخت پرامپت بر اساس وجود یا عدم وجود عنصر
    String instruction = element != null
        ? '''
شما یک دستیار هوشمند شیمی هستید. کاربر در حال بررسی عنصر ${element!.name} (${element!.symbol}) است.
لطفاً به سوالات زیر در مورد این عنصر پاسخ دهید، با توجه به اطلاعات کاربر و سطح دانش، هدف آموزشی و علاقه‌مندی‌های او.
اگر سوال خارج از حوزه شیمی یا این عنصر باشد، توضیح دهید که فقط به سوالات شیمی و در مورد این عنصر پاسخ می‌دهید.

اطلاعات عنصر:
- نام: ${element!.name}
- نماد: ${element!.symbol}
- عدد اتمی: ${element!.number}
- جرم اتمی: ${element!.atomicMass}
- دسته‌بندی: ${element!.category}
- گروه: ${element!.xpos}
- دوره: ${element!.ypos}
- فاز: ${element!.phase}
- خلاصه: ${element!.summary}

$userInfo

سوال: $message
'''
        : '''
شما یک دستیار هوشمند شیمی هستید. لطفاً به سوالات زیر فقط در زمینه شیمی پاسخ دهید، با توجه به اطلاعات کاربر و سطح دانش، هدف آموزشی و علاقه‌مندی‌های او.
اگر سوال خارج از حوزه شیمی باشد، توضیح دهید که فقط به سوالات شیمی پاسخ می‌دهید.

$userInfo

سوال: $message
''';

    return instruction;
  }
}