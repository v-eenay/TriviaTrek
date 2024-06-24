import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _login() async {
    final usernameOrEmail = _usernameOrEmailController.text.trim();
    final password = _passwordController.text;

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      // Check if input is an email or username
      if (usernameOrEmail.contains('@')) {
        querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: usernameOrEmail)
            .limit(1)
            .get();
      } else {
        querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: usernameOrEmail)
            .limit(1)
            .get();
      }

      if (querySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found with this username or email.');
      }

      String email = querySnapshot.docs.first.get('email');

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      final user = userCredential.user;

      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        throw FirebaseAuthException(
            code: 'unknown-error', message: 'An unknown error occurred.');
      }
    } catch (e) {
      _showErrorDialog(_getErrorMessage(e));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'user-not-found':
          return 'No user found with this username or email.';
        case 'wrong-password':
          return 'Incorrect password.';
        default:
          return 'An unknown error occurred. Please try again later.';
      }
    } else {
      return 'An unknown error occurred. Please try again later.';
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

  Future<void> _resetPassword() async {
    final usernameOrEmail = _usernameOrEmailController.text.trim();

    if (usernameOrEmail.isEmpty) {
      _showErrorDialog('Please enter your username or email.');
      return;
    }

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      // Check if input is an email or username
      if (usernameOrEmail.contains('@')) {
        querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: usernameOrEmail)
            .limit(1)
            .get();
      } else {
        querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: usernameOrEmail)
            .limit(1)
            .get();
      }

      if (querySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found with this username or email.');
      }

      String email = querySnapshot.docs.first.get('email');

      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent to $email.')));
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _usernameOrEmailController,
                decoration: InputDecoration(
                  labelText: 'Enter your username or email',
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: Text('Reset'),
                    onPressed: () {
                      _resetPassword();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _usernameOrEmailController,
                decoration: InputDecoration(labelText: 'Username or Email'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              TextButton(
                onPressed: _showResetPasswordDialog,
                child: Text('Forgot Password?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
