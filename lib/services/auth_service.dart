import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import './api_service.dart';
import './socket_service.dart';
import './call_service.dart';

class AuthService {
  final ApiService _apiService;
  final SocketService _socketService;
  final CallService _callService;

  AuthService(this._apiService, this._socketService, this._callService);

  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);
      _user = User.fromJson(response['user']);
      _token = response['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode({
        'token': _token,
        'user': response['user'],
      }));

      _socketService.connect(_token!);
      
      // Inicializar CallService e configurar listeners
      await _callService.initialize();
      _callService.setupSocketListeners(_socketService);
      
      return true;
    } catch (e) {
      print('Login failed: $e');
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    try {
      final response = await _apiService.register(username, password);
      _user = User.fromJson(response['user']);
      _token = response['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode({
        'token': _token,
        'user': response['user'],
      }));

      _socketService.connect(_token!);
      return true;
    } catch (e) {
      print('Registration failed: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _socketService.disconnect();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    _token = extractedUserData['token'];
    _user = User.fromJson(extractedUserData['user']);

    if (_token != null) {
      _socketService.connect(_token!);
      return true;
    }
    return false;
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
      _token = extractedUserData['token'];
      return _token;
    }
    return null;
  }

  Future<User?> getCurrentUser() async {
    if (_user != null) return _user;
    
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
      _user = User.fromJson(extractedUserData['user']);
      return _user;
    }
    return null;
  }
}