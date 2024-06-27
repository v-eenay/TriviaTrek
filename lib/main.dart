import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'models/user_model.dart';

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
