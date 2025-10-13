// models/status_update.dart
import 'user.dart';

class StatusUpdate {
  final String id;
  final String userId;
  final String content;
  final String type;
  final String? mediaUrl;
  final int views;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final User? user;
  final List<StatusViewer> viewers;

  StatusUpdate({
    required this.id,
    required this.userId,
    required this.content,
    required this.type,
    this.mediaUrl,
    required this.views,
    this.expiresAt,
    required this.createdAt,
    this.user,
    required this.viewers,
  });

  factory StatusUpdate.fromJson(Map<String, dynamic> json) {
    return StatusUpdate(
      id: json['id'],
      userId: json['userId'],
      content: json['content'],
      type: json['type'],
      mediaUrl: json['mediaUrl'],
      views: json['views'] ?? 0,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      viewers: (json['viewers'] as List<dynamic>?)
          ?.map((viewer) => StatusViewer.fromJson(viewer))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'type': type,
      'mediaUrl': mediaUrl,
      'views': views,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'user': user?.toJson(),
      'viewers': viewers.map((viewer) => viewer.toJson()).toList(),
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

class StatusViewer {
  final String id;
  final String statusUpdateId;
  final String userId;
  final DateTime viewedAt;

  StatusViewer({
    required this.id,
    required this.statusUpdateId,
    required this.userId,
    required this.viewedAt,
  });

  factory StatusViewer.fromJson(Map<String, dynamic> json) {
    return StatusViewer(
      id: json['id'],
      statusUpdateId: json['statusUpdateId'],
      userId: json['userId'],
      viewedAt: DateTime.parse(json['viewedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'statusUpdateId': statusUpdateId,
      'userId': userId,
      'viewedAt': viewedAt.toIso8601String(),
    };
  }
}
