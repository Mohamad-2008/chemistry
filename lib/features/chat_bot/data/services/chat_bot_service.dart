import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:periodic_table_app/features/chat_bot/data/models/chat_message_model.dart';
import 'package:periodic_table_app/core/models/element_details_model.dart';

class ChatBotService {
  static const String _apiKey = 'AIzaSyBUodT_V76AxIr1iU40_RQdZwifq__jk2w';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  final ElementDetailsModel? element;
  late Dio _dio;
  late FlutterV2ray _v2ray;
  bool _isV2RayRunning = false;

  ChatBotService({this.element}) {
    _dio = Dio();
    _v2ray = FlutterV2ray(
      onStatusChanged: (status) {
        print('V2Ray status: $status');
        _isV2RayRunning = status == 'connected';
      },
    );
    _initializeV2Ray();
  }

  Future<void> _initializeV2Ray() async {
    // کانفیگ V2Ray بر اساس لینک VLESS
    const String v2rayConfig = '''
    {
      "inbounds": [
        {
          "port": 1080,
          "protocol": "socks",
          "settings": {
            "udp": true
          }
        },
        {
          "port": 1081,
          "protocol": "http"
        }
      ],
      "outbounds": [
        {
          "protocol": "vless",
          "settings": {
            "vnext": [
              {
                "address": "tgju.org",
                "port": 80,
                "users": [
                  {
                    "id": "c68aa0bc-a088-46ab-9da0-5f276f51f31c",
                    "encryption": "none"
                  }
                ]
              }
            ]
          },
          "streamSettings": {
            "network": "ws",
            "wsSettings": {
              "path": "/?ed=2048",
              "headers": {
                "Host": "SMalL-IsSue.oNeeAt.co."
              }
            },
            "security": "none"
          }
        },
        {
          "protocol": "freedom",
          "tag": "direct"
        }
      ],
      "routing": {
        "rules": [
          {
            "type": "field",
            "outboundTag": "vless",
            "domain": ["geosite:category-ads-all"]
          }
        ]
      }
    }
    ''';

    try {
      // درخواست مجوزهای لازم (برای اندروید و iOS)
      await _v2ray.requestPermission();

      // شروع V2Ray با کانفیگ
      await _v2ray.startV2Ray(
        remark: 'Chemistry App V2Ray',
        config: v2rayConfig,
      );
      print('V2Ray started successfully');

      // تنظیم Dio برای استفاده از پراکسی محلی V2Ray
      _setupProxy();
    } catch (e) {
      print('Failed to initialize V2Ray: $e');
      _isV2RayRunning = false;
    }
  }

  void _setupProxy() {
    const String proxy = '127.0.0.1:1080'; // پراکسی محلی V2Ray (SOCKS)

    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      HttpClient client = HttpClient();
      client.findProxy = (uri) {
        return 'SOCKS $proxy';
      };
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    print('Using proxy: $proxy');
  }

  Future<bool> testProxy() async {
    try {
      if (!_isV2RayRunning) {
        print('V2Ray is not running.');
        return false;
      }

      final response = await _dio.get(
        'https://www.google.com',
        options: Options(
          validateStatus: (status) => true,
        ),
      );

      print('Test proxy response status: ${response.statusCode}');
      print('Test proxy response body: ${response.data}');

      if (response.statusCode == 200) {
        print('Proxy is working!');
        return true;
      } else {
        print('Proxy failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Proxy test failed with error: $e');
      return false;
    }
  }

  Future<ChatMessageModel> sendMessage(String message) async {
    try {
      if (!_isV2RayRunning) {
        throw Exception('V2Ray is not running. Cannot connect to the server.');
      }

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

      print('Sending request with proxy...');
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

  Future<void> stopV2Ray() async {
    if (_isV2RayRunning) {
      await _v2ray.stopV2Ray();
      _isV2RayRunning = false;
      print('V2Ray stopped.');
    }
  }
}