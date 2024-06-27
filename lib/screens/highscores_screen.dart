import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app_enrichment/models/user_model.dart';
import 'package:quiz_app_enrichment/screens/categories_screen.dart';
import 'package:quiz_app_enrichment/screens/home_screen.dart';
import 'package:quiz_app_enrichment/screens/leaderboard_screen.dart';
import 'package:quiz_app_enrichment/screens/profile_screen.dart';
import 'package:quiz_app_enrichment/screens/settings_screen.dart';

class HighscoresScreen extends StatefulWidget {
  const HighscoresScreen({Key? key}) : super(key: key);

  @override
  _HighscoresScreenState createState() => _HighscoresScreenState();
}

class _HighscoresScreenState extends State<HighscoresScreen> {
  String username = '';
  List<Map<String, dynamic>> highscores = [];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadHighscores();
  }

  Future<void> _loadUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        username = snapshot.data()?['name'] ?? '';
      });
    }
  }

  Future<void> _loadHighscores() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('quiz_history')
              .orderBy('score', descending: true)
              .limit(10)
              .get();
      setState(() {
        highscores = querySnapshot.docs.map((doc) {
          final score = doc['score'] as int;
          final accuracy = double.parse(doc['accuracy'] as String);
          return {
            'score': score,
            'accuracy': accuracy.toStringAsFixed(2),
          };
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Highscores'),
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
      body: highscores.isEmpty
          ? Center(
              child: Text(
                'No highscores to display.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: highscores.length,
                itemBuilder: (context, index) {
                  final entry = highscores[index];
                  final rank = index + 1;
                  final score = entry['score'];
                  final accuracy = entry['accuracy'];
                  return _buildHighscoreItem(rank, score, accuracy);
                },
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(Icons.home, 'Home', () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => HomeScreen(
                      user: UserModel(
                          userId: '',
                          username: '',
                          email: '',
                          name: '',
                          dateOfBirth: '',
                          address: ''))));
            }),
            _buildBottomNavItem(Icons.category, 'Categories', () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => CategoriesScreen()));
            }),
            _buildBottomNavItem(Icons.leaderboard, 'Leaderboard', () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LeaderboardScreen()));
            }),
            _buildBottomNavItem(Icons.settings, 'Settings', () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            }),
            _buildBottomNavItem(Icons.person, 'Profile', () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ProfileScreen(username: username)));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHighscoreItem(int rank, int score, String accuracy) {
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
