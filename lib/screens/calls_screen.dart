import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamadas'),
        backgroundColor: const Color(0xFF1F2C34),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_call),
            onPressed: () => _showNewCallDialog(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF121B22),
      body: ListView(
        children: [
          // Chamadas recentes
          _buildSectionHeader('Chamadas Recentes'),
          _buildCallItem(
            'João Silva',
            'há 2 horas',
            Icons.call_received,
            Colors.green,
            true,
            () => _makeCall('João Silva'),
          ),
          _buildCallItem(
            'Maria Santos',
            'ontem',
            Icons.call_made,
            Colors.blue,
            false,
            () => _makeCall('Maria Santos'),
          ),
          _buildCallItem(
            'Pedro Costa',
            'há 3 dias',
            Icons.call_missed,
            Colors.red,
            false,
            () => _makeCall('Pedro Costa'),
          ),
          
          const SizedBox(height: 20),
          
          // Contatos frequentes
          _buildSectionHeader('Contatos Frequentes'),
          _buildContactItem(
            'Ana Lima',
            'Online',
            Icons.person,
            () => _makeCall('Ana Lima'),
          ),
          _buildContactItem(
            'Carlos Oliveira',
            'Online',
            Icons.person,
            () => _makeCall('Carlos Oliveira'),
          ),
          _buildContactItem(
            'Fernanda Costa',
            'Visto há 1 hora',
            Icons.person,
            () => _makeCall('Fernanda Costa'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewCallDialog(),
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(Icons.add_call, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF25D366),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCallItem(
    String name,
    String time,
    IconData icon,
    Color color,
    bool isVideoCall,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[800],
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              isVideoCall ? Icons.videocam : Icons.call,
              color: const Color(0xFF25D366),
            ),
            onPressed: onTap,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildContactItem(
    String name,
    String status,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: const Color(0xFF25D366),
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
        status,
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.videocam,
              color: Color(0xFF25D366),
            ),
            onPressed: () => _makeVideoCall(name),
          ),
          IconButton(
            icon: const Icon(
              Icons.call,
              color: Color(0xFF25D366),
            ),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  void _showNewCallDialog() {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Nova Chamada',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: phoneController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Digite o número ou nome',
            hintStyle: TextStyle(color: Colors.white54),
            border: OutlineInputBorder(),
          ),
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
              if (phoneController.text.isNotEmpty) {
                _makeCall(phoneController.text);
              }
            },
            child: const Text(
              'Ligar',
              style: TextStyle(color: Color(0xFF25D366)),
            ),
          ),
        ],
      ),
    );
  }

  void _makeCall(String contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando chamada para $contact...'),
        backgroundColor: const Color(0xFF25D366),
      ),
    );
    
    // Aqui você implementaria a lógica real de chamada
    // Por exemplo, navegar para CallScreen
  }

  void _makeVideoCall(String contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando videochamada para $contact...'),
        backgroundColor: const Color(0xFF25D366),
      ),
    );
    
    // Aqui você implementaria a lógica real de videochamada
    // Por exemplo, navegar para CallScreen com isVideoCall = true
  }
}
