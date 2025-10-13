// models/community.dart
import 'user.dart';

class Community {
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
  final List<CommunityMember> members;
  final int memberCount;

  Community({
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
    this.memberCount = 0,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
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
          ?.map((member) => CommunityMember.fromJson(member))
          .toList() ?? [],
      memberCount: json['_count']?['members'] ?? 0,
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

class CommunityMember {
  final String id;
  final String communityId;
  final String userId;
  final String role;
  final DateTime joinedAt;
  final User? user;

  CommunityMember({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.user,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    return CommunityMember(
      id: json['id'],
      communityId: json['communityId'],
      userId: json['userId'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joinedAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communityId': communityId,
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}
