import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'user_model.dart';

class FileStorage {
  static Future<File> _getUserFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/users.json');
  }

  static Future<List<User>> readUsers() async {
    try {
      final file = await _getUserFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        return jsonList.map((json) => User.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<void> writeUsers(List<User> users) async {
    final file = await _getUserFile();
    final jsonList = users.map((user) => user.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }
}
