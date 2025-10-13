// services/search_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/message.dart';
import '../models/group.dart';
import '../models/community.dart';

class SearchService {
  static const String _baseUrl = 'https://projeto-798t.onrender.com/api';

  // Buscar usuários
  Future<List<User>> searchUsers(String query, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/users/search?q=${Uri.encodeComponent(query)}');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao buscar usuários');
      }
    } catch (e) {
      print('[SEARCH] Error searching users: $e');
      throw Exception('Erro ao buscar usuários: $e');
    }
  }

  // Buscar mensagens
  Future<List<Message>> searchMessages(String query, String token, {String? chatId}) async {
    try {
      String url = '$_baseUrl/messages/search?q=${Uri.encodeComponent(query)}';
      if (chatId != null) {
        url += '&chatId=${Uri.encodeComponent(chatId)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao buscar mensagens');
      }
    } catch (e) {
      print('[SEARCH] Error searching messages: $e');
      throw Exception('Erro ao buscar mensagens: $e');
    }
  }

  // Buscar grupos
  Future<List<Group>> searchGroups(String query, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/groups/search?q=${Uri.encodeComponent(query)}');
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
      print('[SEARCH] Error searching groups: $e');
      throw Exception('Erro ao buscar grupos: $e');
    }
  }

  // Buscar comunidades
  Future<List<Community>> searchCommunities(String query, String token) async {
    try {
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
      print('[SEARCH] Error searching communities: $e');
      throw Exception('Erro ao buscar comunidades: $e');
    }
  }

  // Busca global
  Future<Map<String, dynamic>> globalSearch(String query, String token) async {
    try {
      final results = await Future.wait([
        searchUsers(query, token),
        searchMessages(query, token),
        searchGroups(query, token),
        searchCommunities(query, token),
      ]);

      return {
        'users': results[0] as List<User>,
        'messages': results[1] as List<Message>,
        'groups': results[2] as List<Group>,
        'communities': results[3] as List<Community>,
      };
    } catch (e) {
      print('[SEARCH] Error in global search: $e');
      throw Exception('Erro na busca global: $e');
    }
  }

  // Buscar mensagens por tipo
  Future<List<Message>> searchMessagesByType(String query, String token, MessageType type) async {
    try {
      final messages = await searchMessages(query, token);
      return messages.where((message) => message.type == type).toList();
    } catch (e) {
      print('[SEARCH] Error searching messages by type: $e');
      throw Exception('Erro ao buscar mensagens por tipo: $e');
    }
  }

  // Buscar mensagens de mídia
  Future<List<Message>> searchMediaMessages(String token) async {
    try {
      final messages = await searchMessages('', token);
      return messages.where((message) => 
        message.type == MessageType.image ||
        message.type == MessageType.video ||
        message.type == MessageType.audio ||
        message.type == MessageType.file ||
        message.type == MessageType.voice
      ).toList();
    } catch (e) {
      print('[SEARCH] Error searching media messages: $e');
      throw Exception('Erro ao buscar mensagens de mídia: $e');
    }
  }

  // Buscar mensagens com links
  Future<List<Message>> searchLinkMessages(String token) async {
    try {
      final messages = await searchMessages('http', token);
      return messages.where((message) => 
        message.content.contains('http') ||
        message.content.contains('www.') ||
        message.content.contains('.com') ||
        message.content.contains('.br')
      ).toList();
    } catch (e) {
      print('[SEARCH] Error searching link messages: $e');
      throw Exception('Erro ao buscar mensagens com links: $e');
    }
  }

  // Buscar mensagens por data
  Future<List<Message>> searchMessagesByDate(DateTime date, String token) async {
    try {
      final messages = await searchMessages('', token);
      return messages.where((message) => 
        message.createdAt.year == date.year &&
        message.createdAt.month == date.month &&
        message.createdAt.day == date.day
      ).toList();
    } catch (e) {
      print('[SEARCH] Error searching messages by date: $e');
      throw Exception('Erro ao buscar mensagens por data: $e');
    }
  }

  // Buscar mensagens não lidas
  Future<List<Message>> searchUnreadMessages(String token) async {
    try {
      final messages = await searchMessages('', token);
      return messages.where((message) => message.status != MessageStatus.read).toList();
    } catch (e) {
      print('[SEARCH] Error searching unread messages: $e');
      throw Exception('Erro ao buscar mensagens não lidas: $e');
    }
  }

  // Buscar mensagens com reações
  Future<List<Message>> searchMessagesWithReactions(String token) async {
    try {
      final messages = await searchMessages('', token);
      return messages.where((message) => message.reactions.isNotEmpty).toList();
    } catch (e) {
      print('[SEARCH] Error searching messages with reactions: $e');
      throw Exception('Erro ao buscar mensagens com reações: $e');
    }
  }

  // Buscar mensagens encaminhadas
  Future<List<Message>> searchForwardedMessages(String token) async {
    try {
      final messages = await searchMessages('', token);
      return messages.where((message) => message.isForwarded).toList();
    } catch (e) {
      print('[SEARCH] Error searching forwarded messages: $e');
      throw Exception('Erro ao buscar mensagens encaminhadas: $e');
    }
  }

  // Buscar mensagens temporárias
  Future<List<Message>> searchTemporaryMessages(String token) async {
    try {
      final messages = await searchMessages('', token);
      return messages.where((message) => message.isTemporary).toList();
    } catch (e) {
      print('[SEARCH] Error searching temporary messages: $e');
      throw Exception('Erro ao buscar mensagens temporárias: $e');
    }
  }

  // Buscar mensagens editadas
  Future<List<Message>> searchEditedMessages(String token) async {
    try {
      final messages = await searchMessages('', token);
      return messages.where((message) => message.isEdited).toList();
    } catch (e) {
      print('[SEARCH] Error searching edited messages: $e');
      throw Exception('Erro ao buscar mensagens editadas: $e');
    }
  }

  // Buscar mensagens deletadas
  Future<List<Message>> searchDeletedMessages(String token) async {
    try {
      final messages = await searchMessages('', token);
      return messages.where((message) => message.isDeleted).toList();
    } catch (e) {
      print('[SEARCH] Error searching deleted messages: $e');
      throw Exception('Erro ao buscar mensagens deletadas: $e');
    }
  }

  // Buscar usuários online
  Future<List<User>> searchOnlineUsers(String token) async {
    try {
      final users = await searchUsers('', token);
      return users.where((user) => user.isOnline).toList();
    } catch (e) {
      print('[SEARCH] Error searching online users: $e');
      throw Exception('Erro ao buscar usuários online: $e');
    }
  }

  // Buscar usuários por status
  Future<List<User>> searchUsersByStatus(String status, String token) async {
    try {
      final users = await searchUsers('', token);
      return users.where((user) => user.status == status).toList();
    } catch (e) {
      print('[SEARCH] Error searching users by status: $e');
      throw Exception('Erro ao buscar usuários por status: $e');
    }
  }

  // Buscar grupos privados
  Future<List<Group>> searchPrivateGroups(String token) async {
    try {
      final groups = await searchGroups('', token);
      return groups.where((group) => group.isPrivate).toList();
    } catch (e) {
      print('[SEARCH] Error searching private groups: $e');
      throw Exception('Erro ao buscar grupos privados: $e');
    }
  }

  // Buscar comunidades privadas
  Future<List<Community>> searchPrivateCommunities(String token) async {
    try {
      final communities = await searchCommunities('', token);
      return communities.where((community) => community.isPrivate).toList();
    } catch (e) {
      print('[SEARCH] Error searching private communities: $e');
      throw Exception('Erro ao buscar comunidades privadas: $e');
    }
  }
}
