// services/file_upload_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'api_service.dart';

class FileUploadService {
  final ApiService _apiService;
  final String _baseUrl;

  FileUploadService(this._apiService) : _baseUrl = _apiService.baseUrl;

  // Upload de arquivo
  Future<Map<String, dynamic>?> uploadFile(File file) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return null;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: path.basename(file.path),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('[FILE_UPLOAD] Error uploading file: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('[FILE_UPLOAD] Exception uploading file: $e');
      return null;
    }
  }

  // Upload de múltiplos arquivos
  Future<List<Map<String, dynamic>>> uploadMultipleFiles(List<File> files) async {
    final results = <Map<String, dynamic>>[];
    
    for (final file in files) {
      final result = await uploadFile(file);
      if (result != null) {
        results.add(result);
      }
    }
    
    return results;
  }

  // Obter URL completa do arquivo
  String getFileUrl(String relativePath) {
    return '$_baseUrl$relativePath';
  }

  // Verificar se é imagem
  bool isImage(String mimeType) {
    return mimeType.startsWith('image/');
  }

  // Verificar se é vídeo
  bool isVideo(String mimeType) {
    return mimeType.startsWith('video/');
  }

  // Verificar se é áudio
  bool isAudio(String mimeType) {
    return mimeType.startsWith('audio/');
  }

  // Obter tipo de arquivo baseado na extensão
  String getFileType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension)) {
      return 'image';
    } else if (['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(extension)) {
      return 'video';
    } else if (['.mp3', '.wav', '.aac', '.m4a', '.ogg'].contains(extension)) {
      return 'audio';
    } else {
      return 'document';
    }
  }

  // Formatar tamanho do arquivo
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
