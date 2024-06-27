import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_app_enrichment/models/user_model.dart';
import 'package:quiz_app_enrichment/screens/categories_screen.dart';
import 'package:quiz_app_enrichment/screens/highscores_screen.dart';
import 'package:quiz_app_enrichment/screens/home_screen.dart';
import 'package:quiz_app_enrichment/screens/profile_screen.dart';
import 'package:quiz_app_enrichment/screens/quiz_history_screen.dart';
import 'package:quiz_app_enrichment/screens/settings_screen.dart';

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
    // Fetch all users
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    final List<Map<String, dynamic>> leaderboard = [];

    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      final userData = userDoc.data();
      final username = userData['username'] ?? '';

      // Calculate total score from quiz history for the user
      final quizHistorySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .get();

      int totalScore = 0;

      quizHistorySnapshot.docs.forEach((historyDoc) {
        final data = historyDoc.data();
        totalScore += (data['score'] ?? 0) as int;
      });

      // Calculate accuracy from users collection
      final accuracy = userData['overallAccuracy'] ?? '0.00';

      leaderboard.add({
        'userId': userId,
        'name': username,
        'score': totalScore,
        'accuracy': accuracy,
      });
    }

    // Sort leaderboard by score (descending)
    leaderboard.sort((a, b) => b['score'].compareTo(a['score']));

    return leaderboard.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: TextStyle(color: Colors.white),
        ),
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
                final rank = index + 1;
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
            _buildBottomNavItem(Icons.home, () => _navigateToHome(context)),
            _buildBottomNavItem(
                Icons.category, () => _navigateToCategories(context)),
            _buildBottomNavItem(
                Icons.star, () => _navigateToHighscores(context)),
            _buildBottomNavItem(
                Icons.history, () => _navigateToHistory(context)),
            _buildBottomNavItem(
                Icons.person, () => _navigateToProfile(context)),
            _buildBottomNavItem(
                Icons.settings, () => _navigateToSettings(context)),
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
              color: Colors.deepPurple,
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

  Widget _buildBottomNavItem(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onPressed,
    );
  }

  void _navigateToHome(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
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
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen(user: userModel)));
    }
  }

  void _navigateToCategories(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CategoriesScreen()));
  }

  void _navigateToHighscores(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HighscoresScreen()));
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => QuizHistoryScreen()));
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ProfileScreen(username: username)));
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SettingsScreen()));
  }
}
