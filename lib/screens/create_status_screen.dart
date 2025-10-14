// screens/create_status_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import '../models/status_update.dart';
import '../services/status_service.dart';
import '../services/voice_recording_service.dart';
import '../service_locator.dart';

class CreateStatusScreen extends StatefulWidget {
  const CreateStatusScreen({Key? key}) : super(key: key);

  @override
  State<CreateStatusScreen> createState() => _CreateStatusScreenState();
}

class _CreateStatusScreenState extends State<CreateStatusScreen> {
  final StatusService _statusService = locator<StatusService>();
  final VoiceRecordingService _voiceService = locator<VoiceRecordingService>();
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  StatusType _selectedType = StatusType.text;
  String? _mediaPath;
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isUploading = false;

  @override
  void dispose() {
    _textController.dispose();
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Criar Status',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_canPublish())
            TextButton(
              onPressed: _isUploading ? null : _publishStatus,
              child: Text(
                'Publicar',
                style: TextStyle(
                  color: _isUploading ? Colors.grey : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildTypeSelector(),
          Expanded(
            child: _buildContent(),
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTypeButton(StatusType.text, Icons.text_fields, 'Texto'),
          _buildTypeButton(StatusType.image, Icons.image, 'Foto'),
          _buildTypeButton(StatusType.video, Icons.videocam, 'Vídeo'),
          _buildTypeButton(StatusType.audio, Icons.mic, 'Áudio'),
        ],
      ),
    );
  }

  Widget _buildTypeButton(StatusType type, IconData icon, String label) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _mediaPath = null;
          _videoController?.dispose();
          _audioPlayer?.dispose();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedType) {
      case StatusType.text:
        return _buildTextContent();
      case StatusType.image:
        return _buildImageContent();
      case StatusType.video:
        return _buildVideoContent();
      case StatusType.audio:
        return _buildAudioContent();
    }
  }

  Widget _buildTextContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: TextField(
        controller: _textController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ),
        decoration: const InputDecoration(
          hintText: 'Digite seu status...',
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
          border: InputBorder.none,
        ),
        maxLines: null,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImageContent() {
    if (_mediaPath == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma imagem selecionada',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Selecionar Imagem'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Image.file(
        File(_mediaPath!),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_mediaPath == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_outlined,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum vídeo selecionado',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.videocam),
              label: const Text('Selecionar Vídeo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }

  Widget _buildAudioContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 24),
          if (_mediaPath == null) ...[
            const Text(
              'Grave um áudio para seu status',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startRecording,
              icon: const Icon(Icons.mic),
              label: const Text('Gravar Áudio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ] else ...[
            const Text(
              'Áudio gravado',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _playPauseAudio,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _deleteAudio,
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_selectedType == StatusType.image || _selectedType == StatusType.video)
            ElevatedButton.icon(
              onPressed: _mediaPath == null ? _pickMedia : _changeMedia,
              icon: const Icon(Icons.camera_alt),
              label: Text(_mediaPath == null ? 'Selecionar' : 'Trocar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
              ),
            ),
          if (_selectedType == StatusType.audio && _mediaPath == null)
            ElevatedButton.icon(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Parar' : 'Gravar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  bool _canPublish() {
    switch (_selectedType) {
      case StatusType.text:
        return _textController.text.trim().isNotEmpty;
      case StatusType.image:
      case StatusType.video:
      case StatusType.audio:
        return _mediaPath != null;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _mediaPath = image.path;
        });
      }
    } catch (e) {
      print('[CREATE_STATUS] Error picking image: $e');
      _showError('Erro ao selecionar imagem');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
      
      if (video != null) {
        setState(() {
          _mediaPath = video.path;
        });
        _initializeVideoPlayer();
      }
    } catch (e) {
      print('[CREATE_STATUS] Error picking video: $e');
      _showError('Erro ao selecionar vídeo');
    }
  }

  Future<void> _pickMedia() async {
    if (_selectedType == StatusType.image) {
      await _pickImage();
    } else if (_selectedType == StatusType.video) {
      await _pickVideo();
    }
  }

  Future<void> _changeMedia() async {
    await _pickMedia();
  }

  void _initializeVideoPlayer() {
    if (_mediaPath != null) {
      _videoController = VideoPlayerController.file(File(_mediaPath!));
      _videoController!.initialize().then((_) {
        setState(() {});
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      final success = await _voiceService.startRecording();
      
      if (success) {
        setState(() {
          _isRecording = true;
        });
      } else {
        _showError('Erro ao iniciar gravação');
      }
    } catch (e) {
      print('[CREATE_STATUS] Error starting recording: $e');
      _showError('Erro ao iniciar gravação');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _voiceService.stopRecording();
      
      if (path != null) {
        setState(() {
          _mediaPath = path;
          _isRecording = false;
        });
      } else {
        _showError('Erro ao parar gravação');
      }
    } catch (e) {
      print('[CREATE_STATUS] Error stopping recording: $e');
      _showError('Erro ao parar gravação');
    }
  }

  Future<void> _playPauseAudio() async {
    if (_audioPlayer == null) {
      _audioPlayer = AudioPlayer();
    }

    if (_isPlaying) {
      await _audioPlayer!.pause();
    } else {
      await _audioPlayer!.play(DeviceFileSource(_mediaPath!));
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _deleteAudio() {
    setState(() {
      _mediaPath = null;
      _isPlaying = false;
    });
    _audioPlayer?.dispose();
    _audioPlayer = null;
  }

  Future<void> _publishStatus() async {
    if (!_canPublish()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String content = '';
      int? duration;

      switch (_selectedType) {
        case StatusType.text:
          content = _textController.text.trim();
          break;
        case StatusType.image:
          content = 'Imagem';
          break;
        case StatusType.video:
          content = 'Vídeo';
          duration = _videoController?.value.duration?.inSeconds;
          break;
        case StatusType.audio:
          content = 'Áudio';
          // Obter duração do áudio
          break;
      }

      final status = await _statusService.createStatus(
        content: content,
        type: _selectedType,
        mediaPath: _mediaPath,
        duration: duration,
      );

      if (status != null) {
        Navigator.pop(context, true);
        _showSuccess('Status publicado com sucesso!');
      } else {
        _showError('Erro ao publicar status');
      }
    } catch (e) {
      print('[CREATE_STATUS] Error publishing status: $e');
      _showError('Erro ao publicar status');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}