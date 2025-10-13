import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/chat.dart';
import '../models/message.dart';

class ApiService {
  // URL do backend no Render
  static const String _baseUrl = 'https://projeto-798t.onrender.com/api';

  Future<Map<String, dynamic>> register(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    print('[API] Attempting to register at $url');
    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'username': username, 'password': password}));
      final data = json.decode(response.body);
      if (response.statusCode == 201) {
        print('[API] Registration successful for user: $username');
        return {'token': data['access_token'], 'user': data['user']};
      } else {
        throw Exception(data['error'] ?? 'Failed to register');
      }
    } catch (e) {
      print('[API] Registration error: $e');
      if (e.toString().contains('Could not connect to the server')) {
        throw Exception('Could not connect to the server. Please check your internet connection.');
      }
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    print('[API] Attempting to login at $url');
    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'username': username, 'password': password}));
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        print('[API] Login successful for user: $username');
        return {'token': data['access_token'], 'user': data['user']};
      } else {
        throw Exception(data['error'] ?? 'Failed to login');
      }
    } catch (e) {
      print('[API] Login error: $e');
      if (e.toString().contains('Could not connect to the server')) {
        throw Exception('Could not connect to the server. Please check your internet connection.');
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<List<User>> getUsers(String token) async {
    final url = Uri.parse('$_baseUrl/users');
    print('[API] Fetching users from $url');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Could not connect to the server.');
    }
  }

  Future<List<Chat>> getChats(String token) async {
    final url = Uri.parse('$_baseUrl/messages/chats');
    print('[API] Fetching chats from $url');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Chat.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chats');
      }
    } catch (e) {
      throw Exception('Could not connect to the server.');
    }
  }

  Future<List<Message>> getMessages(String token, String peerId) async {
    final url = Uri.parse('$_baseUrl/messages/$peerId');
    print('[API] Fetching messages from $url');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Could not connect to the server.');
    }
  }

  Future<Message> createMessage(String token, String receiverId, String content) async {
    final url = Uri.parse('$_baseUrl/messages');
    print('[API] Creating message via HTTP POST to $url');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode({'receiverId': receiverId, 'content': content, 'type': 'text'}),
      );
      if (response.statusCode == 201) {
        return Message.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create message via API');
      }
    } catch (e) {
      throw Exception('Could not connect to the server.');
    }
  }
}