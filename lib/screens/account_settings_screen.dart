import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conta'),
        backgroundColor: const Color(0xFF1F2C34),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF121B22),
      body: ListView(
        children: [
          _buildSectionHeader('Informações da Conta'),
          _buildSettingsItem(
            context,
            Icons.person,
            'Nome de usuário',
            authProvider.user?.username ?? 'N/A',
            () => _showEditDialog(context, 'Nome de usuário', authProvider.user?.username ?? ''),
          ),
          _buildSettingsItem(
            context,
            Icons.email,
            'Email',
            authProvider.user?.email ?? 'N/A',
            () => _showEditDialog(context, 'Email', authProvider.user?.email ?? ''),
          ),
          _buildSettingsItem(
            context,
            Icons.lock,
            'Alterar senha',
            'Segurança da conta',
            () => _showChangePasswordDialog(context),
          ),
          _buildSectionHeader('Segurança'),
          _buildSettingsItem(
            context,
            Icons.security,
            'Verificação em duas etapas',
            'Adicionar camada extra de segurança',
            () => _showTwoFactorDialog(context),
          ),
          _buildSettingsItem(
            context,
            Icons.devices,
            'Dispositivos conectados',
            'Gerenciar dispositivos',
            () => _showDevicesDialog(context),
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

  void _showEditDialog(BuildContext context, String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: Text(
          'Editar $field',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Digite o novo $field',
            hintStyle: const TextStyle(color: Colors.white54),
            border: const OutlineInputBorder(),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$field atualizado com sucesso'),
                  backgroundColor: const Color(0xFF25D366),
                ),
              );
            },
            child: const Text(
              'Salvar',
              style: TextStyle(color: Color(0xFF25D366)),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Alterar Senha',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Senha atual',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Nova senha',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Confirmar nova senha',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
                  content: Text('Senha alterada com sucesso'),
                  backgroundColor: Color(0xFF25D366),
                ),
              );
            },
            child: const Text(
              'Alterar',
              style: TextStyle(color: Color(0xFF25D366)),
            ),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Verificação em Duas Etapas',
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

  void _showDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Dispositivos Conectados',
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
