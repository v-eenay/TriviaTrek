import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // Web-specific initialization
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: html.window.localStorage['API_KEY'] ?? '',
          authDomain: html.window.localStorage['AUTH_DOMAIN'] ?? '',
          projectId: html.window.localStorage['PROJECT_ID'] ?? '',
          storageBucket: html.window.localStorage['STORAGE_BUCKET'] ?? '',
          messagingSenderId:
              html.window.localStorage['MESSAGING_SENDER_ID'] ?? '',
          appId: html.window.localStorage['APP_ID'] ?? '',
          measurementId: html.window.localStorage['MEASUREMENT_ID'] ?? '',
        ),
      );
    } else {
      // Non-web initialization
      await dotenv.load(fileName: ".env");
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: dotenv.env['API_KEY']!,
          authDomain: dotenv.env['AUTH_DOMAIN']!,
          projectId: dotenv.env['PROJECT_ID']!,
          storageBucket: dotenv.env['STORAGE_BUCKET']!,
          messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
          appId: dotenv.env['APP_ID']!,
          measurementId: dotenv.env['MEASUREMENT_ID']!,
        ),
      );
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({Key? key}) : super(key: key);

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

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  late Future<UserModel?> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = UserModel.getUserFromLocal();
  }

  Future<void> _logout(BuildContext context) async {
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
                      _futureUser = Future.value(newUser);
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _futureUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(user: snapshot.data!);
        } else {
          return LoginScreen(
            onSignUp:
                (username, email, password, name, dateOfBirth, address) async {
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
                    _futureUser = Future.value(newUser);
                  });
                }
              } catch (e) {
                // Handle sign-up errors here
                print('Sign-up error: $e');
              }
            },
          );
        }
      },
    );
  }
}
