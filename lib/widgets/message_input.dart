import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(String, String)? onSendMedia; // fileName, filePath
  final Function()? onSendVoice; // Para gravação de voz

  const MessageInput({
    super.key, 
    required this.onSendMessage,
    this.onSendMedia,
    this.onSendVoice,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  final _audioRecorder = AudioRecorder();
  String _enteredMessage = '';
  bool _isRecording = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;

  void _sendMessage() {
    FocusScope.of(context).unfocus();
    if (_enteredMessage.trim().isEmpty) {
      return;
    }
    widget.onSendMessage(_enteredMessage);
    _controller.clear();
    setState(() {
      _enteredMessage = '';
    });
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (widget.onSendMedia != null) {
          widget.onSendMedia!(file.name, file.path ?? '');
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (widget.onSendMedia != null) {
          widget.onSendMedia!(file.name, file.path ?? '');
        }
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Emojis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 64,
                itemBuilder: (context, index) {
                  final emojis = ['😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣',
                                '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰',
                                '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜',
                                '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏',
                                '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣',
                                '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠',
                                '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨',
                                '😰', '😥', '😓', '🤗', '🤔', '🤭', '🤫', '🤥'];
                  return GestureDetector(
                    onTap: () {
                      _controller.text += emojis[index];
                      setState(() {
                        _enteredMessage = _controller.text;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          emojis[index],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enviar mídia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaOption(
                  icon: Icons.photo,
                  label: 'Galeria',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                _buildMediaOption(
                  icon: Icons.attach_file,
                  label: 'Documento',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFile();
                  },
                ),
                _buildMediaOption(
                  icon: Icons.camera_alt,
                  label: 'Câmera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(); // Por enquanto usa a mesma função
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2A3942),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: Colors.white70,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startVoiceRecording() async {
    try {
      // Verificar permissões
      if (!await _audioRecorder.hasPermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de microfone necessária'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Obter diretório para salvar o arquivo
      final directory = await getApplicationDocumentsDirectory();
      final voiceDir = Directory('${directory.path}/voice_messages');
      if (!await voiceDir.exists()) {
        await voiceDir.create(recursive: true);
      }

      // Gerar nome do arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '${voiceDir.path}/voice_$timestamp.m4a';

      // Iniciar gravação
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath!,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      // Iniciar timer para duração
      _startRecordingTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gravação iniciada'),
          backgroundColor: Color(0xFF25D366),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Erro ao iniciar gravação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao iniciar gravação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopVoiceRecording() async {
    try {
      final path = await _audioRecorder.stop();
      
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });

      if (path != null && widget.onSendMedia != null) {
        // Enviar mensagem de voz
        final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        widget.onSendMedia!(fileName, path);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mensagem de voz enviada'),
            backgroundColor: Color(0xFF25D366),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Erro ao parar gravação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao parar gravação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startRecordingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording) {
        setState(() {
          _recordingDuration = Duration(seconds: _recordingDuration.inSeconds + 1);
        });
        _startRecordingTimer();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF1F2C34),
        border: Border(
          top: BorderSide(
            color: Color(0xFF2A3942),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Ícone de Emoji/Sticker
          GestureDetector(
            onTap: _showEmojiPicker,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.emoji_emotions_outlined,
                color: Colors.white60,
                size: 24,
              ),
            ),
          ),
          
          // Campo de texto
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A3942),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Mensagem',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _enteredMessage = value;
                        });
                      },
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  
                  // Ícone de anexo (clipe)
                  GestureDetector(
                    onTap: _showMediaOptions,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.attach_file,
                        color: Colors.white60,
                        size: 20,
                      ),
                    ),
                  ),
                  
                  // Ícone de câmera
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white60,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Botão de gravação de voz
          GestureDetector(
            onTap: _isRecording ? _stopVoiceRecording : _startVoiceRecording,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : const Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: _isRecording 
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.stop,
                        color: Colors.white,
                        size: 20,
                      ),
                      Text(
                        _formatDuration(_recordingDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 24,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}