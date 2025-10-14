// screens/status_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import '../models/status_update.dart';
import '../models/user.dart';
import '../services/status_service.dart';
import '../services/auth_service.dart';
import '../service_locator.dart';
import 'create_status_screen.dart';
import 'status_viewer_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({Key? key}) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final StatusService _statusService = locator<StatusService>();
  final AuthService _authService = locator<AuthService>();
  
  List<StatusUpdate> _statuses = [];
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      await _loadStatuses();
    } catch (e) {
      print('[STATUS_SCREEN] Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStatuses() async {
    try {
      final statuses = await _statusService.getStatuses();
      setState(() {
        _statuses = statuses;
      });
    } catch (e) {
      print('[STATUS_SCREEN] Error loading statuses: $e');
    }
  }

  Future<void> _refreshStatuses() async {
    await _loadStatuses();
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
          'Status',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: _createStatus,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStatuses,
        child: _buildStatusList(),
      ),
    );
  }

  Widget _buildStatusList() {
    if (_statuses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum status encontrado',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Toque no ícone da câmera para criar um status',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Agrupar statuses por usuário
    final Map<String, List<StatusUpdate>> groupedStatuses = {};
    for (final status in _statuses) {
      final userId = status.userId;
      if (!groupedStatuses.containsKey(userId)) {
        groupedStatuses[userId] = [];
      }
      groupedStatuses[userId]!.add(status);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: groupedStatuses.length + 1, // +1 para o status próprio
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildMyStatusCard();
        }
        
        final userId = groupedStatuses.keys.elementAt(index - 1);
        final userStatuses = groupedStatuses[userId]!;
        final user = userStatuses.first.user;
        
        return _buildUserStatusCard(user, userStatuses);
      },
    );
  }

  Widget _buildMyStatusCard() {
    final myStatuses = _statuses.where((s) => s.userId == _currentUser?.id).toList();
    final hasUnviewedStatuses = myStatuses.any((s) => !s.isViewed);

    return Card(
      color: Colors.grey[900],
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[700],
              child: _currentUser?.avatar != null
                  ? ClipOval(
                      child: Image.network(
                        _currentUser!.avatar!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
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
            if (hasUnviewedStatuses)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
        title: const Text(
          'Meu Status',
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          myStatuses.isEmpty 
              ? 'Toque para adicionar uma atualização de status'
              : '${myStatuses.length} atualização${myStatuses.length > 1 ? 'ões' : ''}',
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: _createStatus,
      ),
    );
  }

  Widget _buildUserStatusCard(User? user, List<StatusUpdate> statuses) {
    final hasUnviewedStatuses = statuses.any((s) => !s.isViewed);
    final latestStatus = statuses.first;

    return Card(
      color: Colors.grey[900],
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: hasUnviewedStatuses ? Colors.green : Colors.grey[700],
              child: user?.avatar != null
                  ? ClipOval(
                      child: Image.network(
                        user!.avatar!,
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
            if (hasUnviewedStatuses)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          user?.name ?? 'Usuário',
          style: TextStyle(
            color: Colors.white,
            fontWeight: hasUnviewedStatuses ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          _formatStatusTime(latestStatus.createdAt),
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () => _viewUserStatuses(user, statuses),
      ),
    );
  }

  String _formatStatusTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _createStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateStatusScreen(),
      ),
    ).then((_) {
      _refreshStatuses();
    });
  }

  void _viewUserStatuses(User? user, List<StatusUpdate> statuses) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusViewerScreen(
          user: user,
          statuses: statuses,
          onStatusViewed: (statusId) {
            _statusService.viewStatus(statusId);
            _refreshStatuses();
          },
        ),
      ),
    );
  }
}