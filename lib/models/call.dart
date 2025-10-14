// models/call.dart
import 'user.dart';

enum CallType {
  audio,
  video,
}

enum CallStatus {
  incoming,
  outgoing,
  missed,
  rejected,
  ended,
}

class Call {
  final String id;
  final String callerId;
  final String receiverId;
  final CallType type;
  final CallStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int? duration; // em segundos
  final User? caller;
  final User? receiver;
  final List<CallParticipant> participants;

  Call({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    this.duration,
    this.caller,
    this.receiver,
    this.participants = const [],
  });

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json['id'],
      callerId: json['callerId'],
      receiverId: json['receiverId'],
      type: CallType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CallType.audio,
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CallStatus.ended,
      ),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration: json['duration'],
      caller: json['caller'] != null ? User.fromJson(json['caller']) : null,
      receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
      participants: json['participants'] != null 
          ? (json['participants'] as List).map((p) => CallParticipant.fromJson(p)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callerId': callerId,
      'receiverId': receiverId,
      'type': type.name,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'caller': caller?.toJson(),
      'receiver': receiver?.toJson(),
      'participants': participants.map((p) => p.toJson()).toList(),
    };
  }

  Call copyWith({
    String? id,
    String? callerId,
    String? receiverId,
    CallType? type,
    CallStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    User? caller,
    User? receiver,
    List<CallParticipant>? participants,
  }) {
    return Call(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      caller: caller ?? this.caller,
      receiver: receiver ?? this.receiver,
      participants: participants ?? this.participants,
    );
  }

  String get formattedDuration {
    if (duration == null) return '';
    final hours = duration! ~/ 3600;
    final minutes = (duration! % 3600) ~/ 60;
    final seconds = duration! % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get statusText {
    switch (status) {
      case CallStatus.incoming:
        return 'Entrada';
      case CallStatus.outgoing:
        return 'Saída';
      case CallStatus.missed:
        return 'Perdida';
      case CallStatus.rejected:
        return 'Rejeitada';
      case CallStatus.ended:
        return 'Finalizada';
    }
  }

  String get typeText {
    return type == CallType.video ? 'Vídeo' : 'Áudio';
  }
}

class CallParticipant {
  final String id;
  final String callId;
  final String userId;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final User? user;

  CallParticipant({
    required this.id,
    required this.callId,
    required this.userId,
    required this.joinedAt,
    this.leftAt,
    this.user,
  });

  factory CallParticipant.fromJson(Map<String, dynamic> json) {
    return CallParticipant(
      id: json['id'],
      callId: json['callId'],
      userId: json['userId'],
      joinedAt: DateTime.parse(json['joinedAt']),
      leftAt: json['leftAt'] != null ? DateTime.parse(json['leftAt']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callId': callId,
      'userId': userId,
      'joinedAt': joinedAt.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}