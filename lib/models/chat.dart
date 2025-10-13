import 'package:equatable/equatable.dart';
import 'message.dart';
import 'user.dart';

class Chat extends Equatable {
  final String id;
  final User peer;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  const Chat({
    required this.id,
    required this.peer,
    this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, updatedAt, lastMessage?.id];

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      peer: User.fromJson(json['peer'] ?? json['participant']),
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}