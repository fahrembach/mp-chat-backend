// services/status_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/status_update.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'file_upload_service.dart';

class StatusService {
  final ApiService _apiService;
  final FileUploadService _fileUploadService;
  final String _baseUrl;

  StatusService(this._apiService) 
      : _fileUploadService = FileUploadService(_apiService),
        _baseUrl = _apiService.baseUrl;

  // Criar um novo status
  Future<StatusUpdate?> createStatus({
    required String content,
    required StatusType type,
    String? mediaPath,
    int? duration,
  }) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return null;

      String? mediaUrl;
      String? thumbnailUrl;

      // Upload do arquivo de mídia se fornecido
      if (mediaPath != null && File(mediaPath).existsSync()) {
        final uploadResult = await _fileUploadService.uploadFile(File(mediaPath));
        if (uploadResult != null) {
          mediaUrl = uploadResult['url'];
          thumbnailUrl = uploadResult['thumbnailUrl'];
        }
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/status'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['content'] = content;
      request.fields['type'] = type.name;
      
      if (mediaUrl != null) {
        request.fields['mediaUrl'] = mediaUrl;
      }
      if (thumbnailUrl != null) {
        request.fields['thumbnailUrl'] = thumbnailUrl;
      }
      if (duration != null) {
        request.fields['duration'] = duration.toString();
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return StatusUpdate.fromJson(data);
      } else {
        print('[STATUS] Error creating status: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('[STATUS] Exception creating status: $e');
      return null;
    }
  }

  // Obter todos os status
  Future<List<StatusUpdate>> getStatuses() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/api/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((item) => StatusUpdate.fromJson(item)).toList();
      } else {
        print('[STATUS] Error fetching statuses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[STATUS] Exception fetching statuses: $e');
      return [];
    }
  }

  // Visualizar um status
  Future<bool> viewStatus(String statusId) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/status/$statusId/view'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[STATUS] Exception viewing status: $e');
      return false;
    }
  }

  // Deletar um status
  Future<bool> deleteStatus(String statusId) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/status/$statusId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[STATUS] Exception deleting status: $e');
      return false;
    }
  }

  // Obter status de um usuário específico
  Future<List<StatusUpdate>> getStatusesForUser(String userId) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/api/status/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((item) => StatusUpdate.fromJson(item)).toList();
      } else {
        print('[STATUS] Error fetching user statuses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[STATUS] Exception fetching user statuses: $e');
      return [];
    }
  }

  // Obter status expirados
  Future<List<StatusUpdate>> getExpiredStatuses() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/api/status/expired'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((item) => StatusUpdate.fromJson(item)).toList();
      } else {
        print('[STATUS] Error fetching expired statuses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[STATUS] Exception fetching expired statuses: $e');
      return [];
    }
  }

  // Obter status de mídia
  Future<List<StatusUpdate>> getMediaStatuses() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/api/status/media'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((item) => StatusUpdate.fromJson(item)).toList();
      } else {
        print('[STATUS] Error fetching media statuses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[STATUS] Exception fetching media statuses: $e');
      return [];
    }
  }

  // Obter status de texto
  Future<List<StatusUpdate>> getTextStatuses() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/api/status/text'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((item) => StatusUpdate.fromJson(item)).toList();
      } else {
        print('[STATUS] Error fetching text statuses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[STATUS] Exception fetching text statuses: $e');
      return [];
    }
  }

  // Selecionar arquivo de mídia
  Future<String?> pickMediaFile({required StatusType type}) async {
    try {
      FilePickerResult? result;
      
      switch (type) {
        case StatusType.image:
          result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
          );
          break;
        case StatusType.video:
          result = await FilePicker.platform.pickFiles(
            type: FileType.video,
            allowMultiple: false,
          );
          break;
        case StatusType.audio:
          result = await FilePicker.platform.pickFiles(
            type: FileType.audio,
            allowMultiple: false,
          );
          break;
        case StatusType.text:
          return null; // Não precisa de arquivo para texto
      }

      if (result != null && result.files.single.path != null) {
        return result.files.single.path!;
      }
      
      return null;
    } catch (e) {
      print('[STATUS] Exception picking media file: $e');
      return null;
    }
  }

  // Obter duração de vídeo/áudio
  Future<int?> getMediaDuration(String filePath) async {
    try {
      // Para implementação real, você usaria um pacote como video_player ou audioplayers
      // Por enquanto, retornamos um valor simulado
      return 30; // 30 segundos
    } catch (e) {
      print('[STATUS] Exception getting media duration: $e');
      return null;
    }
  }

  // Salvar arquivo temporariamente
  Future<String?> saveTempFile(String filePath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basename(filePath);
      final tempPath = path.join(tempDir.path, fileName);
      
      await File(filePath).copy(tempPath);
      return tempPath;
    } catch (e) {
      print('[STATUS] Exception saving temp file: $e');
      return null;
    }
  }

  // Limpar arquivos temporários
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (var file in files) {
        if (file is File) {
          final fileName = path.basename(file.path);
          // Deletar arquivos de status temporários (você pode adicionar um prefixo)
          if (fileName.startsWith('status_')) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('[STATUS] Exception cleaning up temp files: $e');
    }
  }
}