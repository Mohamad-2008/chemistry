import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  final int podmanId;
  final String podmanTitle;

  const QuizScreen({
    super.key,
    required this.podmanId,
    required this.podmanTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  String? _selectedAnswer;
  bool _isLoading = true;

  void _shuffleAnswers(Map<String, dynamic> question) {
    final answers = List<String>.from(question['answers']);
    final correctAnswer = question['correct_answer'];

    // بهم ریختن گزینه‌ها
    answers.shuffle(Random());

    // پیدا کردن موقعیت جدید گزینه درست
    final newCorrectIndex = answers.indexOf(correctAnswer);

    // به‌روزرسانی گزینه درست
    question['correct_answer'] = answers[newCorrectIndex];
    question['answers'] = answers;
  }

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      List<Map<String, dynamic>> allQuestions = [];
      if (widget.podmanId == 2) {
        // بارگذاری هر دو فایل برای پودمان ۲
        final String response1 =
            await rootBundle.loadString('assets/P2 (1).json');
        final String response2 = await rootBundle.loadString('assets/P2s.json');
        final data1 = json.decode(response1);
        final data2 = json.decode(response2);
        allQuestions
            .addAll(List<Map<String, dynamic>>.from(data1['questions']));
        allQuestions
            .addAll(List<Map<String, dynamic>>.from(data2['questions']));
      } else {
        // بارگذاری یک فایل برای سایر پودمان‌ها
        final String response =
            await rootBundle.loadString('assets/P${widget.podmanId}.json');
        final data = json.decode(response);
        allQuestions = List<Map<String, dynamic>>.from(data['questions']);
      }

      // انتخاب ۲۰ سوال تصادفی
      allQuestions.shuffle(Random());
      final questions = allQuestions.take(20).toList();

      // بهم ریختن گزینه‌ها برای هر سوال
      for (var question in questions) {
        _shuffleAnswers(question);
      }

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطا در بارگذاری سوالات'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleAnswer(String answer) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      if (answer == _questions[_currentQuestionIndex]['correct_answer']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswer = null;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'نتیجه آزمون',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Vazir',
            color: Colors.amber,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'نمره شما: $_score از ${_questions.length}',
              style: const TextStyle(
                fontFamily: 'Vazir',
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'درصد موفقیت: ${((_score / _questions.length) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontFamily: 'Vazir',
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'بازگشت',
              style: TextStyle(
                fontFamily: 'Vazir',
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.amber,
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'آزمون ${widget.podmanTitle}',
            style: const TextStyle(
              fontFamily: 'Vazir',
              color: Colors.amber,
            ),
          ),
          backgroundColor: Colors.grey[900],
        ),
        body: const Center(
          child: Text(
            'سوالی برای این پودمان یافت نشد.',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 18,
              color: Colors.amber,
            ),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'آزمون ${widget.podmanTitle}',
          style: const TextStyle(
            fontFamily: 'Vazir',
            color: Colors.amber,
          ),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade50,
              Colors.amber.shade100,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'سوال ${_currentQuestionIndex + 1} از ${_questions.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 18,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  currentQuestion['question'],
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 20),
              ...List<String>.from(currentQuestion['answers']).map((answer) {
                final isSelected = answer == _selectedAnswer;
                final isCorrect = answer == currentQuestion['correct_answer'];
                Color backgroundColor = Colors.grey[900]!;
                if (_isAnswered) {
                  if (isSelected) {
                    backgroundColor = isCorrect ? Colors.green : Colors.red;
                  } else if (isCorrect) {
                    backgroundColor = Colors.green;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () => _handleAnswer(answer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      answer,
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                );
              }).toList(),
              const Spacer(),
              if (_isAnswered)
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentQuestionIndex < _questions.length - 1
                        ? 'سوال بعدی'
                        : 'پایان آزمون',
                    style: const TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
