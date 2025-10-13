// widgets/voice_recording_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/voice_recording_service.dart';

class VoiceRecordingWidget extends StatefulWidget {
  final Function(String)? onRecordingCompleted;
  final Function()? onRecordingCancelled;
  final Function(String)? onRecordingError;

  const VoiceRecordingWidget({
    Key? key,
    this.onRecordingCompleted,
    this.onRecordingCancelled,
    this.onRecordingError,
  }) : super(key: key);

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  final VoiceRecordingService _recordingService = VoiceRecordingService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  Duration _recordingDuration = Duration.zero;
  bool _isRecording = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupRecordingService();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupRecordingService() {
    _recordingService.onRecordingDurationChanged = (duration) {
      setState(() {
        _recordingDuration = duration;
      });
    };

    _recordingService.onRecordingCompleted = (path) {
      widget.onRecordingCompleted?.call(path);
      _stopRecording();
    };

    _recordingService.onRecordingError = (error) {
      widget.onRecordingError?.call(error);
      _stopRecording();
    };
  }

  Future<void> _startRecording() async {
    final success = await _recordingService.startRecording();
    if (success) {
      setState(() {
        _isRecording = true;
        _isPaused = false;
      });
      _animationController.repeat(reverse: true);
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _stopRecording() async {
    await _recordingService.stopRecording();
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _recordingDuration = Duration.zero;
    });
    _animationController.stop();
    _animationController.reset();
  }

  Future<void> _cancelRecording() async {
    await _recordingService.cancelRecording();
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _recordingDuration = Duration.zero;
    });
    _animationController.stop();
    _animationController.reset();
    widget.onRecordingCancelled?.call();
  }

  Future<void> _pauseRecording() async {
    final success = await _recordingService.pauseRecording();
    if (success) {
      setState(() {
        _isPaused = true;
      });
      _animationController.stop();
    }
  }

  Future<void> _resumeRecording() async {
    final success = await _recordingService.resumeRecording();
    if (success) {
      setState(() {
        _isPaused = false;
      });
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recordingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de gravação
          if (_isRecording) ...[
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Duração da gravação
            Text(
              _recordingService.formatDuration(_recordingDuration),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Controles de gravação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancelar
                IconButton(
                  onPressed: _cancelRecording,
                  icon: const Icon(Icons.close, color: Colors.red),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    padding: const EdgeInsets.all(15),
                  ),
                ),
                
                // Pausar/Retomar
                IconButton(
                  onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                  icon: Icon(
                    _isPaused ? Icons.play_arrow : Icons.pause,
                    color: Colors.orange,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    padding: const EdgeInsets.all(15),
                  ),
                ),
                
                // Parar
                IconButton(
                  onPressed: _stopRecording,
                  icon: const Icon(Icons.stop, color: Colors.green),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    padding: const EdgeInsets.all(15),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Botão de iniciar gravação
            GestureDetector(
              onTap: _startRecording,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Toque para gravar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Mantenha pressionado para gravar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
