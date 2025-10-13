// services/voice_recording_service.dart
import 'dart:io';
import 'dart:async';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class VoiceRecordingService {
  static final VoiceRecordingService _instance = VoiceRecordingService._internal();
  factory VoiceRecordingService() => _instance;
  VoiceRecordingService._internal();

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  // Callbacks
  Function(Duration)? onRecordingDurationChanged;
  Function(String)? onRecordingCompleted;
  Function(String)? onRecordingError;

  bool get isRecording => _isRecording;
  Duration get recordingDuration => _recordingDuration;
  String? get currentRecordingPath => _currentRecordingPath;

  Future<bool> requestPermissions() async {
    final microphonePermission = await Permission.microphone.request();
    final storagePermission = await Permission.storage.request();
    
    return microphonePermission.isGranted && storagePermission.isGranted;
  }

  Future<bool> startRecording() async {
    try {
      if (_isRecording) return false;

      // Verificar permissões
      if (!await requestPermissions()) {
        onRecordingError?.call('Permissões de microfone não concedidas');
        return false;
      }

      // Verificar se o microfone está disponível
      if (!await _audioRecorder.hasPermission()) {
        onRecordingError?.call('Microfone não disponível');
        return false;
      }

      // Criar diretório para gravações
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory(path.join(directory.path, 'recordings'));
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // Gerar nome do arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = path.join(recordingsDir.path, 'voice_$timestamp.m4a');

      // Configurações de gravação
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      );

      // Iniciar gravação
      await _audioRecorder.start(config, path: _currentRecordingPath!);
      _isRecording = true;
      _recordingDuration = Duration.zero;

      // Iniciar timer para atualizar duração
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(seconds: timer.tick);
        onRecordingDurationChanged?.call(_recordingDuration);
      });

      print('[VOICE] Recording started: $_currentRecordingPath');
      return true;

    } catch (e) {
      print('[VOICE] Error starting recording: $e');
      onRecordingError?.call('Erro ao iniciar gravação: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      // Parar gravação
      final path = await _audioRecorder.stop();
      _isRecording = false;
      _recordingTimer?.cancel();
      _recordingTimer = null;

      if (path != null && path.isNotEmpty) {
        _currentRecordingPath = path;
        print('[VOICE] Recording stopped: $path');
        onRecordingCompleted?.call(path);
        return path;
      } else {
        onRecordingError?.call('Erro ao parar gravação');
        return null;
      }

    } catch (e) {
      print('[VOICE] Error stopping recording: $e');
      onRecordingError?.call('Erro ao parar gravação: $e');
      return null;
    }
  }

  Future<bool> cancelRecording() async {
    try {
      if (!_isRecording) return false;

      // Cancelar gravação
      await _audioRecorder.cancel();
      _isRecording = false;
      _recordingTimer?.cancel();
      _recordingTimer = null;

      // Deletar arquivo se existir
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _currentRecordingPath = null;
      _recordingDuration = Duration.zero;
      print('[VOICE] Recording cancelled');
      return true;

    } catch (e) {
      print('[VOICE] Error cancelling recording: $e');
      return false;
    }
  }

  Future<bool> pauseRecording() async {
    try {
      if (!_isRecording) return false;

      await _audioRecorder.pause();
      _recordingTimer?.cancel();
      print('[VOICE] Recording paused');
      return true;

    } catch (e) {
      print('[VOICE] Error pausing recording: $e');
      return false;
    }
  }

  Future<bool> resumeRecording() async {
    try {
      if (_isRecording) return false;

      await _audioRecorder.resume();
      
      // Reiniciar timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(seconds: timer.tick);
        onRecordingDurationChanged?.call(_recordingDuration);
      });

      print('[VOICE] Recording resumed');
      return true;

    } catch (e) {
      print('[VOICE] Error resuming recording: $e');
      return false;
    }
  }

  Future<bool> deleteRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('[VOICE] Recording deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      print('[VOICE] Error deleting recording: $e');
      return false;
    }
  }

  Future<List<File>> getRecordings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory(path.join(directory.path, 'recordings'));
      
      if (!await recordingsDir.exists()) {
        return [];
      }

      final files = await recordingsDir.list().toList();
      final recordings = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.m4a') || file.path.endsWith('.wav'))
          .toList();

      // Ordenar por data de modificação (mais recentes primeiro)
      recordings.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      return recordings;
    } catch (e) {
      print('[VOICE] Error getting recordings: $e');
      return [];
    }
  }

  Future<Duration?> getRecordingDuration(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      // Usar flutter_sound para obter duração
      // Implementação simplificada - em produção usar flutter_sound
      return Duration.zero;
    } catch (e) {
      print('[VOICE] Error getting recording duration: $e');
      return null;
    }
  }

  Future<int?> getRecordingSize(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      
      return await file.length();
    } catch (e) {
      print('[VOICE] Error getting recording size: $e');
      return null;
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> dispose() async {
    if (_isRecording) {
      await cancelRecording();
    }
    _recordingTimer?.cancel();
    await _audioRecorder.dispose();
  }
}
