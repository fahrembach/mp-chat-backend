import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/user.dart';
import '../models/call.dart';

class VideoCallService {
  static final VideoCallService _instance = VideoCallService._internal();
  factory VideoCallService() => _instance;
  VideoCallService._internal();

  IO.Socket? _socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  bool _isCallActive = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;
  
  // Callbacks
  Function(User user)? onIncomingCall;
  Function()? onCallAccepted;
  Function()? onCallRejected;
  Function()? onCallEnded;
  Function(MediaStream stream)? onRemoteStreamReceived;
  Function(String error)? onError;

  // Getters
  bool get isCallActive => _isCallActive;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isSpeakerOn => _isSpeakerOn;
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  Future<void> initialize() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      
      // Conectar ao socket
      _socket = IO.io('http://localhost:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      
      _socket!.connect();
      
      // Configurar listeners do socket
      _setupSocketListeners();
      
    } catch (e) {
      print('[VIDEO_CALL] Error initializing: $e');
      onError?.call('Erro ao inicializar chamada de vídeo: $e');
    }
  }

  void _setupSocketListeners() {
    _socket!.on('video_call_offer', (data) {
      _handleOffer(data);
    });
    
    _socket!.on('video_call_answer', (data) {
      _handleAnswer(data);
    });
    
    _socket!.on('video_call_ice_candidate', (data) {
      _handleIceCandidate(data);
    });
    
    _socket!.on('video_call_end', (data) {
      endCall();
    });
  }

  Future<void> startCall(String receiverId) async {
    try {
      _isCallActive = true;
      
      // Obter stream local
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': true,
      });
      
      _localRenderer.srcObject = _localStream;
      
      // Criar peer connection
      await _createPeerConnection();
      
      // Adicionar stream local
      await _peerConnection!.addStream(_localStream!);
      
      // Criar offer
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      
      // Enviar offer
      _socket!.emit('video_call_offer', {
        'offer': offer.toMap(),
        'callerId': 'current_user_id', // TODO: Implementar getter do usuário atual
        'receiverId': receiverId,
      });
      
    } catch (e) {
      print('[VIDEO_CALL] Error starting call: $e');
      onError?.call('Erro ao iniciar chamada: $e');
    }
  }

  Future<void> acceptCall() async {
    try {
      _isCallActive = true;
      
      // Obter stream local
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': true,
      });
      
      _localRenderer.srcObject = _localStream;
      
      // Criar peer connection
      await _createPeerConnection();
      
      // Adicionar stream local
      await _peerConnection!.addStream(_localStream!);
      
      onCallAccepted?.call();
      
    } catch (e) {
      print('[VIDEO_CALL] Error accepting call: $e');
      onError?.call('Erro ao aceitar chamada: $e');
    }
  }

  Future<void> rejectCall() async {
    _socket!.emit('video_call_reject');
    onCallRejected?.call();
  }

  Future<void> _createPeerConnection() async {
    final configuration = <String, dynamic>{
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    };
    
    _peerConnection = await createPeerConnection(configuration);
    
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _socket!.emit('video_call_ice_candidate', {
        'candidate': candidate.toMap(),
      });
    };
    
    _peerConnection!.onAddStream = (MediaStream stream) {
      _remoteStream = stream;
      _remoteRenderer.srcObject = stream;
      onRemoteStreamReceived?.call(stream);
    };
  }

  Future<void> _handleOffer(Map<String, dynamic> data) async {
    try {
      final offer = RTCSessionDescription(
        data['offer']['sdp'],
        data['offer']['type'],
      );
      
      await _peerConnection!.setRemoteDescription(offer);
      
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      
      _socket!.emit('video_call_answer', {
        'answer': answer.toMap(),
      });
      
    } catch (e) {
      print('[VIDEO_CALL] Error handling offer: $e');
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    try {
      final answer = RTCSessionDescription(
        data['answer']['sdp'],
        data['answer']['type'],
      );
      
      await _peerConnection!.setRemoteDescription(answer);
      
    } catch (e) {
      print('[VIDEO_CALL] Error handling answer: $e');
    }
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> data) async {
    try {
      final candidate = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      );
      
      await _peerConnection!.addCandidate(candidate);
      
    } catch (e) {
      print('[VIDEO_CALL] Error handling ICE candidate: $e');
    }
  }

  Future<void> endCall() async {
    try {
      _isCallActive = false;
      _isMuted = false;
      _isVideoEnabled = true;
      _isSpeakerOn = false;
      
      _localStream?.dispose();
      _remoteStream?.dispose();
      _peerConnection?.dispose();
      
      _localStream = null;
      _remoteStream = null;
      _peerConnection = null;
      
      _socket?.emit('video_call_end');
      
      onCallEnded?.call();
      
    } catch (e) {
      print('[VIDEO_CALL] Error ending call: $e');
    }
  }

  Future<void> dispose() async {
    await endCall();
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
    _socket?.disconnect();
  }

  Future<void> toggleMute() async {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        audioTracks.first.enabled = _isMuted;
        _isMuted = !_isMuted;
      }
    }
  }

  Future<void> toggleVideo() async {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        videoTracks.first.enabled = !_isVideoEnabled;
        _isVideoEnabled = !_isVideoEnabled;
      }
    }
  }

  Future<void> toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    // Implementar lógica de speaker aqui
  }
}