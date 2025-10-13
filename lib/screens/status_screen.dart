import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final TextEditingController _statusController = TextEditingController();

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
        backgroundColor: const Color(0xFF1F2C34),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _showCameraOptions(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF121B22),
      body: Column(
        children: [
          // Meu Status
          _buildMyStatus(authProvider),
          
          // Divisor
          const Divider(color: Color(0xFF2A3942)),
          
          // Status de outros usuários
          Expanded(
            child: _buildOthersStatus(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateStatusDialog(),
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMyStatus(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF25D366),
                child: Text(
                  authProvider.user?.username[0].toUpperCase() ?? '?',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF25D366),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meu Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toque para adicionar uma atualização de status',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOthersStatus() {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Atualizações recentes',
            style: TextStyle(
              color: Color(0xFF25D366),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Status de exemplo
        _buildStatusItem(
          'João Silva',
          'Acabei de chegar em casa!',
          'há 2 horas',
          true,
        ),
        _buildStatusItem(
          'Maria Santos',
          'Trabalhando no projeto...',
          'há 5 horas',
          false,
        ),
        _buildStatusItem(
          'Pedro Costa',
          'Almoçando com a família',
          'há 1 dia',
          false,
        ),
      ],
    );
  }

  Widget _buildStatusItem(String name, String status, String time, bool isViewed) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: isViewed ? Colors.grey : const Color(0xFF25D366),
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        time,
        style: const TextStyle(color: Colors.white60),
      ),
      onTap: () => _showStatusViewer(name, status, time),
    );
  }

  void _showCreateStatusDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Criar Status',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusOption(
                  icon: Icons.text_fields,
                  label: 'Texto',
                  onTap: () {
                    Navigator.pop(context);
                    _showTextStatusDialog();
                  },
                ),
                _buildStatusOption(
                  icon: Icons.photo,
                  label: 'Foto',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                _buildStatusOption(
                  icon: Icons.videocam,
                  label: 'Vídeo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideo();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2A3942),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: Colors.white70,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showTextStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Status de Texto',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _statusController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'O que você está pensando?',
            hintStyle: TextStyle(color: Colors.white54),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Status criado com sucesso!'),
                  backgroundColor: Color(0xFF25D366),
                ),
              );
            },
            child: const Text(
              'Publicar',
              style: TextStyle(color: Color(0xFF25D366)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCameraOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Câmera',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusOption(
                  icon: Icons.camera_alt,
                  label: 'Foto',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                _buildStatusOption(
                  icon: Icons.videocam,
                  label: 'Vídeo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideo();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _pickImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selecionar imagem será implementado em breve'),
        backgroundColor: Color(0xFF25D366),
      ),
    );
  }

  void _pickVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selecionar vídeo será implementado em breve'),
        backgroundColor: Color(0xFF25D366),
      ),
    );
  }

  void _showStatusViewer(String name, String status, String time) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Fechar',
              style: TextStyle(color: Color(0xFF25D366)),
            ),
          ),
        ],
      ),
    );
  }
}
