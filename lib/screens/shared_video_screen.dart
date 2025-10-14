// screens/shared_video_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/shared_video_service.dart';
import '../service_locator.dart';

class SharedVideoScreen extends StatefulWidget {
  final String videoUrl;
  final String videoType; // 'local' ou 'youtube'
  final List<String> participants;

  const SharedVideoScreen({
    Key? key,
    required this.videoUrl,
    required this.videoType,
    required this.participants,
  }) : super(key: key);

  @override
  State<SharedVideoScreen> createState() => _SharedVideoScreenState();
}

class _SharedVideoScreenState extends State<SharedVideoScreen> {
  late SharedVideoService _sharedVideoService;
  String? _sessionId;
  bool _isSessionActive = false;

  @override
  void initState() {
    super.initState();
    _sharedVideoService = locator<SharedVideoService>();
    _createSession();
  }

  Future<void> _createSession() async {
    final session = await _sharedVideoService.createSharedVideoSession(
      videoUrl: widget.videoUrl,
      videoType: widget.videoType,
      participants: widget.participants,
    );

    if (session != null) {
      setState(() {
        _sessionId = session['sessionId'];
        _isSessionActive = true;
      });
    }
  }

  Future<void> _endSession() async {
    if (_sessionId != null) {
      await _sharedVideoService.endSharedVideoSession(_sessionId!);
      setState(() {
        _isSessionActive = false;
      });
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Vídeo Compartilhado',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _endSession,
        ),
        actions: [
          if (_isSessionActive)
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.white),
              onPressed: _endSession,
            ),
        ],
      ),
      body: Column(
        children: [
          // Área do vídeo
          Expanded(
            child: _buildVideoPlayer(),
          ),
          // Controles
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              children: [
                Text(
                  'Participantes: ${widget.participants.length}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Implementar controle de play/pause
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play/Pause'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Implementar sincronização
                      },
                      icon: const Icon(Icons.sync),
                      label: const Text('Sincronizar'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _endSession,
                      icon: const Icon(Icons.stop),
                      label: const Text('Encerrar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (widget.videoType == 'youtube') {
      final videoId = _sharedVideoService.extractYouTubeVideoId(widget.videoUrl);
      if (videoId != null) {
        final embedUrl = _sharedVideoService.getYouTubeEmbedUrl(videoId);
        return WebView(
          initialUrl: embedUrl,
          javascriptMode: JavascriptMode.unrestricted,
        );
      }
    }

    // Para vídeos locais, mostrar placeholder
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam,
              color: Colors.white,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Reprodução de vídeo local',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Funcionalidade em desenvolvimento',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
