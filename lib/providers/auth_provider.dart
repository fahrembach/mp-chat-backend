import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _user = _authService.user;
    _token = _authService.token;
  }

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _authService.login(username, password);
    if (success) {
      _user = _authService.user;
      _token = _authService.token;
    } else {
      _errorMessage = "Login failed. Please check your credentials.";
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _authService.register(username, password);
    if (success) {
      _user = _authService.user;
      _token = _authService.token;
    } else {
      _errorMessage = "Registration failed. Username might be taken.";
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _token = null;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final success = await _authService.tryAutoLogin();
    if (success) {
      _user = _authService.user;
      _token = _authService.token;
      notifyListeners();
    }
    return success;
  }
}