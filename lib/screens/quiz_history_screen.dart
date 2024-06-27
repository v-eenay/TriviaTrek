import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app_enrichment/screens/categories_screen.dart';
import 'package:quiz_app_enrichment/screens/highscores_screen.dart';
import 'package:quiz_app_enrichment/screens/home_screen.dart';
import 'package:quiz_app_enrichment/screens/leaderboard_screen.dart';
import 'package:quiz_app_enrichment/screens/profile_screen.dart';
import 'package:quiz_app_enrichment/screens/settings_screen.dart';
import '../models/user_model.dart';

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
        title: const Text(
          'Quiz History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(
            color: Colors.white), // Ensuring the back button is white
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
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        'Score: ${history.score} / ${history.totalQuestions}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Accuracy: ${history.accuracy}%',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Date: ${_formatTimestamp(history.timestamp)}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _navigateToQuestionsReview(context, history),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(Icons.home, () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                DocumentSnapshot<Map<String, dynamic>> snapshot =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();
                UserModel userModel = UserModel(
                  userId: user.uid,
                  username: snapshot.data()?['username'] ?? '',
                  email: user.email ?? '',
                  name: snapshot.data()?['name'] ?? '',
                  dateOfBirth: snapshot.data()?['dateOfBirth'] ?? '',
                  address: snapshot.data()?['address'] ?? '',
                );
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HomeScreen(user: userModel)));
              }
            }),
            _buildBottomNavItem(Icons.category, () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => CategoriesScreen()));
            }),
            _buildBottomNavItem(Icons.star, () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HighscoresScreen()));
            }),
            _buildBottomNavItem(Icons.leaderboard, () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LeaderboardScreen()));
            }),
            _buildBottomNavItem(Icons.person, () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ProfileScreen(username: 'username')));
            }),
            _buildBottomNavItem(Icons.settings, () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            }),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  void _navigateToQuestionsReview(BuildContext context, QuizHistory history) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => QuestionsReviewScreen(history: history),
    ));
  }

  Widget _buildBottomNavItem(IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionsReviewScreen extends StatelessWidget {
  final QuizHistory history;

  const QuestionsReviewScreen({Key? key, required this.history})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions Review',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(
            color: Colors.white), // Ensuring the back button is white
      ),
      body: ListView.builder(
        itemCount: history.questions.length,
        itemBuilder: (context, index) {
          Question question = history.questions[index];
          String selectedAnswer =
              question.selectedAnswer ?? 'No answer selected';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(question.text),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Your Answer: $selectedAnswer'),
                    Text('Correct Answer: ${question.correctAnswer}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
