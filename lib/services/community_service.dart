import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import '../models/community.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class CommunityService {
  static const String _baseUrl = 'https://projeto-798t.onrender.com/api';
  final AuthService _authService = GetIt.instance<AuthService>();

  // Criar nova comunidade
  Future<Community> createCommunity({
    required String name,
    required String description,
    String? avatar,
    bool isPrivate = false,
  }) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities');
      
      final body = {
        'name': name,
        'description': description,
        'avatar': avatar,
        'isPrivate': isPrivate,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Community.fromJson(data);
      } else {
        throw Exception('Falha ao criar comunidade');
      }
    } catch (e) {
      throw Exception('Erro ao criar comunidade: $e');
    }
  }

  // Obter todas as comunidades
  Future<List<Community>> getCommunities() async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities');
      
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Community.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao obter comunidades');
      }
    } catch (e) {
      throw Exception('Erro ao obter comunidades: $e');
    }
  }

  // Obter comunidade por ID
  Future<Community> getCommunity(String communityId) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities/$communityId');
      
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Community.fromJson(data);
      } else {
        throw Exception('Falha ao obter comunidade');
      }
    } catch (e) {
      throw Exception('Erro ao obter comunidade: $e');
    }
  }

  // Entrar na comunidade
  Future<void> joinCommunity(String communityId) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities/$communityId/join');
      
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao entrar na comunidade');
      }
    } catch (e) {
      throw Exception('Erro ao entrar na comunidade: $e');
    }
  }

  // Sair da comunidade
  Future<void> leaveCommunity(String communityId) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities/$communityId/leave');
      
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao sair da comunidade');
      }
    } catch (e) {
      throw Exception('Erro ao sair da comunidade: $e');
    }
  }

  // Obter membros da comunidade
  Future<List<User>> getCommunityMembers(String communityId) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities/$communityId/members');
      
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao obter membros da comunidade');
      }
    } catch (e) {
      throw Exception('Erro ao obter membros da comunidade: $e');
    }
  }

  // Adicionar membro à comunidade
  Future<void> addMember(String communityId, String userId) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities/$communityId/members');
      
      final body = {'userId': userId};

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao adicionar membro');
      }
    } catch (e) {
      throw Exception('Erro ao adicionar membro: $e');
    }
  }

  // Remover membro da comunidade
  Future<void> removeMember(String communityId, String userId) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities/$communityId/members/$userId');
      
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao remover membro');
      }
    } catch (e) {
      throw Exception('Erro ao remover membro: $e');
    }
  }

  // Atualizar comunidade
  Future<Community> updateCommunity(String communityId, {
    String? name,
    String? description,
    String? avatar,
    bool? isPrivate,
  }) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities/$communityId');
      
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (avatar != null) body['avatar'] = avatar;
      if (isPrivate != null) body['isPrivate'] = isPrivate;

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Community.fromJson(data);
      } else {
        throw Exception('Falha ao atualizar comunidade');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar comunidade: $e');
    }
  }

  // Deletar comunidade
  Future<void> deleteCommunity(String communityId) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities/$communityId');
      
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao deletar comunidade');
      }
    } catch (e) {
      throw Exception('Erro ao deletar comunidade: $e');
    }
  }

  // Buscar comunidades
  Future<List<Community>> searchCommunities(String query) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities/search?q=${Uri.encodeComponent(query)}');
      
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Community.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao buscar comunidades');
      }
    } catch (e) {
      throw Exception('Erro ao buscar comunidades: $e');
    }
  }

  // Obter comunidades do usuário
  Future<List<Community>> getUserCommunities() async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities/user');
      
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Community.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao obter comunidades do usuário');
      }
    } catch (e) {
      throw Exception('Erro ao obter comunidades do usuário: $e');
    }
  }

  // Obter comunidades públicas
  Future<List<Community>> getPublicCommunities() async {
    try {
      final communities = await getCommunities();
      return communities.where((community) => !community.isPrivate).toList();
    } catch (e) {
      throw Exception('Erro ao obter comunidades públicas: $e');
    }
  }

  // Obter comunidades privadas
  Future<List<Community>> getPrivateCommunities() async {
    try {
      final communities = await getCommunities();
      return communities.where((community) => community.isPrivate).toList();
    } catch (e) {
      throw Exception('Erro ao obter comunidades privadas: $e');
    }
  }

  // Obter comunidades mais populares
  Future<List<Community>> getPopularCommunities({int limit = 10}) async {
    try {
      final communities = await getCommunities();
      // Ordenar por número de membros (assumindo que temos essa informação)
      communities.sort((a, b) => b.members.length.compareTo(a.members.length));
      return communities.take(limit).toList();
    } catch (e) {
      throw Exception('Erro ao obter comunidades populares: $e');
    }
  }

  // Obter comunidades recentes
  Future<List<Community>> getRecentCommunities({int limit = 10}) async {
    try {
      final communities = await getCommunities();
      communities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return communities.take(limit).toList();
    } catch (e) {
      throw Exception('Erro ao obter comunidades recentes: $e');
    }
  }

  // Upload de avatar da comunidade
  Future<String> uploadCommunityAvatar(String filePath) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities/upload-avatar');
      
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      
      request.files.add(await http.MultipartFile.fromPath('avatar', filePath));
      
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        return data['avatarUrl'] as String;
      } else {
        throw Exception('Falha ao fazer upload do avatar');
      }
    } catch (e) {
      throw Exception('Erro ao fazer upload do avatar: $e');
    }
  }

  // Obter estatísticas da comunidade
  Future<Map<String, dynamic>> getCommunityStats(String communityId) async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('$_baseUrl/communities/$communityId/stats');
      
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao obter estatísticas da comunidade');
      }
    } catch (e) {
      throw Exception('Erro ao obter estatísticas da comunidade: $e');
    }
  }
}

