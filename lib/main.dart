import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCyfYaHkU9-trDt7pWBrI3vPvgLbl57AmQ",
      authDomain: "enrichmentquizapp.firebaseapp.com",
      projectId: "enrichmentquizapp",
      storageBucket: "enrichmentquizapp.appspot.com",
      messagingSenderId: "941720131416",
      appId: "1:941720131416:android:244ae946be78242c60772d",
      measurementId: "",
    ),
  );
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    const isSignedIn = false; // Change this to check if user is signed in
    return isSignedIn ? HomeScreen() : LoginScreen();
  }
}
