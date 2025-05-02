import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class TtsService with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final String _ttsUrl = 'https://text.pollinations.ai';
  final String _imageUrl = 'https://image.pollinations.ai/prompt';
  bool _isPlaying = false;
  bool _isProcessing = false;
  String _status = 'آماده';
  String _currentText = '';
  String? _generatedImageUrl;
  String _selectedMode = 'teaching';

  bool get isPlaying => _isPlaying;
  bool get isProcessing => _isProcessing;
  String get status => _status;
  String get currentText => _currentText;
  String? get generatedImageUrl => _generatedImageUrl;
  String get selectedMode => _selectedMode;

  void setMode(String mode) {
    _selectedMode = mode;
    _generatedImageUrl = null;
    _status = 'آماده';
    notifyListeners();
  }

  Future<void> textToSpeech(String inputText, {Map<String, dynamic>? userProfile}) async {
    if (inputText.isEmpty) {
      _status = 'خطا: محتوایی برای پخش یافت نشد';
      _isProcessing = false;
      _isPlaying = false;
      print('TTS: Empty input text');
      notifyListeners();
      return;
    }

    _isProcessing = true;
    _isPlaying = false;
    _status = 'در حال پردازش...';
    _currentText = inputText;
    print('TTS: Starting processing, isProcessing: $_isProcessing, isPlaying: $_isPlaying');
    notifyListeners();

    try {
      // Build personalized prompt
      String prompt = _buildPersonalizedPrompt(inputText, userProfile, isTts: true);
      final encodedPrompt = Uri.encodeComponent(prompt);

      final response = await http.get(
        Uri.parse('$_ttsUrl/$encodedPrompt?model=openai-audio&voice=nova'),
        headers: {'Content-Type': 'application/json'},
      );

      _isProcessing = false;
      print('TTS: Processing done, isProcessing: $_isProcessing, Status code: ${response.statusCode}');
      notifyListeners();

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/chemistry_lesson.mp3';
        final file = File(filePath);

        if (await file.exists()) {
          await file.delete();
          print('TTS: Deleted old audio file');
        }

        await file.writeAsBytes(response.bodyBytes);
        print('TTS: Audio file saved at $filePath');

        await _audioPlayer.stop();
        print('TTS: AudioPlayer stopped before new playback');

        await _audioPlayer.setFilePath(file.path);
        _isPlaying = true;
        _status = 'در حال پخش آموزش...';
        print('TTS: Starting playback, isPlaying: $_isPlaying');
        notifyListeners();

        await _audioPlayer.play();
        _isPlaying = false;
        _status = 'آموزش با موفقیت پخش شد!';
        print('TTS: Playback finished, isPlaying: $_isPlaying');
      } else {
        _status = 'خطا در پخش: ${response.statusCode}';
        _isPlaying = false;
        print('TTS: Error in playback, Status code: ${response.statusCode}');
      }
    } catch (e) {
      _status = 'خطا: $e';
      _isPlaying = false;
      _isProcessing = false;
      print('TTS: Exception occurred: $e');
    } finally {
      _isProcessing = false;
      if (!_isPlaying) {
        _status = 'آماده';
      }
      print('TTS: Final state, isProcessing: $_isProcessing, isPlaying: $_isPlaying, status: $_status');
      notifyListeners();
    }
  }

  Future<void> generateImage(String prompt, {Map<String, dynamic>? userProfile}) async {
    if (prompt.isEmpty) {
      _status = 'خطا: پرامپت خالی است';
      _isProcessing = false;
      print('ImageGen: Empty prompt');
      notifyListeners();
      return;
    }

    _isProcessing = true;
    _status = 'در حال تولید تصویر...';
    _generatedImageUrl = null;
    print('ImageGen: Starting processing, isProcessing: $_isProcessing');
    notifyListeners();

    try {
      // Build personalized prompt
      String personalizedPrompt = _buildPersonalizedPrompt(prompt, userProfile, isTts: false);
      final encodedPrompt = Uri.encodeComponent(personalizedPrompt);

      final response = await http.get(
        Uri.parse('$_imageUrl/$encodedPrompt'),
        headers: {'Content-Type': 'application/json'},
      );

      _isProcessing = false;
      print('ImageGen: Processing done, Status code: ${response.statusCode}');
      notifyListeners();

      if (response.statusCode == 200) {
        _generatedImageUrl = '$_imageUrl/$encodedPrompt';
        _status = 'تصویر با موفقیت تولید شد!';
        print('ImageGen: Image generated, URL: $_generatedImageUrl');
      } else {
        _status = 'خطا در تولید تصویر: ${response.statusCode}';
        print('ImageGen: Error in image generation, Status code: ${response.statusCode}');
      }
    } catch (e) {
      _status = 'خطا: $e';
      _isProcessing = false;
      print('ImageGen: Exception occurred: $e');
    } finally {
      _isProcessing = false;
      if (_generatedImageUrl == null) {
        _status = 'آماده';
      }
      print('ImageGen: Final state, isProcessing: $_isProcessing, status: $_status');
      notifyListeners();
    }
  }

  String _buildPersonalizedPrompt(String inputText, Map<String, dynamic>? userProfile, {required bool isTts}) {
    String userInfo = userProfile != null
        ? '''
اطلاعات کاربر:
- نام: ${userProfile['userName']}
- رشته تحصیلی: ${userProfile['fieldOfStudy']}
- مقطع تحصیلی: ${userProfile['educationLevel']}
- سطح دانش شیمی: ${userProfile['chemistryKnowledgeLevel']}
- هدف آموزشی: ${userProfile['educationalGoal']}
- علاقه‌مندی‌های علمی: ${userProfile['scientificInterests']}
'''
        : 'اطلاعات کاربر در دسترس نیست.';

    String instruction = isTts
        ? '''
شما یک دستیار هوشمند شیمی هستید. لطفاً محتوای زیر را به‌صورت آموزشی و متناسب با اطلاعات کاربر ارائه دهید.
پاسخ‌ها باید با توجه به سطح دانش شیمی، هدف آموزشی و علاقه‌مندی‌های کاربر تنظیم شوند.
محتوا: $inputText
$userInfo
'''
        : '''
شما یک دستیار هوشمند شیمی هستید. لطفاً تصویری مرتبط با محتوای زیر تولید کنید که متناسب با اطلاعات کاربر باشد.
تصویر باید با توجه به سطح دانش شیمی، هدف آموزشی و علاقه‌مندی‌های کاربر طراحی شود.
محتوا: $inputText
$userInfo
''';

    // Limit prompt length to 1000 characters to avoid API issues
    return instruction.length > 1000 ? instruction.substring(0, 1000) : instruction;
  }

  Future<void> stop() async {
    if (_isPlaying || _isProcessing) {
      await _audioPlayer.stop();
      _isPlaying = false;
      _isProcessing = false;
      _status = 'پخش متوقف شد';
      print('TTS: Stopped, isPlaying: $_isPlaying, isProcessing: $_isProcessing');
      notifyListeners();
    }
  }

  void reset() {
    _isPlaying = false;
    _isProcessing = false;
    _status = 'آماده';
    _currentText = '';
    _generatedImageUrl = null;
    print('TTS: Reset, isPlaying: $_isPlaying, isProcessing: $_isProcessing');
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    print('TTS: Disposed');
    super.dispose();
  }
}