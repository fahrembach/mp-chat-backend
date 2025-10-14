// screens/status_viewer_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import '../models/status_update.dart';
import '../models/user.dart';

class StatusViewerScreen extends StatefulWidget {
  final User? user;
  final List<StatusUpdate> statuses;
  final Function(String) onStatusViewed;

  const StatusViewerScreen({
    Key? key,
    required this.user,
    required this.statuses,
    required this.onStatusViewed,
  }) : super(key: key);

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeMedia();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _initializeMedia() {
    final currentStatus = widget.statuses[_currentIndex];
    if (currentStatus.type == StatusType.video && currentStatus.mediaUrl != null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(currentStatus.mediaUrl!));
      _videoController!.initialize().then((_) {
        setState(() {});
      });
    } else if (currentStatus.type == StatusType.audio && currentStatus.mediaUrl != null) {
      _audioPlayer = AudioPlayer();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Marcar status como visualizado
    final status = widget.statuses[index];
    if (!status.isViewed) {
      widget.onStatusViewed(status.id);
    }
    
    // Reinicializar mídia
    _videoController?.dispose();
    _audioPlayer?.dispose();
    _initializeMedia();
  }

  void _playPauseMedia() {
    final currentStatus = widget.statuses[_currentIndex];
    
    if (currentStatus.type == StatusType.video && _videoController != null) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    } else if (currentStatus.type == StatusType.audio && _audioPlayer != null) {
      if (_isPlaying) {
        _audioPlayer!.pause();
      } else {
        _audioPlayer!.play(UrlSource(currentStatus.mediaUrl!));
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: widget.statuses.length,
                itemBuilder: (context, index) {
                  final status = widget.statuses[index];
                  return _buildStatusContent(status);
                },
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[700],
            child: widget.user?.avatar != null
                ? ClipOval(
                    child: Image.network(
                      widget.user!.avatar!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user?.name ?? 'Usuário',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatTime(widget.statuses[_currentIndex].createdAt),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusContent(StatusUpdate status) {
    switch (status.type) {
      case StatusType.text:
        return _buildTextStatus(status);
      case StatusType.image:
        return _buildImageStatus(status);
      case StatusType.video:
        return _buildVideoStatus(status);
      case StatusType.audio:
        return _buildAudioStatus(status);
    }
  }

  Widget _buildTextStatus(StatusUpdate status) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          status.content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildImageStatus(StatusUpdate status) {
    return Center(
      child: status.mediaUrl != null
          ? Image.network(
              status.mediaUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text(
                    'Erro ao carregar imagem',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                'Imagem não encontrada',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildVideoStatus(StatusUpdate status) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: _playPauseMedia,
      child: Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }

  Widget _buildAudioStatus(StatusUpdate status) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 80,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            status.content.isNotEmpty ? status.content : 'Áudio',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (status.duration != null)
            Text(
              _formatDuration(Duration(seconds: status.duration!)),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _playPauseMedia,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_currentIndex + 1} de ${widget.statuses.length}',
            style: const TextStyle(color: Colors.grey),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.reply, color: Colors.white),
                onPressed: () {
                  // Implementar resposta
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  _showStatusOptions();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('Informações', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showStatusInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Compartilhar', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Implementar compartilhamento
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusInfo() {
    final status = widget.statuses[_currentIndex];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Informações do Status', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Criado em: ${_formatDateTime(status.createdAt)}', style: const TextStyle(color: Colors.white)),
            Text('Visualizações: ${status.views}', style: const TextStyle(color: Colors.white)),
            if (status.expiresAt != null)
              Text('Expira em: ${_formatDateTime(status.expiresAt!)}', style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  String _formatDateTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} às ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
