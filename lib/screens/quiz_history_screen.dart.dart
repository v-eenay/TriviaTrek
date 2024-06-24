import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({Key? key}) : super(key: key);

  @override
  _QuizHistoryScreenState createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  late Future<List<QuizHistory>> _futureQuizHistory;

  @override
  void initState() {
    super.initState();
    _futureQuizHistory = _fetchQuizHistory();
  }

  Future<List<QuizHistory>> _fetchQuizHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid)
            .collection('quiz_history')
            .orderBy('timestamp', descending: true)
            .get();

        List<QuizHistory> quizHistory = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return QuizHistory(
            score: data['score'],
            totalQuestions: data['totalQuestions'],
            accuracy: data['accuracy'],
            timestamp: data['timestamp'].toDate(),
            questions: (data['questions'] as List)
                .map((question) => Question.fromMap(question))
                .toList(),
          );
        }).toList();

        return quizHistory;
      } catch (e) {
        print('Error fetching quiz history: $e');
        return [];
      }
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<QuizHistory>>(
        future: _futureQuizHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No quiz history found'),
            );
          } else {
            List<QuizHistory> quizHistory = snapshot.data!;
            return ListView.builder(
              itemCount: quizHistory.length,
              itemBuilder: (context, index) {
                QuizHistory history = quizHistory[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      'Score: ${history.score} / ${history.totalQuestions}',
                    ),
                    subtitle: Text(
                      'Accuracy: ${history.accuracy}% - ${history.timestamp}',
                    ),
                    onTap: () => _showQuestionsDialog(context, history),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Quiz History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            // Stay on Quiz History screen (current screen)
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  void _showQuestionsDialog(BuildContext context, QuizHistory history) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Questions Review'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: history.questions.length,
              itemBuilder: (context, index) {
                Question question = history.questions[index];
                String selectedAnswer =
                    question.selectedAnswer ?? 'No answer selected';
                return ListTile(
                  title: Text(question.text),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Answer: $selectedAnswer'),
                      Text('Correct Answer: ${question.correctAnswer}'),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class QuizHistory {
  final int score;
  final int totalQuestions;
  final String accuracy;
  final DateTime timestamp;
  final List<Question> questions;

  QuizHistory({
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.timestamp,
    required this.questions,
  });
}

class Question {
  final String text;
  final String correctAnswer;
  final String? selectedAnswer;

  Question({
    required this.text,
    required this.correctAnswer,
    this.selectedAnswer,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      text: map['text'],
      correctAnswer: map['correctAnswer'],
      selectedAnswer: map['selectedAnswer'],
    );
  }
}
