import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _name;
  late String _email;
  late String _dob;
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
    _dob = '';
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
            _dob = data['dob'] ?? '';
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
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
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
        gradient: LinearGradient(
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
      children: [
        _buildProfileInfoItem(Icons.email, 'Email', _email),
        _buildProfileInfoItem(Icons.cake, 'Date of Birth', _dob),
        _buildProfileInfoItem(Icons.home, 'Address', _address),
        _buildProfileInfoItem(
            Icons.quiz, 'Total Quizzes', _totalQuizzes.toString()),
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
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(Icons.home, 'Home', () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }),
          _buildBottomNavItem(Icons.category, 'Categories', () {
            Navigator.of(context).pop();
          }),
          _buildBottomNavItem(Icons.star, 'Favorites', () {
            Navigator.of(context).pop();
          }),
          _buildBottomNavItem(Icons.leaderboard, 'Leaderboard', () {
            Navigator.of(context).pop();
          }),
          _buildBottomNavItem(Icons.person, 'Profile', () {}),
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
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
