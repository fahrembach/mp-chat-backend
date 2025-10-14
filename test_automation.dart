// test_automation.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TestAutomation {
  static const String baseUrl = 'https://mp-chat-backend.onrender.com';
  
  // Criar usuários de teste
  static Future<Map<String, String>> createTestUsers() async {
    print('🧪 Criando usuários de teste...');
    
    final users = <String, String>{};
    
    // Usuário 1
    try {
      final response1 = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': 'testuser1',
          'email': 'test1@example.com',
          'password': 'password123',
          'name': 'Usuário Teste 1',
          'phone': '+5511999999991'
        }),
      );
      
      if (response1.statusCode == 201) {
        final data1 = json.decode(response1.body);
        users['user1'] = data1['token'];
        print('✅ Usuário 1 criado: ${data1['user']['username']}');
      } else {
        print('❌ Erro ao criar usuário 1: ${response1.statusCode} - ${response1.body}');
      }
    } catch (e) {
      print('❌ Exceção ao criar usuário 1: $e');
    }
    
    // Usuário 2
    try {
      final response2 = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': 'testuser2',
          'email': 'test2@example.com',
          'password': 'password123',
          'name': 'Usuário Teste 2',
          'phone': '+5511999999992'
        }),
      );
      
      if (response2.statusCode == 201) {
        final data2 = json.decode(response2.body);
        users['user2'] = data2['token'];
        print('✅ Usuário 2 criado: ${data2['user']['username']}');
      } else {
        print('❌ Erro ao criar usuário 2: ${response2.statusCode} - ${response2.body}');
      }
    } catch (e) {
      print('❌ Exceção ao criar usuário 2: $e');
    }
    
    return users;
  }
  
  // Testar envio de mensagens
  static Future<void> testMessages(String token1, String token2) async {
    print('📱 Testando envio de mensagens...');
    
    try {
      // Enviar mensagem do usuário 1 para usuário 2
      final response = await http.post(
        Uri.parse('$baseUrl/api/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token1'
        },
        body: json.encode({
          'receiverId': 'testuser2',
          'content': 'Olá! Esta é uma mensagem de teste.',
          'type': 'text'
        }),
      );
      
      if (response.statusCode == 201) {
        print('✅ Mensagem enviada com sucesso');
      } else {
        print('❌ Erro ao enviar mensagem: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Exceção ao enviar mensagem: $e');
    }
  }
  
  // Testar status
  static Future<void> testStatus(String token) async {
    print('📸 Testando criação de status...');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'content': 'Status de teste criado automaticamente',
          'type': 'text'
        }),
      );
      
      if (response.statusCode == 201) {
        print('✅ Status criado com sucesso');
      } else {
        print('❌ Erro ao criar status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Exceção ao criar status: $e');
    }
  }
  
  // Testar histórico de chamadas
  static Future<void> testCallHistory(String token) async {
    print('📞 Testando histórico de chamadas...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/calls/history'),
        headers: {
          'Authorization': 'Bearer $token'
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Histórico de chamadas obtido: ${data.length} chamadas');
      } else {
        print('❌ Erro ao obter histórico: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Exceção ao obter histórico: $e');
    }
  }
  
  // Executar todos os testes
  static Future<void> runAllTests() async {
    print('🚀 Iniciando testes automatizados...');
    print('⏰ Aguardando backend atualizar (30 segundos)...');
    
    // Aguardar backend atualizar
    await Future.delayed(Duration(seconds: 30));
    
    final users = await createTestUsers();
    
    if (users.containsKey('user1') && users.containsKey('user2')) {
      await testMessages(users['user1']!, users['user2']!);
      await testStatus(users['user1']!);
      await testCallHistory(users['user1']!);
      
      print('✅ Todos os testes concluídos!');
    } else {
      print('❌ Falha ao criar usuários de teste');
    }
  }
}

void main() async {
  await TestAutomation.runAllTests();
}
