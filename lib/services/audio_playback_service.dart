// services/audio_playback_service.dart
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioPlaybackService {
  static final AudioPlaybackService _instance = AudioPlaybackService._internal();
  factory AudioPlaybackService() => _instance;
  AudioPlaybackService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isPaused = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _currentAudioPath;

  // Callbacks
  Function(Duration)? onPositionChanged;
  Function(Duration)? onDurationChanged;
  Function(bool)? onPlayingStateChanged;
  Function(String)? onPlaybackError;
  Function()? onPlaybackCompleted;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String? get currentAudioPath => _currentAudioPath;

  Future<void> initialize() async {
    // Configurar listeners
    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      onPositionChanged?.call(position);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      onDurationChanged?.call(duration);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case PlayerState.playing:
          _isPlaying = true;
          _isPaused = false;
          onPlayingStateChanged?.call(true);
          break;
        case PlayerState.paused:
          _isPlaying = false;
          _isPaused = true;
          onPlayingStateChanged?.call(false);
          break;
        case PlayerState.stopped:
          _isPlaying = false;
          _isPaused = false;
          onPlayingStateChanged?.call(false);
          break;
        case PlayerState.completed:
          _isPlaying = false;
          _isPaused = false;
          onPlaybackCompleted?.call();
          break;
        case PlayerState.disposed:
          _isPlaying = false;
          _isPaused = false;
          break;
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _isPaused = false;
      onPlaybackCompleted?.call();
    });
  }

  Future<bool> playAudio(String audioPath) async {
    try {
      _currentAudioPath = audioPath;
      
      // Parar reprodução atual se houver
      if (_isPlaying || _isPaused) {
        await stopAudio();
      }

      // Configurar player
      await _audioPlayer.setSource(DeviceFileSource(audioPath));
      
      // Iniciar reprodução
      await _audioPlayer.resume();
      
      print('[AUDIO] Playing audio: $audioPath');
      return true;

    } catch (e) {
      print('[AUDIO] Error playing audio: $e');
      onPlaybackError?.call('Erro ao reproduzir áudio: $e');
      return false;
    }
  }

  Future<bool> playFromUrl(String url) async {
    try {
      _currentAudioPath = url;
      
      // Parar reprodução atual se houver
      if (_isPlaying || _isPaused) {
        await stopAudio();
      }

      // Configurar player
      await _audioPlayer.setSource(UrlSource(url));
      
      // Iniciar reprodução
      await _audioPlayer.resume();
      
      print('[AUDIO] Playing audio from URL: $url');
      return true;

    } catch (e) {
      print('[AUDIO] Error playing audio from URL: $e');
      onPlaybackError?.call('Erro ao reproduzir áudio: $e');
      return false;
    }
  }

  Future<bool> pauseAudio() async {
    try {
      if (!_isPlaying) return false;

      await _audioPlayer.pause();
      print('[AUDIO] Audio paused');
      return true;

    } catch (e) {
      print('[AUDIO] Error pausing audio: $e');
      return false;
    }
  }

  Future<bool> resumeAudio() async {
    try {
      if (!_isPaused) return false;

      await _audioPlayer.resume();
      print('[AUDIO] Audio resumed');
      return true;

    } catch (e) {
      print('[AUDIO] Error resuming audio: $e');
      return false;
    }
  }

  Future<bool> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _currentPosition = Duration.zero;
      _currentAudioPath = null;
      print('[AUDIO] Audio stopped');
      return true;

    } catch (e) {
      print('[AUDIO] Error stopping audio: $e');
      return false;
    }
  }

  Future<bool> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      print('[AUDIO] Seeked to: $position');
      return true;

    } catch (e) {
      print('[AUDIO] Error seeking: $e');
      return false;
    }
  }

  Future<bool> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
      print('[AUDIO] Volume set to: $volume');
      return true;

    } catch (e) {
      print('[AUDIO] Error setting volume: $e');
      return false;
    }
  }

  Future<bool> setPlaybackSpeed(double speed) async {
    try {
      await _audioPlayer.setPlaybackRate(speed.clamp(0.25, 2.0));
      print('[AUDIO] Playback speed set to: $speed');
      return true;

    } catch (e) {
      print('[AUDIO] Error setting playback speed: $e');
      return false;
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  Future<void> dispose() async {
    await stopAudio();
    await _audioPlayer.dispose();
  }
}
