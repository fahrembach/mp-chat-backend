import 'package:flutter/material.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/database_service.dart';
import '../services/call_service.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import './auth_provider.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService;
  final SocketService _socketService;
  final DatabaseService _dbService;
  final AuthProvider _authProvider;
  final CallService _callService;

  List<Chat> _chats = [];
  Map<String, List<Message>> _messages = {};
  Map<String, List<Message>> get messages => _messages;
  List<User> _users = [];
  bool _isLoadingChats = false;
  bool _isLoadingMessages = false;
  bool _isLoadingUsers = false;

  List<Chat> get chats => _chats;
  List<Message> messagesForUser(String peerId) => _messages[peerId] ?? [];
  List<User> get users => _users;
  bool get isLoadingChats => _isLoadingChats;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isLoadingUsers => _isLoadingUsers;

  ChatProvider(this._apiService, this._socketService, this._dbService, this._authProvider, this._callService) {
    _listenToSocketEvents();
    _callService.setupSocketListeners(_socketService);
  }

  void _listenToSocketEvents() {
    _socketService.socket?.on('newMessage', (data) async {
      final message = Message.fromJson(data);
      await _dbService.insertMessage(message);
      
      final peerId = message.senderId == _authProvider.user!.id ? message.receiverId : message.senderId;
      if (_messages.containsKey(peerId)) {
        _messages[peerId]!.add(message);
        notifyListeners();
      }
      loadChats();
    });
  }

  Future<void> loadUsers() async {
    if (_authProvider.token == null) return;
    _isLoadingUsers = true;
    notifyListeners();
    try {
      _users = await _apiService.getUsers(_authProvider.token!);
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> loadChats() async {
    if (_authProvider.token == null) return;
    _isLoadingChats = true;
    notifyListeners();
    try {
      final apiChats = await _apiService.getChats(_authProvider.token!);
      
      // Converter para o novo formato e adicionar dados mockados temporariamente
      _chats = apiChats.map((chat) {
        return Chat(
          id: chat.id,
          peer: chat.peer,
          lastMessage: chat.lastMessage,
          unreadCount: chat.unreadCount,
          updatedAt: chat.updatedAt,
        );
      }).toList();
      
      // Se não há chats, criar alguns exemplos para demonstração
      if (_chats.isEmpty && _users.isNotEmpty) {
        _chats = _users.take(3).map((user) {
          return Chat(
            id: 'chat_${user.id}',
            peer: user,
            lastMessage: null,
            unreadCount: 0,
            updatedAt: DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      print('Error loading chats: $e');
      // Criar chats de exemplo se houver erro
      if (_users.isNotEmpty) {
        _chats = _users.take(3).map((user) {
          return Chat(
            id: 'chat_${user.id}',
            peer: user,
            lastMessage: null,
            unreadCount: 0,
            updatedAt: DateTime.now(),
          );
        }).toList();
      }
    } finally {
      _isLoadingChats = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String peerId) async {
    if (_authProvider.token == null || _authProvider.user == null) return;
    _isLoadingMessages = true;
    notifyListeners();
    try {
      final localMessages = await _dbService.getMessages(_authProvider.user!.id, peerId);
      _messages[peerId] = localMessages;
      notifyListeners();

      final remoteMessages = await _apiService.getMessages(_authProvider.token!, peerId);
      _messages[peerId] = remoteMessages;
      
      for (var msg in remoteMessages) {
        await _dbService.insertMessage(msg);
      }

    } catch (e) {
      print('Error loading messages for $peerId: $e');
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> clearChat(String peerId) async {
    try {
      // Limpar mensagens do banco local
      await _dbService.clearMessages(peerId);
      
      // Recarregar mensagens
      await loadMessages(peerId);
      
      notifyListeners();
    } catch (e) {
      print('Error clearing chat: $e');
    }
  }

  Future<void> sendMedia(String receiverId, String fileName, String filePath) async {
    if (_authProvider.user == null) return;

    // Detectar tipo de arquivo baseado na extensão
    MessageType messageType = MessageType.file;
    if (fileName.toLowerCase().endsWith('.jpg') || 
        fileName.toLowerCase().endsWith('.jpeg') || 
        fileName.toLowerCase().endsWith('.png') || 
        fileName.toLowerCase().endsWith('.gif') || 
        fileName.toLowerCase().endsWith('.webp')) {
      messageType = MessageType.image;
    } else if (fileName.toLowerCase().endsWith('.mp3') || 
               fileName.toLowerCase().endsWith('.wav') || 
               fileName.toLowerCase().endsWith('.m4a') || 
               fileName.toLowerCase().endsWith('.aac')) {
      messageType = MessageType.audio;
    }

    final tempMessage = Message(
      id: DateTime.now().toIso8601String(),
      content: fileName,
      type: messageType,
      senderId: _authProvider.user!.id,
      receiverId: receiverId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      fileName: fileName,
      fileSize: await File(filePath).length(),
      mediaUrl: filePath, // Armazenar o caminho local para preview
    );
    
    if (!_messages.containsKey(receiverId)) {
      _messages[receiverId] = [];
    }
    _messages[receiverId]!.add(tempMessage);
    notifyListeners();

    await _dbService.insertMessage(tempMessage);

    try {
      _socketService.sendMessage(receiverId, fileName, type: messageType.name);
    } catch (e) {
      print('Error sending media via socket: $e');
      try {
        await _apiService.createMessage(_authProvider.token!, receiverId, fileName);
      } catch (apiError) {
        print('Error sending media via API: $apiError');
        _messages[receiverId]!.remove(tempMessage);
        notifyListeners();
      }
    }
  }

  Future<void> sendMessage(String receiverId, String content) async {
    if (_authProvider.user == null) return;

    final tempMessage = Message(
      id: DateTime.now().toIso8601String(),
      content: content,
      type: MessageType.text,
      senderId: _authProvider.user!.id,
      receiverId: receiverId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    if (!_messages.containsKey(receiverId)) {
      _messages[receiverId] = [];
    }
    _messages[receiverId]!.add(tempMessage);
    notifyListeners();

    await _dbService.insertMessage(tempMessage);

    try {
      _socketService.sendMessage(receiverId, content, type: 'text');
    } catch (e) {
      print('Error sending message via socket: $e');
      try {
        await _apiService.createMessage(_authProvider.token!, receiverId, content);
      } catch (apiError) {
        print('Error sending message via API: $apiError');
        _messages[receiverId]!.remove(tempMessage);
        notifyListeners();
      }
    }
  }
}