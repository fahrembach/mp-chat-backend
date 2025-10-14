import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import '../models/user.dart';
import '../models/call.dart';
import '../services/video_call_service.dart';
import '../services/call_service.dart';

class VideoCallScreen extends StatefulWidget {
  final User? caller;
  final User? receiver;
  final Call? call;
  final bool isIncoming;

  const VideoCallScreen({
    Key? key,
    this.caller,
    this.receiver,
    this.call,
    this.isIncoming = false,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final VideoCallService _videoCallService = VideoCallService();
  final CallService _callService = GetIt.instance<CallService>();
  
  Timer? _callTimer;
  int _callDuration = 0;
  bool _isLocalVideoEnabled = true;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCallActive = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoCall();
    _setupCallbacks();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _videoCallService.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initializeVideoCall() async {
    await _videoCallService.initialize();
    
    if (widget.isIncoming) {
      // Chamada recebida - aguardar ação do usuário
    } else {
      // Chamada iniciada
      if (widget.receiver != null) {
        await _videoCallService.startVideoCall(widget.receiver!.id);
      }
    }
  }

  void _setupCallbacks() {
    _videoCallService.onCallAccepted = () {
      setState(() {
        _isCallActive = true;
      });
      _startCallTimer();
    };

    _videoCallService.onCallRejected = () {
      _endCall();
    };

    _videoCallService.onCallEnded = () {
      _endCall();
    };

    _videoCallService.onMuteChanged = (bool isMuted) {
      setState(() {
        _isMuted = isMuted;
      });
    };

    _videoCallService.onVideoChanged = (bool isVideoEnabled) {
      setState(() {
        _isLocalVideoEnabled = isVideoEnabled;
      });
    };

    _videoCallService.onSpeakerChanged = (bool isSpeakerOn) {
      setState(() {
        _isSpeakerOn = isSpeakerOn;
      });
    };
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration++;
      });
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    _videoCallService.endVideoCall();
    Navigator.of(context).pop();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Vídeo remoto (tela principal)
            Positioned.fill(
              child: _videoCallService.remoteStream != null
                  ? RTCVideoView(
                      _videoCallService.remoteRenderer,
                      mirror: false,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  : Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[700],
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              widget.isIncoming 
                                  ? widget.caller?.name ?? 'Chamada recebida'
                                  : widget.receiver?.name ?? 'Chamando...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.isIncoming 
                                  ? 'Chamada de vídeo recebida'
                                  : 'Conectando...',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Vídeo local (picture-in-picture)
            if (_videoCallService.localStream != null)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: RTCVideoView(
                      _videoCallService.localRenderer,
                      mirror: true,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
              ),

            // Informações da chamada
            Positioned(
              top: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isIncoming 
                        ? widget.caller?.name ?? 'Chamada recebida'
                        : widget.receiver?.name ?? 'Chamando...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isCallActive)
                    Text(
                      _formatDuration(_callDuration),
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),

            // Controles da chamada
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botão mute/unmute
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    backgroundColor: _isMuted ? Colors.red : Colors.grey[700]!,
                    onPressed: () async {
                      await _videoCallService.toggleMute();
                    },
                  ),

                  // Botão ligar/desligar vídeo
                  _buildControlButton(
                    icon: _isLocalVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    backgroundColor: _isLocalVideoEnabled ? Colors.grey[700]! : Colors.red,
                    onPressed: () async {
                      await _videoCallService.toggleVideo();
                    },
                  ),

                  // Botão speaker
                  _buildControlButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    backgroundColor: _isSpeakerOn ? Colors.blue : Colors.grey[700]!,
                    onPressed: () async {
                      await _videoCallService.toggleSpeaker();
                    },
                  ),

                  // Botão encerrar chamada
                  _buildControlButton(
                    icon: Icons.call_end,
                    backgroundColor: Colors.red,
                    onPressed: _endCall,
                  ),
                ],
              ),
            ),

            // Botões para chamada recebida
            if (widget.isIncoming && !_isCallActive)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botão rejeitar
                    _buildControlButton(
                      icon: Icons.call_end,
                      backgroundColor: Colors.red,
                      onPressed: () {
                        _videoCallService.rejectVideoCall();
                        Navigator.of(context).pop();
                      },
                    ),

                    // Botão aceitar
                    _buildControlButton(
                      icon: Icons.call,
                      backgroundColor: Colors.green,
                      onPressed: () async {
                        await _videoCallService.acceptVideoCall();
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

