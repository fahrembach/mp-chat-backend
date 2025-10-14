// models/status_update.dart
import 'user.dart';

enum StatusType {
  text,
  image,
  video,
  audio,
}

class StatusUpdate {
  final String id;
  final String userId;
  final String content;
  final StatusType type;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final int? duration; // Para vídeos e áudios
  final int views;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final User? user;
  final List<StatusViewer> viewers;
  final bool isViewed; // Se o usuário atual já visualizou

  StatusUpdate({
    required this.id,
    required this.userId,
    required this.content,
    required this.type,
    this.mediaUrl,
    this.thumbnailUrl,
    this.duration,
    this.views = 0,
    this.expiresAt,
    required this.createdAt,
    this.user,
    this.viewers = const [],
    this.isViewed = false,
  });

  factory StatusUpdate.fromJson(Map<String, dynamic> json) {
    return StatusUpdate(
      id: json['id'],
      userId: json['userId'],
      content: json['content'] ?? '',
      type: StatusType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StatusType.text,
      ),
      mediaUrl: json['mediaUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'],
      views: json['views'] ?? 0,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      viewers: json['viewers'] != null 
          ? (json['viewers'] as List).map((v) => StatusViewer.fromJson(v)).toList()
          : [],
      isViewed: json['isViewed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'views': views,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'user': user?.toJson(),
      'viewers': viewers.map((v) => v.toJson()).toList(),
      'isViewed': isViewed,
    };
  }

  StatusUpdate copyWith({
    String? id,
    String? userId,
    String? content,
    StatusType? type,
    String? mediaUrl,
    String? thumbnailUrl,
    int? duration,
    int? views,
    DateTime? expiresAt,
    DateTime? createdAt,
    User? user,
    List<StatusViewer>? viewers,
    bool? isViewed,
  }) {
    return StatusUpdate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      views: views ?? this.views,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      viewers: viewers ?? this.viewers,
      isViewed: isViewed ?? this.isViewed,
    );
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isMedia => type == StatusType.image || type == StatusType.video || type == StatusType.audio;
  String get displayContent => isMedia ? (mediaUrl ?? '') : content;
  String get formattedDuration {
    if (duration == null) return '';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class StatusViewer {
  final String id;
  final String statusId;
  final String userId;
  final DateTime viewedAt;
  final User? user;

  StatusViewer({
    required this.id,
    required this.statusId,
    required this.userId,
    required this.viewedAt,
    this.user,
  });

  factory StatusViewer.fromJson(Map<String, dynamic> json) {
    return StatusViewer(
      id: json['id'],
      statusId: json['statusId'],
      userId: json['userId'],
      viewedAt: DateTime.parse(json['viewedAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'statusId': statusId,
      'userId': userId,
      'viewedAt': viewedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}