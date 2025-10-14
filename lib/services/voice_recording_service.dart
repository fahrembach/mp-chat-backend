// services/voice_recording_service.dart
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
// import 'package:record/record.dart'; // Removed due to CMake issues

class VoiceRecordingService {
  static final VoiceRecordingService _instance = VoiceRecordingService._internal();
  factory VoiceRecordingService() => _instance;
  VoiceRecordingService._internal();

  // final AudioRecorder _audioRecorder = AudioRecorder(); // Removed due to CMake issues
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  String? _recordingPath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  bool _isRecording = false;
  bool _isPaused = false;

  // Getters
  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  Duration get recordingDuration => _recordingDuration;
  String? get recordingPath => _recordingPath;

  // Iniciar gravação
  Future<bool> startRecording() async {
    try {
      // Verificar permissões
      if (!await _checkPermissions()) {
        print('[VOICE_RECORDING] Permissions not granted');
        return false;
      }

      // Parar qualquer gravação anterior
      await stopRecording();

      // Obter diretório temporário
      final tempDir = await getTemporaryDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _recordingPath = path.join(tempDir.path, fileName);

      // Simular início da gravação
      _isRecording = true;
      _isPaused = false;
      _recordingDuration = Duration.zero;
      
      // Iniciar timer para atualizar duração
      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(seconds: timer.tick);
      });

      print('[VOICE_RECORDING] Recording started (simulated): $_recordingPath');
      return true;
    } catch (e) {
      print('[VOICE_RECORDING] Exception starting recording: $e');
      return false;
    }
  }

  // Pausar gravação
  Future<bool> pauseRecording() async {
    try {
      if (!_isRecording || _isPaused) return false;

      _isPaused = true;
      _recordingTimer?.cancel();
      print('[VOICE_RECORDING] Recording paused (simulated)');
      return true;
    } catch (e) {
      print('[VOICE_RECORDING] Exception pausing recording: $e');
      return false;
    }
  }

  // Retomar gravação
  Future<bool> resumeRecording() async {
    try {
      if (!_isRecording || !_isPaused) return false;

      _isPaused = false;
      
      // Reiniciar timer
      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(seconds: timer.tick);
      });

      print('[VOICE_RECORDING] Recording resumed (simulated)');
      return true;
    } catch (e) {
      print('[VOICE_RECORDING] Exception resuming recording: $e');
      return false;
    }
  }

  // Parar gravação
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      _isRecording = false;
      _isPaused = false;
      _recordingTimer?.cancel();
      _recordingTimer = null;

      // Simular arquivo gravado
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        // Criar arquivo vazio para simular gravação
        await file.writeAsString('Simulated audio recording');
        print('[VOICE_RECORDING] Recording stopped (simulated): $_recordingPath');
        return _recordingPath;
      }

      print('[VOICE_RECORDING] Failed to stop recording');
      return null;
    } catch (e) {
      print('[VOICE_RECORDING] Exception stopping recording: $e');
      return null;
    }
  }

  // Cancelar gravação
  Future<void> cancelRecording() async {
    try {
      if (!_isRecording) return;

      _isRecording = false;
      _isPaused = false;
      _recordingTimer?.cancel();
      _recordingTimer = null;

      // Deletar arquivo se existir
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _recordingPath = null;
      print('[VOICE_RECORDING] Recording cancelled (simulated)');
    } catch (e) {
      print('[VOICE_RECORDING] Exception cancelling recording: $e');
    }
  }

  // Reproduzir áudio
  Future<bool> playAudio(String filePath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(filePath));
      print('[VOICE_RECORDING] Playing audio: $filePath');
      return true;
    } catch (e) {
      print('[VOICE_RECORDING] Exception playing audio: $e');
      return false;
    }
  }

  // Pausar reprodução
  Future<bool> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      print('[VOICE_RECORDING] Audio paused');
      return true;
    } catch (e) {
      print('[VOICE_RECORDING] Exception pausing audio: $e');
      return false;
    }
  }

  // Parar reprodução
  Future<bool> stopAudio() async {
    try {
      await _audioPlayer.stop();
      print('[VOICE_RECORDING] Audio stopped');
      return true;
    } catch (e) {
      print('[VOICE_RECORDING] Exception stopping audio: $e');
      return false;
    }
  }

  // Obter duração do arquivo de áudio
  Future<Duration?> getAudioDuration(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      await _audioPlayer.setSource(DeviceFileSource(filePath));
      final duration = await _audioPlayer.getDuration();
      return duration;
    } catch (e) {
      print('[VOICE_RECORDING] Exception getting audio duration: $e');
      return null;
    }
  }

  // Obter duração formatada
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // Verificar permissões
  Future<bool> _checkPermissions() async {
    final microphonePermission = await Permission.microphone.request();
    return microphonePermission == PermissionStatus.granted;
  }

  // Limpar arquivos temporários
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (var file in files) {
        if (file is File) {
          final fileName = path.basename(file.path);
          // Deletar arquivos de voz temporários
          if (fileName.startsWith('voice_')) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('[VOICE_RECORDING] Exception cleaning up temp files: $e');
    }
  }

  // Obter informações do arquivo
  Future<Map<String, dynamic>?> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final stat = await file.stat();
      final duration = await getAudioDuration(filePath);

      return {
        'path': filePath,
        'size': stat.size,
        'duration': duration?.inSeconds,
        'created': stat.modified,
      };
    } catch (e) {
      print('[VOICE_RECORDING] Exception getting file info: $e');
      return null;
    }
  }

  // Converter arquivo para formato compatível
  Future<String?> convertToCompatibleFormat(String inputPath) async {
    try {
      // Para implementação real, você usaria um pacote de conversão de áudio
      // Por enquanto, retornamos o mesmo arquivo
      return inputPath;
    } catch (e) {
      print('[VOICE_RECORDING] Exception converting file: $e');
      return null;
    }
  }

  // Liberar recursos
  void dispose() {
    _recordingTimer?.cancel();
    // _audioRecorder.dispose(); // Removed due to CMake issues
    _audioPlayer.dispose();
  }
}