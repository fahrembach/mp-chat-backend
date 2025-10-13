// services/group_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/group.dart';
import '../models/user.dart';

class GroupService {
  static const String _baseUrl = 'https://projeto-798t.onrender.com/api';

  // Criar grupo
  Future<Group> createGroup({
    required String name,
    String? description,
    bool isPrivate = false,
    List<String>? memberIds,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/groups');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'isPrivate': isPrivate,
          'memberIds': memberIds,
        }),
      );

      if (response.statusCode == 201) {
        return Group.fromJson(json.decode(response.body));
      } else {
        throw Exception('Falha ao criar grupo');
      }
    } catch (e) {
      print('[GROUP] Error creating group: $e');
      throw Exception('Erro ao criar grupo: $e');
    }
  }

  // Obter grupos do usuário
  Future<List<Group>> getUserGroups(String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Group.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar grupos');
      }
    } catch (e) {
      print('[GROUP] Error getting user groups: $e');
      throw Exception('Erro ao carregar grupos: $e');
    }
  }

  // Obter detalhes do grupo
  Future<Group> getGroupDetails(String groupId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return Group.fromJson(json.decode(response.body));
      } else {
        throw Exception('Falha ao carregar detalhes do grupo');
      }
    } catch (e) {
      print('[GROUP] Error getting group details: $e');
      throw Exception('Erro ao carregar detalhes do grupo: $e');
    }
  }

  // Atualizar grupo
  Future<Group> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? avatar,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'avatar': avatar,
        }),
      );

      if (response.statusCode == 200) {
        return Group.fromJson(json.decode(response.body));
      } else {
        throw Exception('Falha ao atualizar grupo');
      }
    } catch (e) {
      print('[GROUP] Error updating group: $e');
      throw Exception('Erro ao atualizar grupo: $e');
    }
  }

  // Deletar grupo
  Future<bool> deleteGroup(String groupId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId');
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[GROUP] Error deleting group: $e');
      return false;
    }
  }

  // Adicionar membro ao grupo
  Future<bool> addMemberToGroup({
    required String groupId,
    required String userId,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId/members');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'userId': userId}),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('[GROUP] Error adding member to group: $e');
      return false;
    }
  }

  // Remover membro do grupo
  Future<bool> removeMemberFromGroup({
    required String groupId,
    required String userId,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId/members/$userId');
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[GROUP] Error removing member from group: $e');
      return false;
    }
  }

  // Atualizar função do membro
  Future<bool> updateMemberRole({
    required String groupId,
    required String userId,
    required String role,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId/members/$userId');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'role': role}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[GROUP] Error updating member role: $e');
      return false;
    }
  }

  // Obter membros do grupo
  Future<List<GroupMember>> getGroupMembers(String groupId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId/members');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => GroupMember.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar membros do grupo');
      }
    } catch (e) {
      print('[GROUP] Error getting group members: $e');
      throw Exception('Erro ao carregar membros do grupo: $e');
    }
  }

  // Entrar no grupo por código de convite
  Future<bool> joinGroupByInviteCode({
    required String inviteCode,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/join');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'inviteCode': inviteCode}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[GROUP] Error joining group by invite code: $e');
      return false;
    }
  }

  // Sair do grupo
  Future<bool> leaveGroup(String groupId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId/leave');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[GROUP] Error leaving group: $e');
      return false;
    }
  }

  // Obter código de convite do grupo
  Future<String?> getGroupInviteCode(String groupId, String token) async {
    try {
      final group = await getGroupDetails(groupId, token);
      return group.inviteCode;
    } catch (e) {
      print('[GROUP] Error getting group invite code: $e');
      return null;
    }
  }

  // Regenerar código de convite
  Future<String?> regenerateInviteCode(String groupId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId/regenerate-invite');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['inviteCode'];
      } else {
        return null;
      }
    } catch (e) {
      print('[GROUP] Error regenerating invite code: $e');
      return null;
    }
  }

  // Buscar grupos públicos
  Future<List<Group>> searchPublicGroups(String query, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/search?q=${Uri.encodeComponent(query)}&public=true');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Group.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao buscar grupos');
      }
    } catch (e) {
      print('[GROUP] Error searching public groups: $e');
      throw Exception('Erro ao buscar grupos: $e');
    }
  }

  // Obter estatísticas do grupo
  Future<Map<String, dynamic>> getGroupStats(String groupId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId/stats');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao carregar estatísticas do grupo');
      }
    } catch (e) {
      print('[GROUP] Error getting group stats: $e');
      throw Exception('Erro ao carregar estatísticas do grupo: $e');
    }
  }

  // Silenciar grupo
  Future<bool> muteGroup(String groupId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId/mute');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[GROUP] Error muting group: $e');
      return false;
    }
  }

  // Dessilenciar grupo
  Future<bool> unmuteGroup(String groupId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId/unmute');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[GROUP] Error unmuting group: $e');
      return false;
    }
  }

  // Arquivar grupo
  Future<bool> archiveGroup(String groupId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId/archive');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[GROUP] Error archiving group: $e');
      return false;
    }
  }

  // Desarquivar grupo
  Future<bool> unarchiveGroup(String groupId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/$groupId/unarchive');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[GROUP] Error unarchiving group: $e');
      return false;
    }
  }
}
