import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/account_settings_screen.dart';
import '../screens/privacy_settings_screen.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1F2C34),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              children: [
                _buildSettingsItem(
                  icon: Icons.lock,
                  iconColor: Colors.blue,
                  title: 'Conta',
                  subtitle: 'Segurança, mudança de número',
                  onTap: () => _showAccountSettings(context),
                ),
                _buildSettingsItem(
                  icon: Icons.privacy_tip,
                  iconColor: Colors.green,
                  title: 'Privacidade',
                  subtitle: 'Bloqueio, mensagens temporárias',
                  onTap: () => _showPrivacySettings(context),
                ),
                _buildSettingsItem(
                  icon: Icons.person,
                  iconColor: Colors.purple,
                  title: 'Avatar',
                  subtitle: 'Criar, editar, foto de perfil',
                  onTap: () => _showAvatarSettings(context),
                ),
                _buildSettingsItem(
                  icon: Icons.list,
                  iconColor: Colors.blue,
                  title: 'Listas',
                  subtitle: 'Gerenciar pessoas e grupos',
                  onTap: () => _showListsSettings(context),
                ),
                _buildSettingsItem(
                  icon: Icons.chat,
                  iconColor: Colors.green,
                  title: 'Conversas',
                  subtitle: 'Tema, papel de parede, histórico',
                  onTap: () => _showChatSettings(context),
                ),
                _buildSettingsItem(
                  icon: Icons.notifications,
                  iconColor: Colors.red,
                  title: 'Notificações',
                  subtitle: 'Mensagens, grupos, ligações',
                  onTap: () => _showNotificationSettings(context),
                ),
                _buildSettingsItem(
                  icon: Icons.storage,
                  iconColor: Colors.green,
                  title: 'Armazenamento e dados',
                  subtitle: 'Uso de rede, downloads',
                  onTap: () => _showStorageSettings(context),
                ),
                _buildSettingsItem(
                  icon: Icons.accessibility,
                  iconColor: Colors.purple,
                  title: 'Acessibilidade',
                  subtitle: 'Contraste, animações',
                  onTap: () => _showAccessibilitySettings(context),
                ),
                _buildSettingsItem(
                  icon: Icons.language,
                  iconColor: Colors.blue,
                  title: 'Idioma do app',
                  subtitle: 'Português (Brasil)',
                  onTap: () => _showLanguageSettings(context),
                ),
                const Divider(color: Color(0xFF2A3942)),
                _buildLogoutItem(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF25D366),
            child: Text(
              user?.username.isNotEmpty == true
                  ? user!.username[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.username ?? 'Usuário',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'email@exemplo.com',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 12,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.logout, color: Colors.red, size: 20),
      ),
      title: const Text(
        'Sair',
        style: TextStyle(
          color: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => _showLogoutDialog(context),
    );
  }

  void _showAccountSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacySettingsScreen()),
    );
  }

  void _showAvatarSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Configurações de Avatar');
  }

  void _showListsSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Configurações de Listas');
  }

  void _showChatSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Configurações de Conversas');
  }

  void _showNotificationSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Configurações de Notificações');
  }

  void _showStorageSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Configurações de Armazenamento');
  }

  void _showAccessibilitySettings(BuildContext context) {
    _showComingSoonDialog(context, 'Configurações de Acessibilidade');
  }

  void _showLanguageSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Configurações de Idioma');
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Sair',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja sair?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/login');
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: Text(
          feature,
          style: const TextStyle(color: Colors.white),
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
