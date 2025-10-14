import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'socket_service.dart';
import '../models/call.dart';
import 'call_history_service.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  // Armazenar descrições localmente
  RTCSessionDescription? _localOffer;
  RTCSessionDescription? _localAnswer;
  
  // Socket service para sinalização
  SocketService? _socketService;
  CallHistoryService? _callHistoryService;
  
  bool _isInCall = false;
  bool _isCallActive = false;
  String? _currentCallId;
  String? _currentPeerId;
  String? _currentUserId;
  String? _currentReceiverId;
  CallType _currentCallType = CallType.audio;
  
  // Callbacks
  Function(MediaStream)? onRemoteStream;
  Function()? onCallEnded;
  Function(String)? onCallError;
  
  // Getters
  bool get isInCall => _isInCall;
  bool get isCallActive => _isCallActive;
  String? get currentCallId => _currentCallId;
  String? get currentPeerId => _currentPeerId;
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  Future<void> initialize() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  // Configurar serviço de histórico
  void setCallHistoryService(CallHistoryService callHistoryService) {
    _callHistoryService = callHistoryService;
  }

  // Definir ID do usuário atual
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  // Configurar listeners do SocketService para receber chamadas
  void setupSocketListeners(SocketService socketService) {
    socketService.onCallOffer = (data) async {
      print('[CALL] Received call offer: $data');
      final String callerId = data['callerId'];
      final String callId = data['callId'];
      final Map<String, dynamic> offer = data['offer'];
      
      _currentCallId = callId;
      _currentPeerId = callerId;
      _isInCall = true;
      
      // Configurar WebRTC
      await _setupPeerConnection();
      
      // Obter stream de mídia local
      _localStream = await _getUserMedia();
      _localRenderer.srcObject = _localStream;
      
      // Adicionar stream local ao peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
      
      // Definir oferta remota
      RTCSessionDescription offerDesc = RTCSessionDescription(
        offer['sdp'],
        offer['type'],
      );
      await _peerConnection!.setRemoteDescription(offerDesc);
      
      // Criar resposta
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _localAnswer = answer;
      
      // Enviar resposta via socket
      socketService.sendCallAnswer(callerId, callId, {
        'sdp': answer.sdp,
        'type': answer.type,
      });
      
      print('[CALL] Call answered for $callerId');
    };

    socketService.onCallAnswer = (data) async {
      print('[CALL] Received call answer: $data');
      final Map<String, dynamic> answer = data['answer'];
      
      RTCSessionDescription answerDesc = RTCSessionDescription(
        answer['sdp'],
        answer['type'],
      );
      await _peerConnection!.setRemoteDescription(answerDesc);
      print('[CALL] Remote description set');
    };

    socketService.onIceCandidate = (data) async {
      print('[CALL] Received ICE candidate: $data');
      final Map<String, dynamic> candidate = data['candidate'];
      
      RTCIceCandidate iceCandidate = RTCIceCandidate(
        candidate['candidate'],
        candidate['sdpMid'],
        candidate['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(iceCandidate);
      print('[CALL] ICE candidate added');
    };

    socketService.onCallEnd = (data) {
      print('[CALL] Received call end: $data');
      endCall();
      onCallEnded?.call();
    };
  }

  Future<void> dispose() async {
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
    await _peerConnection?.close();
    _localStream?.dispose();
    _remoteStream?.dispose();
  }

  Future<void> startCall(String peerId, String callId, {SocketService? socketService, bool isVideo = false}) async {
    try {
      _currentPeerId = peerId;
      _currentCallId = callId;
      _currentReceiverId = peerId;
      _currentCallType = isVideo ? CallType.video : CallType.audio;
      _isInCall = true;
      _socketService = socketService;
      
      // Registrar chamada no histórico
      if (_callHistoryService != null && _currentUserId != null) {
        await _callHistoryService!.recordCall(
          callerId: _currentUserId!,
          receiverId: peerId,
          type: _currentCallType,
          status: CallStatus.outgoing,
        );
      }
      
      // Configurar WebRTC
      await _setupPeerConnection();
      
      // Obter stream de mídia local
      _localStream = await _getUserMedia(isVideo: isVideo);
      _localRenderer.srcObject = _localStream;
      
      // Adicionar stream local ao peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
      
      // Criar oferta
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      _localOffer = offer; // Armazenar localmente
      
      // Enviar oferta via socket
      if (_socketService != null) {
        _socketService!.sendCallOffer(peerId, callId, {
          'sdp': offer.sdp,
          'type': offer.type,
        });
      }
      
      print('[CALL] Call started with $peerId');
      
    } catch (e) {
      print('[CALL] Error starting call: $e');
      onCallError?.call('Erro ao iniciar chamada: $e');
    }
  }

  Future<void> answerCall(String peerId, String callId, Map<String, dynamic> offerData, {SocketService? socketService, bool isVideo = false}) async {
    try {
      _currentPeerId = peerId;
      _currentCallId = callId;
      _currentReceiverId = peerId;
      _currentCallType = isVideo ? CallType.video : CallType.audio;
      _isInCall = true;
      _socketService = socketService;
      
      // Registrar chamada no histórico
      if (_callHistoryService != null && _currentUserId != null) {
        await _callHistoryService!.recordCall(
          callerId: peerId,
          receiverId: _currentUserId!,
          type: _currentCallType,
          status: CallStatus.incoming,
        );
      }
      
      // Configurar WebRTC
      await _setupPeerConnection();
      
      // Obter stream de mídia local
      _localStream = await _getUserMedia(isVideo: isVideo);
      _localRenderer.srcObject = _localStream;
      
      // Adicionar stream local ao peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
      
      // Definir oferta remota
      RTCSessionDescription offer = RTCSessionDescription(
        offerData['sdp'],
        offerData['type'],
      );
      await _peerConnection!.setRemoteDescription(offer);
      
      // Criar resposta
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _localAnswer = answer; // Armazenar localmente
      
      // Enviar resposta via socket
      if (_socketService != null) {
        _socketService!.sendCallAnswer(peerId, callId, {
          'sdp': answer.sdp,
          'type': answer.type,
        });
      }
      
      print('[CALL] Call answered for $peerId');
      
    } catch (e) {
      print('[CALL] Error answering call: $e');
      onCallError?.call('Erro ao atender chamada: $e');
    }
  }

  Future<void> endCall() async {
    try {
      _isInCall = false;
      _isCallActive = false;
      
      // Atualizar status da chamada no histórico
      if (_callHistoryService != null && _currentCallId != null) {
        await _callHistoryService!.updateCallStatus(_currentCallId!, CallStatus.ended);
      }
      
      // Enviar sinal de fim via socket
      if (_socketService != null && _currentPeerId != null && _currentCallId != null) {
        _socketService!.sendCallEnd(_currentPeerId!, _currentCallId!);
      }
      
      await _peerConnection?.close();
      _localStream?.dispose();
      _remoteStream?.dispose();
      
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
      
      _currentCallId = null;
      _currentPeerId = null;
      _currentReceiverId = null;
      
      // Limpar descrições
      _localOffer = null;
      _localAnswer = null;
      
      onCallEnded?.call();
      print('[CALL] Call ended');
      
    } catch (e) {
      print('[CALL] Error ending call: $e');
    }
  }

  Future<void> _setupPeerConnection() async {
    final configuration = <String, dynamic>{
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    };

    _peerConnection = await createPeerConnection(configuration);

    // Configurar eventos
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      print('[CALL] ICE candidate: ${candidate.candidate}');
      // Enviar candidate via socket
      if (_socketService != null && _currentPeerId != null && _currentCallId != null) {
        _socketService!.sendIceCandidate(_currentPeerId!, _currentCallId!, {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }
    };

    _peerConnection!.onAddStream = (MediaStream stream) {
      print('[CALL] Remote stream received');
      _remoteStream = stream;
      _remoteRenderer.srcObject = stream;
      _isCallActive = true;
      onRemoteStream?.call(stream);
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('[CALL] Connection state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        endCall();
      }
    };
  }

  Future<MediaStream> _getUserMedia({bool isVideo = false}) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
        'sampleRate': 48000, // Qualidade alta
        'channelCount': 2,   // Estéreo
      },
      'video': isVideo ? {
        'width': {'min': 640, 'ideal': 1280, 'max': 1920},
        'height': {'min': 480, 'ideal': 720, 'max': 1080},
        'frameRate': {'min': 15, 'ideal': 30, 'max': 60},
        'facingMode': 'user', // Câmera frontal
      } : false,
    };

    return await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  // Métodos para troca de sinais via socket
  Map<String, dynamic>? getLocalDescription() {
    // Retornar a descrição local armazenada
    if (_localOffer != null) {
      return {
        'sdp': _localOffer!.sdp,
        'type': _localOffer!.type,
      };
    } else if (_localAnswer != null) {
      return {
        'sdp': _localAnswer!.sdp,
        'type': _localAnswer!.type,
      };
    }
    return null;
  }

  Future<void> setRemoteDescription(Map<String, dynamic> description) async {
    if (_peerConnection == null) return;
    
    RTCSessionDescription remoteDesc = RTCSessionDescription(
      description['sdp'],
      description['type'],
    );
    await _peerConnection!.setRemoteDescription(remoteDesc);
  }

  Future<void> addIceCandidate(Map<String, dynamic> candidateData) async {
    if (_peerConnection == null) return;
    
    RTCIceCandidate candidate = RTCIceCandidate(
      candidateData['candidate'],
      candidateData['sdpMid'],
      candidateData['sdpMLineIndex'],
    );
    await _peerConnection!.addCandidate(candidate);
  }
}
