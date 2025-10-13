import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';
import '../models/message.dart';

class SocketService {
  IO.Socket? _socket;
  
  // URL do backend no Render
  static const String _socketUrl = 'https://projeto-798t.onrender.com';

  IO.Socket? get socket => _socket;

  // Callbacks para chamadas P2P
  Function(Map<String, dynamic>)? onCallOffer;
  Function(Map<String, dynamic>)? onCallAnswer;
  Function(Map<String, dynamic>)? onIceCandidate;
  Function(Map<String, dynamic>)? onCallEnd;

  void connect(String token) {
    if (_socket != null && _socket!.connected) return;
    
    print('[SOCKET] Connecting to $_socketUrl...');
    _socket = IO.io(_socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {'token': token},
    });

    _socket!.onConnect((_) => print('[SOCKET] ✅ Socket connected with ID: ${_socket!.id}'));
    _socket!.onDisconnect((_) => print('[SOCKET] 🔌 Socket disconnected'));
    _socket!.onConnectError((data) => print('[SOCKET] ‼️  Connection Error: $data'));
    _socket!.onError((data) => print('[SOCKET] ‼️  Error: $data'));

    // Listeners para chamadas P2P
    _socket!.on('callOffer', (data) {
      print('[SOCKET] 📞 Call offer received: $data');
      onCallOffer?.call(data);
    });

    _socket!.on('callAnswer', (data) {
      print('[SOCKET] 📞 Call answer received: $data');
      onCallAnswer?.call(data);
    });

    _socket!.on('iceCandidate', (data) {
      print('[SOCKET] 🧊 ICE candidate received: $data');
      onIceCandidate?.call(data);
    });

    _socket!.on('callEnd', (data) {
      print('[SOCKET] 📞 Call end received: $data');
      onCallEnd?.call(data);
    });
  }

  // Send message with type support
  void sendMessage(String receiverId, String content, {String type = 'text'}) {
    if (_socket == null || !_socket!.connected) {
      print('[SOCKET] ‼️ Cannot send message, socket is not connected.');
      return;
    }
    final data = {'receiverId': receiverId, 'content': content, 'type': type};
    print('[SOCKET] Emitting "sendMessage" with data: $data');
    _socket!.emit('sendMessage', data);
  }

  // Métodos para chamadas P2P
  void sendCallOffer(String receiverId, String callId, Map<String, dynamic> offer) {
    if (_socket == null || !_socket!.connected) return;
    final data = {
      'receiverId': receiverId,
      'callId': callId,
      'offer': offer,
      'type': 'call_offer'
    };
    print('[SOCKET] Emitting "callOffer" with data: $data');
    _socket!.emit('callOffer', data);
  }

  void sendCallAnswer(String receiverId, String callId, Map<String, dynamic> answer) {
    if (_socket == null || !_socket!.connected) return;
    final data = {
      'receiverId': receiverId,
      'callId': callId,
      'answer': answer,
      'type': 'call_answer'
    };
    print('[SOCKET] Emitting "callAnswer" with data: $data');
    _socket!.emit('callAnswer', data);
  }

  void sendIceCandidate(String receiverId, String callId, Map<String, dynamic> candidate) {
    if (_socket == null || !_socket!.connected) return;
    final data = {
      'receiverId': receiverId,
      'callId': callId,
      'candidate': candidate,
      'type': 'ice_candidate'
    };
    print('[SOCKET] Emitting "iceCandidate" with data: $data');
    _socket!.emit('iceCandidate', data);
  }

  void sendCallEnd(String receiverId, String callId) {
    if (_socket == null || !_socket!.connected) return;
    final data = {
      'receiverId': receiverId,
      'callId': callId,
      'type': 'call_end'
    };
    print('[SOCKET] Emitting "callEnd" with data: $data');
    _socket!.emit('callEnd', data);
  }

  void disconnect() {
    print('[SOCKET] Disconnecting socket...');
    _socket?.dispose();
    _socket = null;
  }
}