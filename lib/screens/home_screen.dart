import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'categories_screen.dart';
import 'highscores_screen.dart';
import 'leaderboard_screen.dart';
import 'quiz_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        username = user.displayName ?? user.email ?? '';
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        username = prefs.getString('username') ?? '';
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
        actions: [
          GestureDetector(
            onTap: () =>
                _navigateTo(context, ProfileScreen(username: username)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  username,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Container(
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
                  'Welcome, $username!',
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
                      onPressed: () => _navigateTo(context, const QuizScreen()),
                    ),
                    _buildHomeButton(
                      title: 'Categories',
                      icon: Icons.category,
                      backgroundColor: Colors.orangeAccent,
                      onPressed: () => _navigateTo(context, CategoriesScreen()),
                    ),
                    _buildHomeButton(
                      title: 'Highscores',
                      icon: Icons.star,
                      backgroundColor: Colors.green,
                      onPressed: () =>
                          _navigateTo(context, const HighscoresScreen()),
                    ),
                    _buildHomeButton(
                      title: 'Leaderboard',
                      icon: Icons.leaderboard,
                      backgroundColor: const Color.fromARGB(255, 0, 140, 255),
                      onPressed: () =>
                          _navigateTo(context, const LeaderboardScreen()),
                    ),
                    _buildHomeButton(
                      title: 'Profile',
                      icon: Icons.person,
                      backgroundColor: Colors.purple,
                      onPressed: () => _navigateTo(
                          context, ProfileScreen(username: username)),
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
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 40, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username,
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
            _buildDrawerItem(context, 'Profile', Icons.person,
                () => _navigateTo(context, ProfileScreen(username: username))),
            _buildDrawerItem(context, 'Settings', Icons.settings,
                () => _navigateTo(context, const SettingsScreen())),
            const Divider(color: Colors.white),
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

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
