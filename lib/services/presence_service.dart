import 'package:flutter/material.dart';
import '../models/user.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final Map<String, bool> _userPresence = {};
  final Map<String, DateTime> _lastSeen = {};

  bool isUserOnline(String userId) {
    return _userPresence[userId] ?? false;
  }

  DateTime? getLastSeen(String userId) {
    return _lastSeen[userId];
  }

  void setUserOnline(String userId) {
    _userPresence[userId] = true;
    _lastSeen[userId] = DateTime.now();
  }

  void setUserOffline(String userId) {
    _userPresence[userId] = false;
    _lastSeen[userId] = DateTime.now();
  }

  void updateLastSeen(String userId) {
    _lastSeen[userId] = DateTime.now();
  }

  String formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Nunca visto';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Online agora';
    } else if (difference.inMinutes < 60) {
      return 'Visto há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Visto há ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Visto há ${difference.inDays} dias';
    } else {
      return 'Visto em ${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }

  String formatOnlineStatus(User user) {
    if (isUserOnline(user.id)) {
      return 'Online';
    } else {
      return formatLastSeen(getLastSeen(user.id));
    }
  }
}
