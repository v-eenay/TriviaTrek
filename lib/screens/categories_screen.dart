import 'package:flutter/material.dart';
import 'package:quiz_app_enrichment/models/user_model.dart';
import 'package:quiz_app_enrichment/screens/quiz_history_screen.dart';
import 'package:quiz_app_enrichment/screens/quiz_screen.dart';
import 'package:quiz_app_enrichment/screens/home_screen.dart';
import 'package:quiz_app_enrichment/screens/profile_screen.dart';
import 'package:quiz_app_enrichment/screens/settings_screen.dart';
import 'package:quiz_app_enrichment/screens/highscores_screen.dart';
import 'package:quiz_app_enrichment/screens/leaderboard_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late UserModel currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    UserModel? user = await UserModel.getUserFromLocal();
    if (user != null) {
      setState(() {
        currentUser = user;
      });
    } else {
      // Handle user not found scenario, maybe redirect to login or sign-up
      print('User data not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories',
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          _buildProfileButton(),
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
                      category: '17',
                    ),
                    _buildCategoryButton(
                      title: 'History',
                      icon: Icons.history,
                      backgroundColor: Colors.orangeAccent,
                      category: '23',
                    ),
                    _buildCategoryButton(
                      title: 'Computer',
                      icon: Icons.computer,
                      backgroundColor: Colors.lightBlueAccent,
                      category: '18',
                    ),
                    _buildCategoryButton(
                      title: 'Sports',
                      icon: Icons.sports,
                      backgroundColor: Colors.green,
                      category: '21',
                    ),
                    _buildCategoryButton(
                      title: 'Geography',
                      icon: Icons.map,
                      backgroundColor: const Color.fromARGB(255, 0, 140, 255),
                      category: '22',
                    ),
                    _buildCategoryButton(
                      title: 'Art',
                      icon: Icons.brush,
                      backgroundColor: Colors.purple,
                      category: '25',
                    ),
                    _buildCategoryButton(
                      title: 'Anime and Manga',
                      icon: Icons.animation,
                      backgroundColor: Colors.redAccent,
                      category: '31',
                    ),
                    _buildCategoryButton(
                      title: 'Random/Others',
                      icon: Icons.miscellaneous_services,
                      backgroundColor: Colors.grey,
                      category: '',
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
            _buildBottomNavItem(Icons.home, 'Home', () {
              _navigateToReplacement(context, HomeScreen(user: currentUser));
            }),
            _buildBottomNavItem(Icons.star, 'Highscores', () {
              _navigateTo(context, HighscoresScreen());
            }),
            _buildBottomNavItem(Icons.leaderboard, 'Leaderboard', () {
              _navigateTo(context, LeaderboardScreen());
            }),
            _buildBottomNavItem(Icons.history, 'History', () {
              _navigateToReplacement(context, QuizHistoryScreen());
            }),
            _buildBottomNavItem(Icons.person, 'Profile', () {
              _navigateToReplacement(
                  context, ProfileScreen(username: currentUser.username));
            }),
            _buildBottomNavItem(Icons.settings, 'Settings', () {
              _navigateTo(context, SettingsScreen());
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
    required String category,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (category.isNotEmpty) {
            _navigateToQuizOptions(context, category);
          } else {
            _navigateToRandomQuiz(context);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
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

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: () {
        _navigateToReplacement(
            context, ProfileScreen(username: currentUser.name));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                currentUser.name.isNotEmpty
                    ? currentUser.name[0].toUpperCase()
                    : '',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currentUser.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
      IconData icon, String label, void Function() onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onTap,
      tooltip: label,
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _navigateToReplacement(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _navigateToQuizOptions(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizOptionsScreen(category: category),
      ),
    );
  }

  void _navigateToRandomQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuizScreen(apiUrl: 'https://opentdb.com/api.php?amount=20'),
      ),
    );
  }
}

class QuizOptionsScreen extends StatefulWidget {
  final String category;

  const QuizOptionsScreen({Key? key, required this.category}) : super(key: key);

  @override
  _QuizOptionsScreenState createState() => _QuizOptionsScreenState();
}

class _QuizOptionsScreenState extends State<QuizOptionsScreen> {
  int selectedQuestionCount = 10;
  String? selectedDifficulty; // Changed to nullable for dropdown selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz Options',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Number of Questions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildQuestionCountInput(),
            SizedBox(height: 16),
            Text(
              'Select Difficulty:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildDifficultySelector(),
            Spacer(),
            _buildStartQuizButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCountInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter number of questions',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
          prefixIcon: Icon(Icons.format_list_numbered),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            setState(() {
              selectedQuestionCount = int.parse(value);
            });
          } else {
            setState(() {
              selectedQuestionCount = 1; // Default value
            });
          }
        },
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedDifficulty,
        onChanged: (value) {
          setState(() {
            selectedDifficulty = value!;
          });
        },
        items: ['easy', 'medium', 'hard', 'random']
            .map((value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
            .toList(),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _startQuiz() {
    String apiUrl =
        'https://opentdb.com/api.php?amount=$selectedQuestionCount&category=${widget.category}';

    if (selectedDifficulty != null && selectedDifficulty != 'random') {
      apiUrl += '&difficulty=$selectedDifficulty';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(apiUrl: apiUrl),
      ),
    );
  }

  Widget _buildStartQuizButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startQuiz,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Start Quiz',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
