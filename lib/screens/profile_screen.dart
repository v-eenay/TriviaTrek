import 'package:flutter/material.dart';
import 'package:quiz_app_enrichment/screens/categories_screen.dart';
import 'package:quiz_app_enrichment/screens/highscores_screen.dart';
import 'package:quiz_app_enrichment/screens/leaderboard_screen.dart';
import 'settings_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserStats> _userStatsFuture;

  @override
  void initState() {
    super.initState();
    _userStatsFuture = _fetchUserStats();
  }

  Future<UserStats> _fetchUserStats() async {
    // Replace with actual implementation to fetch user stats
    // For demo, using dummy data
    await Future.delayed(Duration(seconds: 2)); // Simulating delay
    return UserStats(
      totalQuizzes: 10,
      averageScore: 85,
      highScore: 95,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 16),
              Text(
                widget.username,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Statistics:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<UserStats>(
                future: _userStatsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final stats = snapshot.data!;
                    return Column(
                      children: [
                        _buildStatItem(
                            'Total Quizzes', stats.totalQuizzes.toString()),
                        _buildStatItem(
                            'Average Score', '${stats.averageScore}%'),
                        _buildStatItem('High Score', '${stats.highScore}%'),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Handle edit profile button click
                },
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            IconButton(
              icon: const Icon(Icons.category, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => CategoriesScreen()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.star, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HighscoresScreen()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.leaderboard, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => LeaderboardScreen()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.deepPurple,
      child: Text(
        widget.username.isNotEmpty ? widget.username[0].toUpperCase() : 'U',
        style: const TextStyle(
            fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }
}

class UserStats {
  final int totalQuizzes;
  final int averageScore;
  final int highScore;

  UserStats({
    required this.totalQuizzes,
    required this.averageScore,
    required this.highScore,
  });
}
