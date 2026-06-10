import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;

  Future<String?> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock logic: allow any login with a valid-looking email
    if (email.contains('@') && password.length >= 6) {
      _isAuthenticated = true;
      _userEmail = email;
      notifyListeners();
      return null; // Success
    } else {
      return 'Invalid email or password';
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock logic: allow any signup
    if (email.contains('@') && password.length >= 6 && name.isNotEmpty) {
      _isAuthenticated = true;
      _userEmail = email;
      notifyListeners();
      return null; // Success
    } else {
      return 'Registration failed. Please check your details.';
    }
  }

  void logout() {
    _isAuthenticated = false;
    _userEmail = null;
    notifyListeners();
  }
}
