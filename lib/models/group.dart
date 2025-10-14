// models/group.dart
import 'user.dart';

class Group {
  final String id;
  final String name;
  final String? description;
  final String? avatar;
  final String creatorId;
  final bool isPrivate;
  final String? inviteCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? creator;
  final List<GroupMember> members;
  final int messageCount;

  Group({
    required this.id,
    required this.name,
    this.description,
    this.avatar,
    required this.creatorId,
    required this.isPrivate,
    this.inviteCode,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
    required this.members,
    this.messageCount = 0,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      avatar: json['avatar'],
      creatorId: json['creatorId'],
      isPrivate: json['isPrivate'] ?? false,
      inviteCode: json['inviteCode'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      members: (json['members'] as List<dynamic>?)
          ?.map((member) => GroupMember.fromJson(member))
          .toList() ?? [],
      messageCount: json['_count']?['messages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatar': avatar,
      'creatorId': creatorId,
      'isPrivate': isPrivate,
      'inviteCode': inviteCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'creator': creator?.toJson(),
      'members': members.map((member) => member.toJson()).toList(),
    };
  }
}

class GroupMember {
  final String id;
  final String groupId;
  final String userId;
  final String role;
  final DateTime joinedAt;
  final User? user;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.user,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'],
      groupId: json['groupId'],
      userId: json['userId'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joinedAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}
