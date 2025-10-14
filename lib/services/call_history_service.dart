// services/call_history_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/call.dart';
import 'api_service.dart';

class CallHistoryService {
  final ApiService _apiService;
  final String _baseUrl;

  CallHistoryService(this._apiService) : _baseUrl = _apiService.baseUrl;

  // Obter histórico de chamadas
  Future<List<Call>> getCallHistory() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/api/calls/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((item) => Call.fromJson(item)).toList();
      } else {
        print('[CALL_HISTORY] Error fetching call history: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[CALL_HISTORY] Exception fetching call history: $e');
      return [];
    }
  }

  // Obter chamadas perdidas
  Future<List<Call>> getMissedCalls() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/api/calls/missed'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((item) => Call.fromJson(item)).toList();
      } else {
        print('[CALL_HISTORY] Error fetching missed calls: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[CALL_HISTORY] Exception fetching missed calls: $e');
      return [];
    }
  }

  // Obter chamadas de um usuário específico
  Future<List<Call>> getCallsWithUser(String userId) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/api/calls/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((item) => Call.fromJson(item)).toList();
      } else {
        print('[CALL_HISTORY] Error fetching calls with user: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[CALL_HISTORY] Exception fetching calls with user: $e');
      return [];
    }
  }

  // Registrar uma nova chamada
  Future<Call?> recordCall({
    required String callerId,
    required String receiverId,
    required CallType type,
    required CallStatus status,
    DateTime? endTime,
    int? duration,
  }) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/calls'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'callerId': callerId,
          'receiverId': receiverId,
          'type': type.name,
          'status': status.name,
          'startTime': DateTime.now().toIso8601String(),
          'endTime': endTime?.toIso8601String(),
          'duration': duration,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Call.fromJson(data);
      } else {
        print('[CALL_HISTORY] Error recording call: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('[CALL_HISTORY] Exception recording call: $e');
      return null;
    }
  }

  // Atualizar status de uma chamada
  Future<bool> updateCallStatus(String callId, CallStatus status) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/calls/$callId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': status.name,
          'endTime': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[CALL_HISTORY] Exception updating call status: $e');
      return false;
    }
  }

  // Deletar uma chamada do histórico
  Future<bool> deleteCall(String callId) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/calls/$callId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[CALL_HISTORY] Exception deleting call: $e');
      return false;
    }
  }

  // Limpar histórico de chamadas
  Future<bool> clearCallHistory() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/calls/clear'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[CALL_HISTORY] Exception clearing call history: $e');
      return false;
    }
  }

  // Obter estatísticas de chamadas
  Future<Map<String, dynamic>> getCallStats() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return {};

      final response = await http.get(
        Uri.parse('$_baseUrl/api/calls/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('[CALL_HISTORY] Error fetching call stats: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('[CALL_HISTORY] Exception fetching call stats: $e');
      return {};
    }
  }

  // Filtrar chamadas por tipo
  List<Call> filterCallsByType(List<Call> calls, CallType type) {
    return calls.where((call) => call.type == type).toList();
  }

  // Filtrar chamadas por status
  List<Call> filterCallsByStatus(List<Call> calls, CallStatus status) {
    return calls.where((call) => call.status == status).toList();
  }

  // Ordenar chamadas por data
  List<Call> sortCallsByDate(List<Call> calls, {bool ascending = false}) {
    calls.sort((a, b) {
      if (ascending) {
        return a.startTime.compareTo(b.startTime);
      } else {
        return b.startTime.compareTo(a.startTime);
      }
    });
    return calls;
  }

  // Agrupar chamadas por data
  Map<String, List<Call>> groupCallsByDate(List<Call> calls) {
    final Map<String, List<Call>> grouped = {};
    
    for (final call in calls) {
      final dateKey = '${call.startTime.year}-${call.startTime.month.toString().padLeft(2, '0')}-${call.startTime.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(dateKey, () => []).add(call);
    }
    
    return grouped;
  }
}
