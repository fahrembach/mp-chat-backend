// screens/call_history_screen.dart
import 'package:flutter/material.dart';
import '../models/call.dart';
import '../models/user.dart';
import '../services/call_history_service.dart';
import '../services/auth_service.dart';
import '../service_locator.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  final CallHistoryService _callHistoryService = locator<CallHistoryService>();
  final AuthService _authService = locator<AuthService>();
  
  List<Call> _calls = [];
  User? _currentUser;
  bool _isLoading = true;
  CallType? _selectedFilter;
  CallStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      await _loadCallHistory();
    } catch (e) {
      print('[CALL_HISTORY] Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCallHistory() async {
    try {
      final calls = await _callHistoryService.getCallHistory();
      setState(() {
        _calls = calls;
      });
    } catch (e) {
      print('[CALL_HISTORY] Error loading call history: $e');
    }
  }

  Future<void> _refreshCalls() async {
    await _loadCallHistory();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Histórico de Chamadas',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: _onFilterSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Todas as chamadas'),
              ),
              const PopupMenuItem(
                value: 'audio',
                child: Text('Apenas áudio'),
              ),
              const PopupMenuItem(
                value: 'video',
                child: Text('Apenas vídeo'),
              ),
              const PopupMenuItem(
                value: 'missed',
                child: Text('Chamadas perdidas'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCalls,
        child: _buildCallList(),
      ),
    );
  }

  Widget _buildCallList() {
    if (_calls.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.call_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma chamada encontrada',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Filtrar chamadas
    List<Call> filteredCalls = _calls;
    
    if (_selectedFilter != null) {
      filteredCalls = filteredCalls.where((call) => call.type == _selectedFilter).toList();
    }
    
    if (_selectedStatusFilter != null) {
      filteredCalls = filteredCalls.where((call) => call.status == _selectedStatusFilter).toList();
    }

    // Agrupar por data
    final groupedCalls = _groupCallsByDate(filteredCalls);

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: groupedCalls.length,
      itemBuilder: (context, index) {
        final dateKey = groupedCalls.keys.elementAt(index);
        final callsForDate = groupedCalls[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _formatDateHeader(dateKey),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...callsForDate.map((call) => _buildCallTile(call)),
          ],
        );
      },
    );
  }

  Widget _buildCallTile(Call call) {
    final isOutgoing = call.callerId == _currentUser?.id;
    final otherUser = isOutgoing ? call.receiver : call.caller;
    final isMissed = call.status == CallStatus.missed;
    final isRejected = call.status == CallStatus.rejected;

    return Card(
      color: Colors.grey[900],
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[700],
          child: otherUser?.avatar != null
              ? ClipOval(
                  child: Image.network(
                    otherUser!.avatar!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      );
                    },
                  ),
                )
              : const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
        ),
        title: Text(
          otherUser?.name ?? 'Usuário',
          style: TextStyle(
            color: Colors.white,
            fontWeight: (isMissed || isRejected) ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              call.type == CallType.video ? Icons.videocam : Icons.call,
              color: _getCallIconColor(call.status),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              call.statusText,
              style: TextStyle(
                color: _getCallIconColor(call.status),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatCallTime(call.startTime),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (call.duration != null && call.status == CallStatus.ended)
              Text(
                call.formattedDuration,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    call.type == CallType.video ? Icons.videocam : Icons.call,
                    color: Colors.green,
                    size: 20,
                  ),
                  onPressed: () => _makeCall(otherUser, call.type),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => _showCallInfo(call),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showCallInfo(call),
      ),
    );
  }

  Color _getCallIconColor(CallStatus status) {
    switch (status) {
      case CallStatus.missed:
        return Colors.red;
      case CallStatus.rejected:
        return Colors.orange;
      case CallStatus.ended:
        return Colors.green;
      case CallStatus.incoming:
      case CallStatus.outgoing:
        return Colors.blue;
    }
  }

  Map<String, List<Call>> _groupCallsByDate(List<Call> calls) {
    final Map<String, List<Call>> grouped = {};
    
    for (final call in calls) {
      final dateKey = '${call.startTime.year}-${call.startTime.month.toString().padLeft(2, '0')}-${call.startTime.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(dateKey, () => []).add(call);
    }
    
    // Ordenar por data (mais recente primeiro)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedGrouped = <String, List<Call>>{};
    
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }
    
    return sortedGrouped;
  }

  String _formatDateHeader(String dateKey) {
    final parts = dateKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    
    final date = DateTime(year, month, day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date == today) {
      return 'Hoje';
    } else if (date == yesterday) {
      return 'Ontem';
    } else {
      return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year}';
    }
  }

  String _formatCallTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _onFilterSelected(String filter) {
    setState(() {
      switch (filter) {
        case 'all':
          _selectedFilter = null;
          _selectedStatusFilter = null;
          break;
        case 'audio':
          _selectedFilter = CallType.audio;
          _selectedStatusFilter = null;
          break;
        case 'video':
          _selectedFilter = CallType.video;
          _selectedStatusFilter = null;
          break;
        case 'missed':
          _selectedFilter = null;
          _selectedStatusFilter = CallStatus.missed;
          break;
      }
    });
  }

  void _makeCall(User? user, CallType type) {
    if (user != null) {
      // Implementar chamada
      print('[CALL_HISTORY] Making call to ${user.name}');
    }
  }

  void _showCallInfo(Call call) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Detalhes da Chamada', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${call.typeText}', style: const TextStyle(color: Colors.white)),
            Text('Status: ${call.statusText}', style: const TextStyle(color: Colors.white)),
            Text('Início: ${_formatDateTime(call.startTime)}', style: const TextStyle(color: Colors.white)),
            if (call.endTime != null)
              Text('Fim: ${_formatDateTime(call.endTime!)}', style: const TextStyle(color: Colors.white)),
            if (call.duration != null)
              Text('Duração: ${call.formattedDuration}', style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCall(call);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime time) {
    return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year} às ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteCall(Call call) async {
    try {
      final success = await _callHistoryService.deleteCall(call.id);
      if (success) {
        await _refreshCalls();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chamada excluída'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir chamada'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('[CALL_HISTORY] Error deleting call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir chamada'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Limpar Histórico', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tem certeza que deseja limpar todo o histórico de chamadas?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _callHistoryService.clearCallHistory();
        if (success) {
          await _refreshCalls();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Histórico limpo'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao limpar histórico'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('[CALL_HISTORY] Error clearing history: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao limpar histórico'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
