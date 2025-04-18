import 'dart:convert';

import 'package:fyp_wyc/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) {
      return null;
    }
    return User.fromJson(jsonDecode(userJson));
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }
}
