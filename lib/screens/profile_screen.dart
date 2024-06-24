import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _name;
  late String _username;
  late String _email;
  late String _dob;
  late String _address;
  late int _totalQuizzes;
  late int _totalScore;
  late double _averageScore;

  @override
  void initState() {
    super.initState();
    _name = '';
    _username = widget.username;
    _email = '';
    _dob = '';
    _address = '';
    _totalQuizzes = 0;
    _totalScore = 0;
    _averageScore = 0.0;

    // Fetch user data from Firestore
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Fetch user profile data
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.username)
          .get();

      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;
        setState(() {
          _name = data['name'] ?? '';
          _email = data['email'] ?? '';
          _dob = data['dob'] ?? '';
          _address = data['address'] ?? '';
        });

        // Fetch user's quiz history
        final quizHistorySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.username)
            .collection('quiz_history')
            .get();

        int totalScore = 0;
        int totalQuizzes = quizHistorySnapshot.docs.length;

        quizHistorySnapshot.docs.forEach((doc) {
          totalScore += (doc['score'] ?? 0) as int;
        });

        double averageScore =
            totalQuizzes > 0 ? totalScore / totalQuizzes : 0.0;

        setState(() {
          _totalQuizzes = totalQuizzes;
          _totalScore = totalScore;
          _averageScore = averageScore;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Text(
                _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '@$_username',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _buildProfileInfoItem('Email', _email),
            _buildProfileInfoItem('Date of Birth', _dob),
            _buildProfileInfoItem('Address', _address),
            _buildProfileInfoItem('Total Quizzes', _totalQuizzes.toString()),
            _buildProfileInfoItem('Total Score', _totalScore.toString()),
            _buildProfileInfoItem(
                'Average Score', _averageScore.toStringAsFixed(2)),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            IconButton(
              icon: Icon(Icons.category, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(Icons.star, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(Icons.leaderboard, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
