import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _suggestUsername;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_checkUsernameAvailability);
    _emailController.addListener(_checkEmailAvailability);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _checkUsernameAvailability() async {
    String enteredUsername = _usernameController.text.trim().toLowerCase();
    if (enteredUsername.isNotEmpty) {
      bool usernameExists = await _isUsernameTaken(enteredUsername);
      if (usernameExists) {
        _suggestUsername = _generateSuggestedUsername(enteredUsername) as String?;
      } else {
        _suggestUsername = null;
      }
      setState(() {});
    }
  }

  void _checkEmailAvailability() async {
    String enteredEmail = _emailController.text.trim().toLowerCase();
    if (enteredEmail.isNotEmpty && !enteredEmail.contains('@')) return;
    bool emailExists = await _isEmailTaken(enteredEmail);
    if (emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email already in use. Please use a different one.'),
      ));
    }
  }

  Future<bool> _isUsernameTaken(String username) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<bool> _isEmailTaken(String email) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<String> _generateSuggestedUsername(String baseUsername) async {
    String suggestedUsername = baseUsername;
    int suffix = 1;
    while (await _suggestUsernameExists(suggestedUsername)) {
      suffix++;
      suggestedUsername = '$baseUsername$suffix';
    }
    return suggestedUsername;
  }

  Future<bool> _suggestUsernameExists(String username) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final userModel = await UserModel.signUp(
        username: _suggestUsername ?? _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (userModel != null) {
        _showSuccessDialog(userModel);
      } else {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'User registration failed. Please try again.',
        );
      }
    } catch (e) {
      _showErrorDialog(_getErrorMessage(e));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'The email address is already in use by another account.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'operation-not-allowed':
          return 'Operation not allowed. Please contact support.';
        case 'weak-password':
          return 'The password provided is too weak.';
        default:
          return 'Registration failed: ${error.message}';
      }
    } else {
      return 'Registration failed: ${error.toString()}';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Up Failed'),
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

  void _showSuccessDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Up Successful'),
          content: Text('Your account has been created successfully.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen(user: user)),
                );
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
          'Sign Up',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  'Create a New Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _dateOfBirthController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth (YYYY-MM-DD)',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _dateOfBirthController.text =
                            '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your date of birth';
                    }
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                      return 'Invalid date format (YYYY-MM-DD)';
                    }
                    DateTime currentDate = DateTime.now();
                    DateTime? selectedDate = _selectedDate;
                    if (selectedDate != null &&
                        selectedDate.isAfter(
                            currentDate.subtract(Duration(days: 6570)))) {
                      return 'Must be 18 years or older';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signUp,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
