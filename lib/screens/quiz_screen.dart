import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

void main() {
  runApp(const MaterialApp(
    home: QuizScreen(apiUrl: 'your_quiz_api_url_here'),
  ));
}

class QuizScreen extends StatefulWidget {
  final String apiUrl;

  const QuizScreen({Key? key, required this.apiUrl}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int _secondsRemaining = 20;
  List<Question> _questions = [];
  bool _isQuestionLoading = true;
  final HtmlUnescape _htmlUnescape = HtmlUnescape();
  List<Question> _answeredQuestions = [];
  Timer? _timer;
  bool _quizEnded = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (!_quizEnded) {
      _saveQuizResult(interrupted: true);
    }
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse(widget.apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['results'] as List;
        setState(() {
          _questions = data.map((questionData) {
            final question =
                _htmlUnescape.convert(questionData['question'] as String);
            final List<dynamic>? incorrectAnswers =
                questionData['incorrect_answers'] as List<dynamic>?;
            final correctAnswer =
                _htmlUnescape.convert(questionData['correct_answer'] as String);
            final options = [
              ...incorrectAnswers
                      ?.map((e) => _htmlUnescape.convert(e as String)) ??
                  [],
              correctAnswer
            ]..shuffle();
            final category =
                _htmlUnescape.convert(questionData['category'] as String);
            return Question(question, options.cast<String>(), correctAnswer,
                category: category);
          }).toList();
          _isQuestionLoading = false;
          _startTimer();
        });
      } else {
        _handleFetchError('Failed to fetch questions. Please try again later.');
      }
    } catch (e) {
      _handleFetchError(
          'Failed to load questions. Please check your internet connection.');
    }
  }

  void _handleFetchError(String message) {
    setState(() {
      _isQuestionLoading = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Go Back'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isQuestionLoading = true;
                });
                _fetchQuestions();
              },
              child: Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _nextQuestion();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _secondsRemaining = 20;
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _secondsRemaining = 20;
      });
      _startTimer();
    } else {
      _stopTimer();
      _saveQuizResult();
    }
  }

  void _saveQuizResult({bool interrupted = false}) async {
    if (_quizEnded) return;
    _quizEnded = true;

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _answeredQuestions.isNotEmpty) {
      double accuracy = (_score / _answeredQuestions.length) * 100;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('quiz_history')
          .add({
        'score': _score,
        'totalQuestions': _answeredQuestions.length,
        'accuracy': accuracy.toStringAsFixed(2),
        'timestamp': Timestamp.now(),
        'questions': _answeredQuestions.map((q) => q.toMap()).toList(),
        'interrupted': interrupted,
      });
      await _updateOverallAccuracy(user.uid);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            score: _score,
            totalQuestions: _answeredQuestions.length,
            accuracy: accuracy,
            questions: _answeredQuestions,
          ),
        ),
      );
    }
  }

  Future<void> _updateOverallAccuracy(String userId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .get();
    double totalScore = 0;
    int totalQuestions = 0;
    for (var doc in snapshot.docs) {
      totalScore += doc.data()['score'] as num;
      totalQuestions += doc.data()['totalQuestions'] as int;
    }
    double overallAccuracy = (totalScore / totalQuestions) * 100;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'overallAccuracy': overallAccuracy.toStringAsFixed(2),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isQuestionLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No questions available.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isQuestionLoading = true;
                  });
                  _fetchQuestions();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Retry', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    return WillPopScope(
      onWillPop: () async {
        _saveQuizResult(interrupted: true);
        return true;
      },
      child: Scaffold(
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...question.options
                  .map((option) => _buildOption(option))
                  .toList(),
              const SizedBox(height: 20),
              CircularCountdown(
                secondsRemaining: _secondsRemaining,
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
      ),
    );
  }

  Widget _buildOption(String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          if (option == _questions[_currentIndex].correctAnswer) {
            setState(() {
              _score++;
            });
          }
          setState(() {
            _questions[_currentIndex].selectedAnswer = option;
          });
          _answeredQuestions.add(_questions[_currentIndex]);
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

class CircularCountdown extends StatelessWidget {
  final int secondsRemaining;

  const CircularCountdown({Key? key, required this.secondsRemaining})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: secondsRemaining / 20,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                secondsRemaining > 5 ? Colors.green : Colors.red,
              ),
              strokeWidth: 8,
            ),
          ),
          Text(
            '$secondsRemaining',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final double accuracy;
  final List<Question> questions;

  const QuizResultScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Your score: $score / $totalQuestions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Accuracy: ${accuracy.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          const Text('Finish', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizReviewScreen(questions: questions),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Review Questions',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizReviewScreen extends StatelessWidget {
  final List<Question> questions;

  const QuizReviewScreen({Key? key, required this.questions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions Review'),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          Question question = questions[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Correct Answer: ${question.correctAnswer}',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your Answer: ${question.selectedAnswer ?? "-"}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final String correctAnswer;
  final String category;
  String? selectedAnswer;

  Question(this.text, this.options, this.correctAnswer,
      {required this.category, this.selectedAnswer});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options,
      'correctAnswer': correctAnswer,
      'category': category,
      'selectedAnswer': selectedAnswer,
    };
  }
}
