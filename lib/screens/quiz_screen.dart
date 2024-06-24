import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int _secondsRemaining = 20;
  late final List<Question> _questions;
  bool _isQuestionLoading = true;
  final HtmlUnescape _htmlUnescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    super.dispose();
    _stopTimer();
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await http.get(
          Uri.parse('https://opentdb.com/api.php?amount=20&type=multiple'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['results'] as List;
        setState(() {
          _questions = data.map((questionData) {
            final question =
                _htmlUnescape.convert(questionData['question'] as String);
            final incorrectAnswers = (questionData['incorrect_answers'] as List)
                .map((e) => _htmlUnescape.convert(e as String))
                .toList();
            final correctAnswer =
                _htmlUnescape.convert(questionData['correct_answer'] as String);
            final options = [...incorrectAnswers, correctAnswer]..shuffle();
            return Question(question, options, correctAnswer);
          }).toList();
          _isQuestionLoading = false;
        });
        _startTimer();
      } else {
        throw Exception('Failed to fetch questions');
      }
    } catch (e) {
      setState(() {
        _isQuestionLoading = false;
      });
      _showErrorDialog('Failed to load questions. Please try again later.');
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
        _startTimer();
      } else {
        _nextQuestion();
      }
    });
  }

  void _stopTimer() {
    _secondsRemaining = 20;
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _secondsRemaining = 20;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Complete',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your score: $_score / ${_questions.length}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              Text(
                  'Accuracy: ${(_score / _questions.length * 100).toStringAsFixed(2)}%',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Finish', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isQuestionLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final question = _questions[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1} / ${_questions.length}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  question.text,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...question.options.map((option) => _buildOption(option)),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _secondsRemaining / 20,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _secondsRemaining > 5 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Time Remaining: $_secondsRemaining seconds',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          if (option == _questions[_currentIndex].correctAnswer) {
            setState(() {
              _score++;
            });
          }
          _stopTimer();
          _nextQuestion();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          option,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final String correctAnswer;

  Question(this.text, this.options, this.correctAnswer);
}
