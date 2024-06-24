import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _suggestUsername;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_checkUsernameAvailability);
    _emailController.addListener(_checkEmailAvailability);
  }

  void _checkUsernameAvailability() async {
    String enteredUsername = _usernameController.text.trim().toLowerCase();
    if (enteredUsername.isNotEmpty) {
      bool usernameExists = await _isUsernameTaken(enteredUsername);
      if (usernameExists) {
        _suggestUsername = _generateSuggestedUsername(enteredUsername);
      } else {
        _suggestUsername = null;
      }
      setState(() {}); // Update UI to show suggestion
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

  String _generateSuggestedUsername(String baseUsername) {
    String suggestedUsername = baseUsername;
    int suffix = 1;
    while (_suggestUsernameExists(suggestedUsername)) {
      suffix++;
      suggestedUsername = '$baseUsername$suffix';
    }
    return suggestedUsername;
  }

  bool _suggestUsernameExists(String username) {
    // Check if the suggested username exists in Firestore
    return false; // Implement your logic here
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        String username = _suggestUsername ?? _usernameController.text.trim();

        await _firestore.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'username': username,
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'dateOfBirth': _dateOfBirthController.text.trim(),
          'address': _addressController.text.trim(),
        });

        _showSuccessDialog();
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

  void _showSuccessDialog() {
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
                  MaterialPageRoute(builder: (context) => HomeScreen()),
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
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
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
                  decoration: InputDecoration(labelText: 'Email'),
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
                  decoration: InputDecoration(labelText: 'Password'),
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
                  decoration: InputDecoration(labelText: 'Full Name'),
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
                  decoration:
                      InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
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
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _signUp,
                    child: Text('Sign Up'),
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
