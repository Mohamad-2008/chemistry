import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class TtsService with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final String _ttsUrl = 'https://text.pollinations.ai';
  bool _isPlaying = false;
  bool _isProcessing = false;
  String _status = 'آماده برای آموزش';
  String _currentText = '';

  bool get isPlaying => _isPlaying;
  bool get isProcessing => _isProcessing;
  String get status => _status;
  String get currentText => _currentText;

  Future<void> textToSpeech(String inputText) async {
    if (inputText.isEmpty) {
      _status = 'خطا: محتوایی برای پخش یافت نشد';
      _isProcessing = false;
      _isPlaying = false;
      notifyListeners();
      return;
    }

    _isProcessing = true;
    _isPlaying = false;
    _status = 'در حال پردازش...';
    _currentText = inputText;
    notifyListeners();

    try {
      final encodedPrompt = Uri.encodeComponent(inputText);
      final response = await http.get(
        Uri.parse('$_ttsUrl/$encodedPrompt?model=openai-audio&voice=nova'),
        headers: {'Content-Type': 'application/json'},
      );

      _isProcessing = false;
      notifyListeners();

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/chemistry_lesson.mp3');
        await file.writeAsBytes(response.bodyBytes);
        await _audioPlayer.setFilePath(file.path);
        _isPlaying = true;
        _status = 'در حال پخش آموزش...';
        notifyListeners();
        await _audioPlayer.play();
        _isPlaying = false;
        _status = 'آموزش با موفقیت پخش شد!';
      } else {
        _status = 'خطا در پخش: ${response.statusCode}';
        _isPlaying = false;
      }
    } catch (e) {
      _status = 'خطا: $e';
      _isPlaying = false;
      _isProcessing = false;
    } finally {
      _isProcessing = false;
      if (!_isPlaying) {
        _status = 'آماده برای آموزش';
      }
      notifyListeners();
    }
  }

  Future<void> stop() async {
    if (_isPlaying || _isProcessing) {
      await _audioPlayer.stop();
      _isPlaying = false;
      _isProcessing = false;
      _status = 'پخش متوقف شد';
      notifyListeners();
    }
  }

  void reset() {
    _isPlaying = false;
    _isProcessing = false;
    _status = 'آماده برای آموزش';
    _currentText = '';
    notifyListeners();
  }

  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}