// services/shared_video_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class SharedVideoService {
  final ApiService _apiService;
  final String _baseUrl;

  SharedVideoService(this._apiService) : _baseUrl = _apiService.baseUrl;

  // Criar sessão de vídeo compartilhado
  Future<Map<String, dynamic>?> createSharedVideoSession({
    required String videoUrl,
    required String videoType, // 'local' ou 'youtube'
    required List<String> participants,
  }) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/shared-videos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'videoUrl': videoUrl,
          'videoType': videoType,
          'participants': participants,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print('[SHARED_VIDEO] Error creating session: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('[SHARED_VIDEO] Exception creating session: $e');
      return null;
    }
  }

  // Obter sessões de vídeo compartilhado
  Future<List<Map<String, dynamic>>> getSharedVideoSessions() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/api/shared-videos'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('[SHARED_VIDEO] Error fetching sessions: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('[SHARED_VIDEO] Exception fetching sessions: $e');
      return [];
    }
  }

  // Encerrar sessão de vídeo compartilhado
  Future<bool> endSharedVideoSession(String sessionId) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/shared-videos/$sessionId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('[SHARED_VIDEO] Error ending session: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('[SHARED_VIDEO] Exception ending session: $e');
      return false;
    }
  }

  // Validar URL do YouTube
  bool isValidYouTubeUrl(String url) {
    final youtubeRegex = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    return youtubeRegex.hasMatch(url);
  }

  // Extrair ID do vídeo do YouTube
  String? extractYouTubeVideoId(String url) {
    final youtubeRegex = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = youtubeRegex.firstMatch(url);
    return match?.group(1);
  }

  // Obter URL de embed do YouTube
  String getYouTubeEmbedUrl(String videoId) {
    return 'https://www.youtube.com/embed/$videoId?autoplay=1&controls=1&showinfo=0&rel=0';
  }

  // Validar arquivo de vídeo local
  bool isValidLocalVideo(String filePath) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v'];
    return videoExtensions.any((ext) => filePath.toLowerCase().endsWith(ext));
  }

  // Obter tipo de vídeo baseado na URL/caminho
  String getVideoType(String videoSource) {
    if (isValidYouTubeUrl(videoSource)) {
      return 'youtube';
    } else if (isValidLocalVideo(videoSource)) {
      return 'local';
    } else {
      return 'unknown';
    }
  }
}
