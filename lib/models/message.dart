import 'user.dart';
import 'group.dart';

enum MessageType { 
  text, 
  image, 
  video, 
  audio, 
  file, 
  location, 
  contact, 
  sticker, 
  gif,
  voice,
  document,
  poll,
  system
}

enum MessageStatus { sent, delivered, read }

class Message {
  final String id;
  final String content;
  final MessageType type;
  final String senderId;
  final String? receiverId;
  final String? groupId;
  final String? replyToId;
  final String? forwardedFromId;
  final bool isEdited;
  final bool isDeleted;
  final bool isTemporary;
  final DateTime? expiresAt;
  final String? metadata; // JSON para dados extras
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? sender;
  final User? receiver;
  final Group? group;
  final Message? replyTo;
  final Message? forwardedFrom;
  final List<MessageReaction> reactions;

  Message({
    required this.id,
    required this.content,
    required this.type,
    required this.senderId,
    this.receiverId,
    this.groupId,
    this.replyToId,
    this.forwardedFromId,
    this.isEdited = false,
    this.isDeleted = false,
    this.isTemporary = false,
    this.expiresAt,
    this.metadata,
    this.status = MessageStatus.sent,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.receiver,
    this.group,
    this.replyTo,
    this.forwardedFrom,
    this.reactions = const [],
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      type: _stringToMessageType(json['type'] ?? 'text'),
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      groupId: json['groupId'],
      replyToId: json['replyToId'],
      forwardedFromId: json['forwardedFromId'],
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      isTemporary: json['isTemporary'] ?? false,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      metadata: json['metadata'],
      status: _stringToMessageStatus(json['status'] ?? 'sent'),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
      group: json['group'] != null ? Group.fromJson(json['group']) : null,
      replyTo: json['replyTo'] != null ? Message.fromJson(json['replyTo']) : null,
      forwardedFrom: json['forwardedFrom'] != null ? Message.fromJson(json['forwardedFrom']) : null,
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((reaction) => MessageReaction.fromJson(reaction))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': _messageTypeToString(type),
      'senderId': senderId,
      'receiverId': receiverId,
      'groupId': groupId,
      'replyToId': replyToId,
      'forwardedFromId': forwardedFromId,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'isTemporary': isTemporary,
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
      'status': _messageStatusToString(status),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sender': sender?.toJson(),
      'receiver': receiver?.toJson(),
      'group': group?.toJson(),
      'replyTo': replyTo?.toJson(),
      'forwardedFrom': forwardedFrom?.toJson(),
      'reactions': reactions.map((reaction) => reaction.toJson()).toList(),
    };
  }

  static MessageType _stringToMessageType(String type) {
    switch (type.toLowerCase()) {
      case 'image': return MessageType.image;
      case 'video': return MessageType.video;
      case 'audio': return MessageType.audio;
      case 'file': return MessageType.file;
      case 'location': return MessageType.location;
      case 'contact': return MessageType.contact;
      case 'sticker': return MessageType.sticker;
      case 'gif': return MessageType.gif;
      case 'voice': return MessageType.voice;
      case 'document': return MessageType.document;
      case 'poll': return MessageType.poll;
      case 'system': return MessageType.system;
      default: return MessageType.text;
    }
  }

  static String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.image: return 'image';
      case MessageType.video: return 'video';
      case MessageType.audio: return 'audio';
      case MessageType.file: return 'file';
      case MessageType.location: return 'location';
      case MessageType.contact: return 'contact';
      case MessageType.sticker: return 'sticker';
      case MessageType.gif: return 'gif';
      case MessageType.voice: return 'voice';
      case MessageType.document: return 'document';
      case MessageType.poll: return 'poll';
      case MessageType.system: return 'system';
      default: return 'text';
    }
  }

  static MessageStatus _stringToMessageStatus(String status) {
    switch (status.toLowerCase()) {
      case 'delivered': return MessageStatus.delivered;
      case 'read': return MessageStatus.read;
      default: return MessageStatus.sent;
    }
  }

  static String _messageStatusToString(MessageStatus status) {
    switch (status) {
      case MessageStatus.delivered: return 'delivered';
      case MessageStatus.read: return 'read';
      default: return 'sent';
    }
  }

  Message copyWith({
    String? content,
    MessageType? type,
    bool? isEdited,
    bool? isDeleted,
    bool? isTemporary,
    DateTime? expiresAt,
    String? metadata,
    MessageStatus? status,
    List<MessageReaction>? reactions,
  }) {
    return Message(
      id: id,
      content: content ?? this.content,
      type: type ?? this.type,
      senderId: senderId,
      receiverId: receiverId,
      groupId: groupId,
      replyToId: replyToId,
      forwardedFromId: forwardedFromId,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      isTemporary: isTemporary ?? this.isTemporary,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      sender: sender,
      receiver: receiver,
      group: group,
      replyTo: replyTo,
      forwardedFrom: forwardedFrom,
      reactions: reactions ?? this.reactions,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isGroupMessage => groupId != null;
  bool get isReply => replyToId != null;
  bool get isForwarded => forwardedFromId != null;

  String get statusText {
    switch (status) {
      case MessageStatus.sent:
        return 'Enviada';
      case MessageStatus.delivered:
        return 'Entregue';
      case MessageStatus.read:
        return 'Lida';
    }
  }

  String get typeText {
    switch (type) {
      case MessageType.text:
        return 'Texto';
      case MessageType.image:
        return 'Imagem';
      case MessageType.video:
        return 'Vídeo';
      case MessageType.audio:
        return 'Áudio';
      case MessageType.file:
        return 'Arquivo';
      case MessageType.location:
        return 'Localização';
      case MessageType.contact:
        return 'Contato';
      case MessageType.sticker:
        return 'Sticker';
      case MessageType.gif:
        return 'GIF';
      case MessageType.voice:
        return 'Voz';
      case MessageType.document:
        return 'Documento';
      case MessageType.poll:
        return 'Enquete';
      case MessageType.system:
        return 'Sistema';
    }
  }
}

class MessageReaction {
  final String id;
  final String messageId;
  final String userId;
  final String emoji;
  final DateTime createdAt;

  MessageReaction({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      id: json['id'],
      messageId: json['messageId'],
      userId: json['userId'],
      emoji: json['emoji'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messageId': messageId,
      'userId': userId,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}