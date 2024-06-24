import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quiz_app_enrichment/screens/categories_screen.dart';
import 'package:quiz_app_enrichment/screens/home_screen.dart';
import 'package:quiz_app_enrichment/screens/leaderboard_screen.dart';
import 'package:quiz_app_enrichment/screens/profile_screen.dart';
import 'package:quiz_app_enrichment/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  Future<void> _loadHighscores() async {
    final prefs = await SharedPreferences.getInstance();
    final highscoresJson = prefs.getStringList('highscores');
    if (highscoresJson != null) {
      setState(() {
        highscores = highscoresJson
            .map((entry) => Map<String, dynamic>.from(jsonDecode(entry)))
            .toList();
      });
    }
  }

  Future<void> _saveHighscores() async {
    final prefs = await SharedPreferences.getInstance();
    final highscoresJson = highscores.map((entry) => entry.toString()).toList();
    await prefs.setStringList('highscores', highscoresJson);
  }

  void _addHighscore(String name, int score) {
    setState(() {
      highscores.add({'name': name, 'score': score});
      highscores.sort((a, b) => b['score'].compareTo(a['score']));
    });
    _saveHighscores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Highscores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                username,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: highscores.length,
                itemBuilder: (context, index) {
                  final entry = highscores[index];
                  final name = entry['name'];
                  final score = entry['score'];
                  return _buildHighscoreItem(name, score);
                },
              ),
            ),
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
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
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

  Widget _buildHighscoreItem(String name, int score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue[100],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Score: $score',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
