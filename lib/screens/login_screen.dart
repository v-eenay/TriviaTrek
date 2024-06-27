import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required Future<Null> Function(dynamic username, dynamic email, dynamic password, dynamic name, dynamic dateOfBirth, dynamic address) onSignUp}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _checkCachedUser();
  }

  Future<void> _checkCachedUser() async {
    final userModel = await UserModel.getUserFromLocal();
    if (userModel != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen(user: userModel)),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Future<void> _login() async {
    final usernameOrEmail = _usernameOrEmailController.text.trim();
    final password = _passwordController.text;

    try {
      final userModel = await UserModel.login(usernameOrEmail, password);

      if (userModel != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen(user: userModel)),
        );
      } else {
        throw FirebaseAuthException(
            code: 'unknown-error', message: 'An unknown error occurred.');
      }
    } catch (e) {
      String errorMessage = _getErrorMessage(e);
      _showErrorDialog(errorMessage);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
          return 'No user found with this username or email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        default:
          return 'An unexpected error occurred. Please try again later.';
      }
    } else {
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email.'),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      _showErrorDialog(_getErrorMessage(e));
    }
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Enter your email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Reset'),
              onPressed: () {
                final email = _emailController.text.trim();
                if (email.isNotEmpty) {
                  _resetPassword(email);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login to TriviaTrek',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        leading: SizedBox(
          width: kToolbarHeight,
          height: kToolbarHeight,
          child: Image.asset(
            'assets/app_icon.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                'Welcome to TriviaTrek!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameOrEmailController,
                decoration: InputDecoration(
                  labelText: 'Username or Email',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: _togglePasswordVisibility,
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: !_showPassword,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: _showResetPasswordDialog,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
