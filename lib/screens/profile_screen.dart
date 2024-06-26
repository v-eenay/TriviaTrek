import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app_enrichment/screens/categories_screen.dart';
import 'package:quiz_app_enrichment/screens/highscores_screen.dart';
import 'package:quiz_app_enrichment/screens/leaderboard_screen.dart';
import 'package:quiz_app_enrichment/screens/quiz_history_screen.dart';
import 'package:quiz_app_enrichment/screens/settings_screen.dart';
import 'package:quiz_app_enrichment/screens/home_screen.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _name;
  late String _email;
  late String _address;
  late int _totalQuizzes;
  late int _totalScore;
  late double _averageScore;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _name = '';
    _email = '';
    _address = '';
    _totalQuizzes = 0;
    _totalScore = 0;
    _averageScore = 0.0;

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userData.exists) {
          final data = userData.data() as Map<String, dynamic>;
          setState(() {
            _name = data['name'] ?? '';
            _email = data['email'] ?? '';
            _address = data['address'] ?? '';
          });

          final quizHistorySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('quiz_history')
              .get();

          int totalScore = 0;
          int totalQuizzes = quizHistorySnapshot.docs.length;

          for (var doc in quizHistorySnapshot.docs) {
            totalScore += (doc['score'] ?? 0) as int;
          }

          double averageScore =
              totalQuizzes > 0 ? totalScore / totalQuizzes : 0.0;

          setState(() {
            _totalQuizzes = totalQuizzes;
            _totalScore = totalScore;
            _averageScore = averageScore;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  _buildProfileInfo(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _name,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '@${widget.username}',
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileInfoItem(Icons.email, 'Email', _email),
        _buildProfileInfoItem(Icons.home, 'Address', _address),
        _buildProfileInfoItem(
            Icons.quiz, 'Total Quizzes Taken', _totalQuizzes.toString()),
        _buildProfileInfoItem(
            Icons.score, 'Total Score', _totalScore.toString()),
        _buildProfileInfoItem(
            Icons.equalizer, 'Average Score', _averageScore.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildProfileInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
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
          _buildBottomNavItem(Icons.history, () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => QuizHistoryScreen()));
          }),
          _buildBottomNavItem(Icons.settings, () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SettingsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
