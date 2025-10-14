import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import '../models/message.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isMe ? const Color(0xFF25D366) : const Color(0xFF2A3942),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.message.type) {
      case MessageType.image:
        return _buildImageMessage(context);
      case MessageType.video:
        return _buildVideoMessage(context);
      case MessageType.file:
        return _buildFileMessage(context);
      case MessageType.audio:
        return _buildAudioMessage(context);
      case MessageType.text:
      default:
        return _buildTextMessage(context);
    }
  }

  Widget _buildTextMessage(BuildContext context) {
    return Text(
      widget.message.content,
      style: TextStyle(
        color: widget.isMe ? Colors.white : Colors.white,
        fontSize: 16,
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.message.mediaUrl != null && widget.message.mediaUrl!.isNotEmpty)
          GestureDetector(
            onTap: () => _showImagePreview(context, widget.message.mediaUrl!),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 200,
                maxWidth: 250,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.message.mediaUrl!.startsWith('http')
                    ? Image.network(
                        widget.message.mediaUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            width: 250,
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: 250,
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(Icons.error, color: Colors.white),
                            ),
                          );
                        },
                      )
                    : Image.file(
                        File(widget.message.mediaUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: 250,
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(Icons.error, color: Colors.white),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        if (widget.message.fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.message.fileName!,
              style: TextStyle(
                color: widget.isMe ? Colors.white70 : Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.message.mediaUrl != null && widget.message.mediaUrl!.isNotEmpty)
          GestureDetector(
            onTap: () => _showVideoPreview(context, widget.message.mediaUrl!),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 200,
                maxWidth: 250,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      width: 250,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.play_circle_filled, color: Colors.white, size: 50),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Vídeo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (widget.message.fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.message.fileName!,
              style: TextStyle(
                color: widget.isMe ? Colors.white70 : Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFileMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_file,
              color: widget.isMe ? Colors.white70 : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.message.fileName ?? 'Arquivo',
                style: TextStyle(
                  color: widget.isMe ? Colors.white : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.download,
                color: widget.isMe ? Colors.white70 : Colors.white70,
              ),
              onPressed: () => _downloadFile(),
            ),
          ],
        ),
        if (widget.message.fileSize != null)
          Text(
            _formatFileSize(widget.message.fileSize!),
            style: TextStyle(
              color: widget.isMe ? Colors.white60 : Colors.white60,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildAudioMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.grey[200] : Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.audiotrack,
                color: widget.isMe ? Colors.black54 : Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.message.fileName ?? 'Mensagem de voz',
                  style: TextStyle(
                    color: widget.isMe ? Colors.black : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: widget.isMe ? Colors.black54 : Colors.white70,
                ),
                onPressed: _toggleAudioPlayback,
              ),
            ],
          ),
          if (_duration.inMilliseconds > 0) ...[
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: widget.isMe ? Colors.blue : Colors.green,
                inactiveTrackColor: widget.isMe ? Colors.grey[300] : Colors.grey[600],
                thumbColor: widget.isMe ? Colors.blue : Colors.green,
                overlayColor: widget.isMe ? Colors.blue.withOpacity(0.2) : Colors.green.withOpacity(0.2),
              ),
              child: Slider(
                value: _position.inMilliseconds.toDouble(),
                max: _duration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: TextStyle(
                    color: widget.isMe ? Colors.black54 : Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: TextStyle(
                    color: widget.isMe ? Colors.black54 : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _downloadFile() async {
    if (widget.message.mediaUrl == null || widget.message.mediaUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arquivo não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = widget.message.fileName ?? 'arquivo';
      final filePath = '${downloadsDir.path}/$fileName';

      if (widget.message.mediaUrl!.startsWith('http')) {
        // Download from URL
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download de URL não implementado ainda'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Copy local file
        final sourceFile = File(widget.message.mediaUrl!);
        if (await sourceFile.exists()) {
          await sourceFile.copy(filePath);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Arquivo baixado: $fileName'),
              backgroundColor: const Color(0xFF25D366),
              action: SnackBarAction(
                label: 'Abrir pasta',
                onPressed: () {
                  Process.run('explorer', [downloadsDir.path]);
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Arquivo não encontrado localmente'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao baixar arquivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao baixar arquivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleAudioPlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        if (widget.message.mediaUrl != null && widget.message.mediaUrl!.isNotEmpty) {
          // Se é um arquivo local
          if (!widget.message.mediaUrl!.startsWith('http')) {
            await _audioPlayer.play(DeviceFileSource(widget.message.mediaUrl!));
          } else {
            // Se é uma URL
            await _audioPlayer.play(UrlSource(widget.message.mediaUrl!));
          }
          setState(() {
            _isPlaying = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Arquivo de áudio não encontrado'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao reproduzir áudio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao reproduzir áudio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Preview', style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
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
                : Image.file(
                    File(imageUrl),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Erro ao carregar imagem',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  void _showVideoPreview(BuildContext context, String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Vídeo', style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: videoUrl.startsWith('http')
                ? const Center(
                    child: Text(
                      'Reprodução de vídeo online não implementada',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : const Center(
                    child: Text(
                      'Reprodução de vídeo local não implementada',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}