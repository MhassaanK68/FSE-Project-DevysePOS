import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  static const String _keyRememberMe = 'remember_me';
  static const String _keySavedUser = 'saved_user';

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  bool get isAdmin => _currentUser?.role == UserRole.admin;

  bool get isCashier => _currentUser?.role == UserRole.cashier;

  String get displayName => _currentUser?.displayName ?? '';

  UserRole? get role => _currentUser?.role;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

      if (rememberMe) {
        final savedUserJson = prefs.getString(_keySavedUser);
        if (savedUserJson != null && savedUserJson.isNotEmpty) {
          try {
            final userMap = jsonDecode(savedUserJson) as Map<String, dynamic>;
            _currentUser = User.fromJson(userMap);
            notifyListeners();
          } catch (e) {
            debugPrint('Failed to parse saved user: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to restore user session: $e');
    }
  }

  Future<void> login(User user, {bool rememberMe = false}) async {
    _currentUser = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, rememberMe);

    if (rememberMe) {
      await prefs.setString(_keySavedUser, jsonEncode(user.toJson()));
    } else {
      await prefs.remove(_keySavedUser);
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, false);
    await prefs.remove(_keySavedUser);

    notifyListeners();
  }
}
