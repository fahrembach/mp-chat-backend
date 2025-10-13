// models/user_settings.dart
class UserSettings {
  final String id;
  final String userId;
  final String theme;
  final String language;
  final bool notifications;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool readReceipts;
  final bool lastSeen;
  final bool profilePhoto;
  final String statusPrivacy;
  final String groupInvitePrivacy;
  final String callPrivacy;
  final bool mediaAutoDownload;
  final bool mediaDownloadWifiOnly;
  final String fontSize;
  final bool accessibilityMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettings({
    required this.id,
    required this.userId,
    required this.theme,
    required this.language,
    required this.notifications,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.readReceipts,
    required this.lastSeen,
    required this.profilePhoto,
    required this.statusPrivacy,
    required this.groupInvitePrivacy,
    required this.callPrivacy,
    required this.mediaAutoDownload,
    required this.mediaDownloadWifiOnly,
    required this.fontSize,
    required this.accessibilityMode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'],
      userId: json['userId'],
      theme: json['theme'] ?? 'dark',
      language: json['language'] ?? 'pt-BR',
      notifications: json['notifications'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      readReceipts: json['readReceipts'] ?? true,
      lastSeen: json['lastSeen'] ?? true,
      profilePhoto: json['profilePhoto'] ?? true,
      statusPrivacy: json['statusPrivacy'] ?? 'contacts',
      groupInvitePrivacy: json['groupInvitePrivacy'] ?? 'contacts',
      callPrivacy: json['callPrivacy'] ?? 'contacts',
      mediaAutoDownload: json['mediaAutoDownload'] ?? true,
      mediaDownloadWifiOnly: json['mediaDownloadWifiOnly'] ?? true,
      fontSize: json['fontSize'] ?? 'medium',
      accessibilityMode: json['accessibilityMode'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'theme': theme,
      'language': language,
      'notifications': notifications,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'readReceipts': readReceipts,
      'lastSeen': lastSeen,
      'profilePhoto': profilePhoto,
      'statusPrivacy': statusPrivacy,
      'groupInvitePrivacy': groupInvitePrivacy,
      'callPrivacy': callPrivacy,
      'mediaAutoDownload': mediaAutoDownload,
      'mediaDownloadWifiOnly': mediaDownloadWifiOnly,
      'fontSize': fontSize,
      'accessibilityMode': accessibilityMode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserSettings copyWith({
    String? theme,
    String? language,
    bool? notifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? readReceipts,
    bool? lastSeen,
    bool? profilePhoto,
    String? statusPrivacy,
    String? groupInvitePrivacy,
    String? callPrivacy,
    bool? mediaAutoDownload,
    bool? mediaDownloadWifiOnly,
    String? fontSize,
    bool? accessibilityMode,
  }) {
    return UserSettings(
      id: id,
      userId: userId,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      readReceipts: readReceipts ?? this.readReceipts,
      lastSeen: lastSeen ?? this.lastSeen,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      statusPrivacy: statusPrivacy ?? this.statusPrivacy,
      groupInvitePrivacy: groupInvitePrivacy ?? this.groupInvitePrivacy,
      callPrivacy: callPrivacy ?? this.callPrivacy,
      mediaAutoDownload: mediaAutoDownload ?? this.mediaAutoDownload,
      mediaDownloadWifiOnly: mediaDownloadWifiOnly ?? this.mediaDownloadWifiOnly,
      fontSize: fontSize ?? this.fontSize,
      accessibilityMode: accessibilityMode ?? this.accessibilityMode,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
