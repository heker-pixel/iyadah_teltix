import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _username;
  String? _userLevel;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get username => _username;
  String? get userLevel => _userLevel;

  AppProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userEmail = prefs.getString('userEmail');
      _username = prefs.getString('username');
      _userLevel = prefs.getString('userLevel');
      notifyListeners();
    } catch (e) {
      // Handle error, e.g., log the error or show a message to the user
      print('Error loading from prefs: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', _isLoggedIn);
      await prefs.setString('userEmail', _userEmail ?? '');
      await prefs.setString('username', _username ?? '');
      await prefs.setString('userLevel', _userLevel ?? '');
    } catch (e) {
      // Handle error, e.g., log the error or show a message to the user
      print('Error saving to prefs: $e');
    }
  }

  Future<void> login(String email, String username, String userLevel) async {
    _isLoggedIn = true;
    _userEmail = email;
    _username = username;
    _userLevel = userLevel;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userEmail = null;
    _username = null;
    _userLevel = null;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateUsername(String newUsername) async {
    _username = newUsername;
    await _saveToPrefs();
    notifyListeners();
  }
}
