import 'package:flutter/material.dart';
import 'package:quiz_app_enrichment/screens/categories_screen.dart';
import 'package:quiz_app_enrichment/screens/highscores_screen.dart';
import 'package:quiz_app_enrichment/screens/profile_screen.dart';
import 'package:quiz_app_enrichment/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  Future<List<Map<String, dynamic>>> _fetchLeaderboard() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('quiz_history').get();
    final userScores = <String, int>{};
    final userQuestions = <String, int>{};
    final userCorrectAnswers = <String, int>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final user = data['user'];
      final score = data['score'] as int;
      final correctAnswers = data['correct_answers'] as int;
      final totalQuestions = data['total_questions'] as int;

      userScores[user] = (userScores[user] ?? 0) + score;
      userQuestions[user] = (userQuestions[user] ?? 0) + totalQuestions;
      userCorrectAnswers[user] =
          (userCorrectAnswers[user] ?? 0) + correctAnswers;
    }

    final leaderboard = userScores.keys.map((user) {
      final totalScore = userScores[user]!;
      final totalQuestions = userQuestions[user]!;
      final correctAnswers = userCorrectAnswers[user]!;
      final accuracy = totalQuestions > 0
          ? (correctAnswers / totalQuestions * 100).toStringAsFixed(2)
          : '0.00';

      return {
        'name': user,
        'score': totalScore,
        'accuracy': accuracy,
      };
    }).toList();

    leaderboard
        .sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    return leaderboard.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                username,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No leaderboard data available.'));
          } else {
            final leaderboard = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                final rank = index == 0
                    ? 1
                    : (leaderboard[index - 1]['score'] == entry['score']
                        ? leaderboard[index - 1]['rank']
                        : index + 1);
                entry['rank'] = rank;
                final name = entry['name'];
                final score = entry['score'];
                final accuracy = entry['accuracy'];
                return _buildLeaderboardItem(rank, name, score, accuracy);
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
            _buildBottomNavItem(Icons.home, 'Home', () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
            _buildBottomNavItem(Icons.category, 'Categories', () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => CategoriesScreen()));
            }),
            _buildBottomNavItem(Icons.star, 'Highscores', () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HighscoresScreen()));
            }),
            _buildBottomNavItem(Icons.settings, 'Settings', () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            }),
            _buildBottomNavItem(Icons.person, 'Profile', () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                        username: username,
                      )));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
      int rank, String name, int score, String accuracy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rank: $rank',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Name: $name',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Score: $score',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Accuracy: $accuracy%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
      IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
