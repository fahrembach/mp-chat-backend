import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/audio_playback_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final String? audioUrl;
  final bool showControls;
  final bool autoPlay;
  final Color? primaryColor;
  final Color? secondaryColor;

  const AudioPlayerWidget({
    Key? key,
    required this.audioPath,
    this.audioUrl,
    this.showControls = true,
    this.autoPlay = false,
    this.primaryColor,
    this.secondaryColor,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlaybackService _audioService = GetIt.instance<AudioPlaybackService>();
  
  bool _isPlaying = false;
  bool _isPaused = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  Timer? _positionTimer;

  @override
  void initState() {
    super.initState();
    _setupAudioService();
    
    if (widget.autoPlay) {
      _playAudio();
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    super.dispose();
  }

  void _setupAudioService() {
    _audioService.onPlayingStateChanged = (bool isPlaying) {
      if (mounted) {
        setState(() {
          _isPlaying = isPlaying;
          _isPaused = !isPlaying && _audioService.isPaused;
        });
      }
    };

    _audioService.onPositionChanged = (Duration position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    };

    _audioService.onDurationChanged = (Duration duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    };

    _audioService.onPlaybackCompleted = () {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
          _currentPosition = Duration.zero;
        });
      }
    };

    _audioService.onPlaybackError = (String error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    };
  }

  Future<void> _playAudio() async {
    bool success;
    if (widget.audioUrl != null) {
      success = await _audioService.playFromUrl(widget.audioUrl!);
    } else {
      success = await _audioService.playAudio(widget.audioPath);
    }
    
    if (success) {
      _startPositionTimer();
    }
  }

  Future<void> _pauseAudio() async {
    await _audioService.pauseAudio();
    _positionTimer?.cancel();
  }

  Future<void> _resumeAudio() async {
    await _audioService.resumeAudio();
    _startPositionTimer();
  }

  Future<void> _stopAudio() async {
    await _audioService.stopAudio();
    _positionTimer?.cancel();
    setState(() {
      _currentPosition = Duration.zero;
    });
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _currentPosition = _audioService.currentPosition;
        });
      }
    });
  }

  Future<void> _seekTo(double value) async {
    final position = Duration(
      milliseconds: (value * _totalDuration.inMilliseconds).round(),
    );
    await _audioService.seekTo(position);
  }

  Future<void> _setVolume(double value) async {
    await _audioService.setVolume(value);
    setState(() {
      _volume = value;
    });
  }

  Future<void> _setPlaybackSpeed(double value) async {
    await _audioService.setPlaybackSpeed(value);
    setState(() {
      _playbackSpeed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? Theme.of(context).primaryColor;
    final secondaryColor = widget.secondaryColor ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Controles principais
          Row(
            children: [
              // Botão play/pause
              IconButton(
                onPressed: _isPlaying ? _pauseAudio : _resumeAudio,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: primaryColor,
                  size: 32,
                ),
              ),

              // Botão stop
              IconButton(
                onPressed: _stopAudio,
                icon: Icon(
                  Icons.stop,
                  color: secondaryColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Informações do áudio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDuration(_currentPosition),
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(_totalDuration),
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Velocidade de reprodução
              PopupMenuButton<double>(
                onSelected: _setPlaybackSpeed,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                  const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                  const PopupMenuItem(value: 1.0, child: Text('1.0x')),
                  const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                  const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_playbackSpeed}x',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Barra de progresso
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: primaryColor,
              inactiveTrackColor: secondaryColor.withOpacity(0.3),
              thumbColor: primaryColor,
              overlayColor: primaryColor.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _totalDuration.inMilliseconds > 0
                  ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                  : 0.0,
              onChanged: _seekTo,
            ),
          ),

          if (widget.showControls) ...[
            const SizedBox(height: 12),

            // Controles de volume
            Row(
              children: [
                Icon(
                  Icons.volume_down,
                  color: secondaryColor,
                  size: 20,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: secondaryColor,
                      inactiveTrackColor: secondaryColor.withOpacity(0.3),
                      thumbColor: secondaryColor,
                      trackHeight: 2,
                    ),
                    child: Slider(
                      value: _volume,
                      onChanged: _setVolume,
                    ),
                  ),
                ),
                Icon(
                  Icons.volume_up,
                  color: secondaryColor,
                  size: 20,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}