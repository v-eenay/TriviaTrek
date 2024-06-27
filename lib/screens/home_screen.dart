import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app_enrichment/models/user_model.dart';
import 'package:quiz_app_enrichment/screens/categories_screen.dart';
import 'package:quiz_app_enrichment/screens/profile_screen.dart';
import 'package:quiz_app_enrichment/screens/settings_screen.dart';
import 'package:quiz_app_enrichment/screens/highscores_screen.dart';
import 'package:quiz_app_enrichment/screens/leaderboard_screen.dart';
import 'package:quiz_app_enrichment/screens/quiz_screen.dart';
import 'package:quiz_app_enrichment/screens/login_screen.dart';
import 'package:quiz_app_enrichment/screens/quiz_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String fullName;
  String profilePicture = ''; // Initialize profilePicture here
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fullName = widget.user.name;
    // Initialize profilePicture with first initial of name if name is not empty
    if (fullName.isNotEmpty) {
      profilePicture = fullName[0]
          .toUpperCase(); // Assuming first character as profile picture
    }
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
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
                      backgroundColor:
                          Colors.white, // Provide a background color
                      child: Text(
                        profilePicture,
                        style: const TextStyle(fontSize: 24),
                      ),
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
                            gradientColors: [
                              Colors.deepPurpleAccent,
                              Colors.deepPurple
                            ],
                            onPressed: () => _startQuiz(context,
                                'https://opentdb.com/api.php?amount=20'),
                          ),
                          _buildHomeButton(
                            title: 'Categories',
                            icon: Icons.category,
                            gradientColors: [
                              Colors.orangeAccent,
                              Colors.orange
                            ],
                            onPressed: () =>
                                _navigateTo(context, CategoriesScreen()),
                          ),
                          _buildHomeButton(
                            title: 'Highscores',
                            icon: Icons.star,
                            gradientColors: [Colors.greenAccent, Colors.green],
                            onPressed: () =>
                                _navigateTo(context, const HighscoresScreen()),
                          ),
                          _buildHomeButton(
                            title: 'Leaderboard',
                            icon: Icons.leaderboard,
                            gradientColors: [
                              Color.fromARGB(255, 0, 140, 255),
                              Color.fromARGB(255, 0, 120, 255)
                            ],
                            onPressed: () =>
                                _navigateTo(context, const LeaderboardScreen()),
                          ),
                          _buildHomeButton(
                            title: 'Quiz History',
                            icon: Icons.history,
                            gradientColors: [Colors.deepOrange, Colors.orange],
                            onPressed: () =>
                                _navigateTo(context, const QuizHistoryScreen()),
                          ),
                          _buildHomeButton(
                            title: 'Profile',
                            icon: Icons.person,
                            gradientColors: [
                              Colors.purple,
                              Colors.purpleAccent
                            ],
                            onPressed: () => _navigateTo(
                                context, ProfileScreen(username: fullName)),
                          ),
                          _buildHomeButton(
                            title: 'Settings',
                            icon: Icons.settings,
                            gradientColors: [Colors.blue, Colors.blueAccent],
                            onPressed: () =>
                                _navigateTo(context, SettingsScreen()),
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
                    backgroundColor: Colors.white, // Provide a background color
                    child: Text(
                      profilePicture,
                      style: const TextStyle(fontSize: 40),
                    ),
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
                () => _navigateTo(context, SettingsScreen())),
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
    required List<Color> gradientColors,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
    // Clear local storage (cache)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) => LoginScreen(onSignUp: (username, email,
                  password, name, dateOfBirth, address) async {
                try {
                  UserModel? newUser = await UserModel.signUp(
                    username: username,
                    email: email,
                    password: password,
                    name: name,
                    dateOfBirth: dateOfBirth,
                    address: address,
                  );
                  if (newUser != null) {
                    setState(() {
                      fullName = newUser.name;
                      profilePicture = newUser.profilePicture;
                    });
                  }
                } catch (e) {
                  // Handle sign-up errors here
                  print('Sign-up error: $e');
                }
              })),
      (Route<dynamic> route) => false,
    );
  }
}
