// widgets/audio_player_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/audio_playback_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final String? title;
  final Color? primaryColor;
  final Color? secondaryColor;

  const AudioPlayerWidget({
    Key? key,
    required this.audioPath,
    this.title,
    this.primaryColor,
    this.secondaryColor,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with TickerProviderStateMixin {
  final AudioPlaybackService _audioService = AudioPlaybackService();
  late AnimationController _waveformController;
  late Animation<double> _waveformAnimation;
  
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  bool _isPaused = false;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupAudioService();
    _loadAudio();
  }

  void _setupAnimations() {
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _waveformAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveformController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupAudioService() {
    _audioService.onPositionChanged = (position) {
      setState(() {
        _currentPosition = position;
      });
    };

    _audioService.onDurationChanged = (duration) {
      setState(() {
        _totalDuration = duration;
      });
    };

    _audioService.onPlayingStateChanged = (isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
        _isPaused = !isPlaying && _currentPosition > Duration.zero;
      });
      
      if (isPlaying) {
        _waveformController.repeat();
      } else {
        _waveformController.stop();
      }
    };

    _audioService.onPlaybackCompleted = () {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
        _currentPosition = Duration.zero;
      });
      _waveformController.stop();
    };

    _audioService.onPlaybackError = (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    };
  }

  Future<void> _loadAudio() async {
    await _audioService.initialize();
    await _audioService.playAudio(widget.audioPath);
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioService.pauseAudio();
    } else if (_isPaused) {
      await _audioService.resumeAudio();
    } else {
      await _audioService.playAudio(widget.audioPath);
    }
    HapticFeedback.lightImpact();
  }

  Future<void> _stop() async {
    await _audioService.stopAudio();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _currentPosition = Duration.zero;
    });
    _waveformController.stop();
  }

  Future<void> _seekTo(double position) async {
    final duration = Duration(
      milliseconds: (position * _totalDuration.inMilliseconds).round(),
    );
    await _audioService.seekTo(duration);
  }

  Future<void> _setVolume(double volume) async {
    setState(() {
      _volume = volume;
    });
    await _audioService.setVolume(volume);
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    setState(() {
      _playbackSpeed = speed;
    });
    await _audioService.setPlaybackSpeed(speed);
  }

  @override
  void dispose() {
    _waveformController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? Theme.of(context).primaryColor;
    final secondaryColor = widget.secondaryColor ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],

          // Waveform animado
          if (_isPlaying) ...[
            AnimatedBuilder(
              animation: _waveformAnimation,
              builder: (context, child) {
                return Container(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(20, (index) {
                      final height = (20 + (index % 3) * 10) * 
                          (0.5 + 0.5 * _waveformAnimation.value);
                      return Container(
                        width: 3,
                        height: height,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Barra de progresso
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: primaryColor,
                  inactiveTrackColor: secondaryColor.withOpacity(0.3),
                  thumbColor: primaryColor,
                  overlayColor: primaryColor.withOpacity(0.2),
                  trackHeight: 3,
                ),
                child: Slider(
                  value: _totalDuration.inMilliseconds > 0
                      ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                      : 0.0,
                  onChanged: _seekTo,
                ),
              ),
              
              // Tempos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _audioService.formatDuration(_currentPosition),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _audioService.formatDuration(_totalDuration),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Controles principais
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Parar
              IconButton(
                onPressed: _stop,
                icon: const Icon(Icons.stop),
                style: IconButton.styleFrom(
                  backgroundColor: secondaryColor.withOpacity(0.1),
                ),
              ),

              // Play/Pause
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _playPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              // Velocidade
              PopupMenuButton<double>(
                icon: Text(
                  '${_playbackSpeed}x',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onSelected: _setPlaybackSpeed,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                  const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                  const PopupMenuItem(value: 1.0, child: Text('1.0x')),
                  const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                  const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Controle de volume
          Row(
            children: [
              Icon(Icons.volume_down, color: secondaryColor),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: secondaryColor.withOpacity(0.3),
                    thumbColor: primaryColor,
                    trackHeight: 2,
                  ),
                  child: Slider(
                    value: _volume,
                    onChanged: _setVolume,
                  ),
                ),
              ),
              Icon(Icons.volume_up, color: secondaryColor),
            ],
          ),
        ],
      ),
    );
  }
}
