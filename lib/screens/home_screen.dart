import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app_enrichment/screens/categories_screen.dart';
import 'package:quiz_app_enrichment/screens/profile_screen.dart';
import 'package:quiz_app_enrichment/screens/settings_screen.dart';
import 'package:quiz_app_enrichment/screens/highscores_screen.dart';
import 'package:quiz_app_enrichment/screens/leaderboard_screen.dart';
import 'package:quiz_app_enrichment/screens/quiz_screen.dart';
import 'package:quiz_app_enrichment/screens/login_screen.dart';
import 'package:quiz_app_enrichment/screens/quiz_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fullName = '';
  String profilePicture = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (snapshot.exists) {
          setState(() {
            fullName = snapshot.data()?['name'] ?? 'User';
            profilePicture = snapshot.data()?['profilePicture'] ?? '';
            isLoading = false;
          });
        } else {
          throw Exception('User data not found');
        }
      } catch (e) {
        print('Error loading user data: $e');
        setState(() {
          fullName = 'User';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        fullName = 'User';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: fullName.isNotEmpty
                  ? () =>
                      _navigateTo(context, ProfileScreen(username: fullName))
                  : null,
              child: Center(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: profilePicture.isNotEmpty
                          ? NetworkImage(profilePicture)
                          : null,
                      child: profilePicture.isEmpty
                          ? Text(
                              fullName.isNotEmpty ? fullName[0] : 'U',
                              style: const TextStyle(fontSize: 24),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fullName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $fullName!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildHomeButton(
                            title: 'Start Random Quiz',
                            icon: Icons.play_arrow,
                            backgroundColor: Colors.deepPurpleAccent,
                            onPressed: () => _startQuiz(context,
                                'https://opentdb.com/api.php?amount=20'),
                          ),
                          _buildHomeButton(
                            title: 'Categories',
                            icon: Icons.category,
                            backgroundColor: Colors.orangeAccent,
                            onPressed: () =>
                                _navigateTo(context, CategoriesScreen()),
                          ),
                          _buildHomeButton(
                            title: 'Highscores',
                            icon: Icons.star,
                            backgroundColor: Colors.green,
                            onPressed: () =>
                                _navigateTo(context, HighscoresScreen()),
                          ),
                          _buildHomeButton(
                            title: 'Leaderboard',
                            icon: Icons.leaderboard,
                            backgroundColor:
                                const Color.fromARGB(255, 0, 140, 255),
                            onPressed: () =>
                                _navigateTo(context, const LeaderboardScreen()),
                          ),
                          _buildHomeButton(
                            title: 'Quiz History',
                            icon: Icons.history,
                            backgroundColor: Colors.deepOrange,
                            onPressed: () =>
                                _navigateTo(context, const QuizHistoryScreen()),
                          ),
                          _buildHomeButton(
                            title: 'Profile',
                            icon: Icons.person,
                            backgroundColor: Colors.purple,
                            onPressed: () => _navigateTo(
                                context, ProfileScreen(username: fullName)),
                          ),
                          _buildHomeButton(
                            title: 'Settings',
                            icon: Icons.settings,
                            backgroundColor: Colors.blue,
                            onPressed: () =>
                                _navigateTo(context, const SettingsScreen()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepPurple,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: profilePicture.isNotEmpty
                        ? NetworkImage(profilePicture)
                        : null,
                    child: profilePicture.isEmpty
                        ? Text(
                            fullName.isNotEmpty ? fullName[0] : 'U',
                            style: const TextStyle(fontSize: 40),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
                context, 'Home', Icons.home, () => Navigator.pop(context)),
            _buildDrawerItem(context, 'Categories', Icons.category,
                () => _navigateTo(context, CategoriesScreen())),
            _buildDrawerItem(context, 'Highscores', Icons.star,
                () => _navigateTo(context, const HighscoresScreen())),
            _buildDrawerItem(context, 'Leaderboard', Icons.leaderboard,
                () => _navigateTo(context, const LeaderboardScreen())),
            _buildDrawerItem(context, 'Quiz History', Icons.history,
                () => _navigateTo(context, const QuizHistoryScreen())),
            _buildDrawerItem(context, 'Profile', Icons.person,
                () => _navigateTo(context, ProfileScreen(username: fullName))),
            const Divider(color: Colors.white),
            _buildDrawerItem(context, 'Settings', Icons.settings,
                () => _navigateTo(context, const SettingsScreen())),
            _buildDrawerItem(
                context, 'Logout', Icons.exit_to_app, () => _logout(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  Widget _buildHomeButton({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context, String apiUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => QuizScreen(
                apiUrl: apiUrl,
              )),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
