import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../services/call_service.dart';
import '../models/user.dart';
import '../services/socket_service.dart';

class CallScreen extends StatefulWidget {
  final User peer;
  final bool isIncoming;
  final String callId;
  final SocketService? socketService;

  const CallScreen({
    Key? key,
    required this.peer,
    required this.isIncoming,
    required this.callId,
    this.socketService,
  }) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _callService.endCall();
    super.dispose();
  }

  Future<void> _initializeCall() async {
    await _callService.initialize();
    
    _callService.onCallEnded = () {
      if (mounted) {
        context.go('/');
      }
    };
    
    _callService.onCallError = (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    };

    if (!widget.isIncoming) {
      await _callService.startCall(widget.peer.id, widget.callId, socketService: widget.socketService);
      _startCallTimer();
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
      });
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isMuted ? 'Microfone silenciado' : 'Microfone ativado'),
        backgroundColor: const Color(0xFF25D366),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSpeakerOn ? 'Alto-falante ativado' : 'Alto-falante desativado'),
        backgroundColor: const Color(0xFF25D366),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header com informações da chamada
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    widget.isIncoming ? 'Chamada Recebida' : 'Chamando...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.peer.username,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_callService.isCallActive) ...[
                    SizedBox(height: 5),
                    Text(
                      _formatDuration(_callDuration),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Área principal
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar do usuário
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[800],
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white70,
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Status da chamada
                    Text(
                      widget.isIncoming 
                          ? 'Chamada recebida de ${widget.peer.username}'
                          : _callService.isCallActive 
                              ? 'Chamada em andamento'
                              : 'Conectando...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // Controles da chamada
            Container(
              padding: EdgeInsets.all(30),
              child: widget.isIncoming
                  ? _buildIncomingCallControls()
                  : _buildActiveCallControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Rejeitar
        _buildCallButton(
          icon: Icons.call_end,
          color: Colors.red,
          onPressed: () {
            _callService.endCall();
            if (mounted) {
              context.go('/');
            }
          },
        ),
        
        // Atender
        _buildCallButton(
          icon: Icons.call,
          color: Colors.green,
          onPressed: () async {
            await _callService.answerCall(widget.peer.id, widget.callId, {}, socketService: widget.socketService);
            _startCallTimer();
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildActiveCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Microfone
        _buildCallButton(
          icon: _isMuted ? Icons.mic_off : Icons.mic,
          color: _isMuted ? Colors.red : Colors.white,
          onPressed: () {
            setState(() {
              _isMuted = !_isMuted;
            });
            // TODO: Implementar mute/unmute
          },
        ),
        
        // Speaker
        _buildCallButton(
          icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
          color: _isSpeakerOn ? Colors.blue : Colors.white,
          onPressed: () {
            setState(() {
              _isSpeakerOn = !_isSpeakerOn;
            });
            // TODO: Implementar speaker on/off
          },
        ),
        
        // Encerrar
        _buildCallButton(
          icon: Icons.call_end,
          color: Colors.red,
          onPressed: () {
            _callService.endCall();
            if (mounted) {
              context.go('/');
            }
          },
        ),
      ],
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}
