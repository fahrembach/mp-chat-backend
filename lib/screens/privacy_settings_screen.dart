import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidade'),
        backgroundColor: const Color(0xFF1F2C34),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF121B22),
      body: ListView(
        children: [
          _buildSectionHeader('Status de Presença'),
          _buildSwitchItem(
            context,
            Icons.visibility,
            'Último visto',
            'Mostrar quando você esteve online pela última vez',
            true,
            (value) => _updateLastSeen(context, value),
          ),
          _buildSwitchItem(
            context,
            Icons.visibility_off,
            'Status de leitura',
            'Mostrar quando você leu as mensagens',
            true,
            (value) => _updateReadReceipts(context, value),
          ),
          _buildSectionHeader('Bloqueio'),
          _buildSettingsItem(
            context,
            Icons.block,
            'Contatos bloqueados',
            'Gerenciar contatos bloqueados',
            () => _showBlockedContacts(context),
          ),
          _buildSectionHeader('Mensagens Temporárias'),
          _buildSwitchItem(
            context,
            Icons.timer,
            'Mensagens temporárias',
            'Ativar mensagens que desaparecem automaticamente',
            false,
            (value) => _updateTemporaryMessages(context, value),
          ),
          _buildSettingsItem(
            context,
            Icons.schedule,
            'Tempo de expiração',
            'Definir tempo para mensagens temporárias',
            () => _showExpirationTime(context),
          ),
        ],
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

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: Switch(
        value: value,
        onChanged: (value) => _updateLastSeen(context, value),
        activeColor: const Color(0xFF25D366),
      ),
    );
  }

  void _updateLastSeen(BuildContext context, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Último visto ${value ? 'ativado' : 'desativado'}'),
        backgroundColor: const Color(0xFF25D366),
      ),
    );
  }

  void _updateReadReceipts(BuildContext context, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status de leitura ${value ? 'ativado' : 'desativado'}'),
        backgroundColor: const Color(0xFF25D366),
      ),
    );
  }

  void _updateTemporaryMessages(BuildContext context, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mensagens temporárias ${value ? 'ativadas' : 'desativadas'}'),
        backgroundColor: const Color(0xFF25D366),
      ),
    );
  }

  void _showBlockedContacts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Contatos Bloqueados',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta funcionalidade será implementada em breve!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF25D366)),
            ),
          ),
        ],
      ),
    );
  }

  void _showExpirationTime(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Tempo de Expiração',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta funcionalidade será implementada em breve!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF25D366)),
            ),
          ),
        ],
      ),
    );
  }
}
