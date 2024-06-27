import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String userId;
  final String username;
  final String email;
  final String name;
  final String dateOfBirth;
  final String address;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.name,
    required this.dateOfBirth,
    required this.address,
  });

  String get profilePicture {
    if (name.isNotEmpty) {
      return name[0].toUpperCase();
    } else {
      return '';
    }
  }

  static Future<UserModel?> login(
      String usernameOrEmail, String password) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> querySnapshot;

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

    final userData = querySnapshot.docs.first.data();
    final email = userData['email'] as String;
    final name = userData['name'] as String;
    final dateOfBirth = userData['dateOfBirth'] as String;
    final address = userData['address'] as String;

    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    final user = userCredential.user;

    if (user != null) {
      final userModel = UserModel(
        userId: user.uid,
        username: usernameOrEmail,
        email: email,
        name: name,
        dateOfBirth: dateOfBirth,
        address: address,
      );
      await userModel.saveToLocal();
      return userModel;
    } else {
      throw FirebaseAuthException(
          code: 'unknown-error', message: 'An unknown error occurred.');
    }
  }

  static Future<UserModel?> signUp({
    required String username,
    required String email,
    required String password,
    required String name,
    required String dateOfBirth,
    required String address,
  }) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'userId': user.uid,
        'username': username,
        'email': email,
        'name': name,
        'dateOfBirth': dateOfBirth,
        'address': address,
      });

      final userModel = UserModel(
        userId: user.uid,
        username: username,
        email: email,
        name: name,
        dateOfBirth: dateOfBirth,
        address: address,
      );

      await userModel.saveToLocal(); // Cache user data locally
      return userModel;
    } else {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'User registration failed. Please try again.',
      );
    }
  }

  Future<void> saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('name', name);
    await prefs.setString('dateOfBirth', dateOfBirth);
    await prefs.setString('address', address);
  }

  static Future<UserModel?> getUserFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final username = prefs.getString('username');
    final email = prefs.getString('email');
    final name = prefs.getString('name');
    final dateOfBirth = prefs.getString('dateOfBirth');
    final address = prefs.getString('address');

    if (userId != null &&
        username != null &&
        email != null &&
        name != null &&
        dateOfBirth != null &&
        address != null) {
      return UserModel(
        userId: userId,
        username: username,
        email: email,
        name: name,
        dateOfBirth: dateOfBirth,
        address: address,
      );
    } else {
      return null;
    }
  }
}
