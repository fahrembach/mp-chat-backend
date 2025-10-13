import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String? email;
  final String? name;
  final String? phone;
  final String? bio;
  final String? avatar;
  final bool isOnline;
  final DateTime? lastSeen;
  final String status; // available, busy, away, invisible
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.username,
    this.email,
    this.name,
    this.phone,
    this.bio,
    this.avatar,
    this.isOnline = false,
    this.lastSeen,
    this.status = 'available',
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, username, email, name, phone, bio, avatar, isOnline, lastSeen, status, createdAt, updatedAt];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      bio: json['bio'],
      avatar: json['avatar'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      status: json['status'] ?? 'available',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'phone': phone,
      'bio': bio,
      'avatar': avatar,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? username,
    String? email,
    String? name,
    String? phone,
    String? bio,
    String? avatar,
    bool? isOnline,
    DateTime? lastSeen,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName => name ?? username;
  
  String get statusText {
    switch (status) {
      case 'available':
        return 'Disponível';
      case 'busy':
        return 'Ocupado';
      case 'away':
        return 'Ausente';
      case 'invisible':
        return 'Invisível';
      default:
        return 'Disponível';
    }
  }

  String get lastSeenText {
    if (isOnline) {
      return 'Online';
    }
    
    if (lastSeen == null) {
      return 'Nunca visto';
    }
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    
    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dias';
    } else {
      return 'Há muito tempo';
    }
  }
}