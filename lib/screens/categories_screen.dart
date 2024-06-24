import 'package:flutter/material.dart';
import 'package:quiz_app_enrichment/screens/login_screen.dart';
import 'package:quiz_app_enrichment/screens/quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'highscores_screen.dart';
import 'leaderboard_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String username = "";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        actions: [
          GestureDetector(
            onTap: () => _navigateToProfile(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildCategoryButton(
                      title: 'Science',
                      icon: Icons.science,
                      backgroundColor: Colors.deepPurpleAccent,
                      apiUrl:
                          'https://opentdb.com/api.php?amount=20&category=17',
                    ),
                    _buildCategoryButton(
                      title: 'History',
                      icon: Icons.history,
                      backgroundColor: Colors.orangeAccent,
                      apiUrl:
                          'https://opentdb.com/api.php?amount=20&category=23',
                    ),
                    _buildCategoryButton(
                      title: 'Computer',
                      icon: Icons.computer,
                      backgroundColor: Colors.lightBlueAccent,
                      apiUrl:
                          'https://opentdb.com/api.php?amount=20&category=18',
                    ),
                    _buildCategoryButton(
                      title: 'Sports',
                      icon: Icons.sports,
                      backgroundColor: Colors.green,
                      apiUrl:
                          'https://opentdb.com/api.php?amount=20&category=21&type=multiple',
                    ),
                    _buildCategoryButton(
                      title: 'Geography',
                      icon: Icons.map,
                      backgroundColor: const Color.fromARGB(255, 0, 140, 255),
                      apiUrl:
                          'https://opentdb.com/api.php?amount=20&category=22&type=multiple',
                    ),
                    _buildCategoryButton(
                      title: 'Art',
                      icon: Icons.brush,
                      backgroundColor: Colors.purple,
                      apiUrl:
                          'https://opentdb.com/api.php?amount=20&category=25&type=multiple',
                    ),
                    _buildCategoryButton(
                      title: 'Anime and Manga',
                      icon: Icons.animation,
                      backgroundColor: Colors.redAccent,
                      apiUrl:
                          'https://opentdb.com/api.php?amount=20&category=31&type=multiple',
                    ),
                    _buildCategoryButton(
                      title: 'Random/Others',
                      icon: Icons.miscellaneous_services,
                      backgroundColor: Colors.grey,
                      apiUrl: 'https://opentdb.com/api.php?amount=20',
                    ),
                  ],
                ),
              ],
            ),
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
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.star, color: Colors.white),
              onPressed: () {
                _navigateTo(context, HighscoresScreen());
              },
            ),
            IconButton(
              icon: Icon(Icons.leaderboard, color: Colors.white),
              onPressed: () {
                _navigateTo(context, LeaderboardScreen());
              },
            ),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                _navigateTo(context, SettingsScreen());
              },
            ),
            IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                            username: 'username',
                          )));
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required String apiUrl,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuizScreen(apiUrl: apiUrl)),
          );
        },
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

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(username: username),
      ),
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
