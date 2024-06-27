import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app_enrichment/models/user_model.dart';
import 'package:quiz_app_enrichment/screens/categories_screen.dart';
import 'package:quiz_app_enrichment/screens/highscores_screen.dart';
import 'package:quiz_app_enrichment/screens/home_screen.dart';
import 'package:quiz_app_enrichment/screens/leaderboard_screen.dart';
import 'package:quiz_app_enrichment/screens/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            _buildSettingsItem(
              context,
              'Change Password',
              Icons.lock,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
              ),
            ),
            _buildSettingsItem(
              context,
              'Edit Profile',
              Icons.person,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              ),
            ),
            _buildSettingsItem(
              context,
              'Clear History',
              Icons.delete,
              () => _showClearHistoryDialog(context),
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
                  MaterialPageRoute(
                      builder: (context) => HomeScreen(
                          user: UserModel(
                              userId: '',
                              username: '',
                              email: '',
                              name: '',
                              dateOfBirth: '',
                              address: ''))),
                );
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
              icon: const Icon(Icons.star, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HighscoresScreen()));
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
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => ProfileScreen(username: 'username')));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, String title, IconData icon,
      VoidCallback onPressed) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onPressed,
    );
  }

  Future<void> _clearHistory(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final batch = FirebaseFirestore.instance.batch();
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('quiz_history')
            .get();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz history cleared successfully.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear history: $e')),
      );
    }
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content:
            const Text('This will clear all your quiz history. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearHistory(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _oldPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(labelText: 'Old Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _changePassword(context),
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          AuthCredential credential = EmailAuthProvider.credential(
              email: user.email!, password: _oldPasswordController.text);

          await user.reauthenticateWithCredential(credential);
          await user.updatePassword(_newPasswordController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully.')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change password: $e')),
        );
      }
    }
  }
}

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    UserModel? user = await UserModel.getUserFromLocal();
    if (user != null) {
      _nameController.text = user.name;
      _addressController.text = user.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _editProfile(context),
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Update Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'name': _nameController.text,
            'address': _addressController.text,
          });

          // Update local storage
          UserModel updatedUser = UserModel(
            userId: user.uid,
            username: '',
            email: '',
            name: _nameController.text,
            dateOfBirth: '',
            address: _addressController.text,
          );
          await updatedUser.saveToLocal();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully.')),
          );
          // Optionally, you can pop the context to return to the previous screen
          // Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }
}
