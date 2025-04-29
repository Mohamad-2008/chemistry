import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:periodic_table_app/features/chat_bot/data/models/chat_message_model.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';

class ChatBotService {
  static const String _apiKey = 'AIzaSyBUodT_V76AxIr1iU40_RQdZwifq__jk2w';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  final ElementDetailsModel? element;
  late Dio _dio;

  ChatBotService({this.element}) {
    _dio = Dio();
  }

  Future<ChatMessageModel> sendMessage(String message) async {
    try {
      final prompt = element != null
          ? '''
شما یک دستیار هوشمند شیمی هستید. کاربر در حال بررسی عنصر ${element!.name} (${element!.symbol}) است.
لطفاً به سوالات زیر در مورد این عنصر پاسخ دهید. اگر سوال خارج از حوزه شیمی یا این عنصر باشد،
لطفاً توضیح دهید که فقط به سوالات شیمی و در مورد این عنصر پاسخ می‌دهید.

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

سوال: $message
'''
          : '''
شما یک دستیار هوشمند شیمی هستید. لطفاً به سوالات زیر فقط در زمینه شیمی پاسخ دهید.
اگر سوال خارج از حوزه شیمی باشد، لطفاً توضیح دهید که فقط به سوالات شیمی پاسخ می‌دهید.

سوال: $message
''';

      print('Sending request to Gemini...');
      final response = await _dio.post(
        '$_baseUrl?key=$_apiKey',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true,
        ),
        data: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          }
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {

          final text = data['candidates'][0]['content']['parts'][0]['text'] ?? 'متاسفم، پاسخی دریافت نشد.';

          return ChatMessageModel(
            text: text,
            createdAt: DateTime.now(),
            authorId: 'bot',
          );
        } else {
          throw Exception('پاسخ نامعتبر از سرور دریافت شد');
        }
      } else {
        throw Exception('خطا در ارتباط با سرور: ${response.statusCode}');
      }
    } catch (e) {
      return ChatMessageModel(
        text: 'خطا در ارتباط با سرور: ${e.toString()}',
        createdAt: DateTime.now(),
        authorId: 'bot',
      );
    }
  }
}