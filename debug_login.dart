import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await testLogin();
  await testRegister();
}

Future<void> testLogin() async {
  print('🔍 Testing Login API...');
  
  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': 'testuser', 'password': 'password123'}),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Login successful!');
      print('Access Token: ${data['access_token']}');
      print('User ID: ${data['user']['id']}');
      print('Username: ${data['user']['username']}');
    } else {
      print('❌ Login failed');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
  
  print('\n' + '='*50 + '\n');
}

Future<void> testRegister() async {
  print('🔍 Testing Register API...');
  
  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': 'newuser', 'password': 'password123'}),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('✅ Registration successful!');
      print('Access Token: ${data['access_token']}');
      print('User ID: ${data['user']['id']}');
      print('Username: ${data['user']['username']}');
    } else {
      print('❌ Registration failed');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
  
  print('\n' + '='*50 + '\n');
}