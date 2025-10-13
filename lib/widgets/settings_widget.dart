// widgets/settings_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/settings_service.dart';
import '../models/user_settings.dart';

class SettingsWidget extends StatefulWidget {
  final String token;
  final Function(UserSettings)? onSettingsChanged;

  const SettingsWidget({
    Key? key,
    required this.token,
    this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final SettingsService _settingsService = SettingsService();
  UserSettings? _settings;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.getUserSettings(widget.token);
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSetting<T>(String key, T value) async {
    if (_settings == null) return;

    try {
      UserSettings updatedSettings;
      
      switch (key) {
        case 'theme':
          updatedSettings = await _settingsService.updateTheme(value as String, widget.token);
          break;
        case 'language':
          updatedSettings = await _settingsService.updateLanguage(value as String, widget.token);
          break;
        case 'notifications':
          updatedSettings = await _settingsService.updateNotifications(value as bool, widget.token);
          break;
        case 'soundEnabled':
          updatedSettings = await _settingsService.updateSoundEnabled(value as bool, widget.token);
          break;
        case 'vibrationEnabled':
          updatedSettings = await _settingsService.updateVibrationEnabled(value as bool, widget.token);
          break;
        case 'readReceipts':
          updatedSettings = await _settingsService.updateReadReceipts(value as bool, widget.token);
          break;
        case 'lastSeen':
          updatedSettings = await _settingsService.updateLastSeen(value as bool, widget.token);
          break;
        case 'profilePhoto':
          updatedSettings = await _settingsService.updateProfilePhoto(value as bool, widget.token);
          break;
        case 'statusPrivacy':
          updatedSettings = await _settingsService.updateStatusPrivacy(value as String, widget.token);
          break;
        case 'groupInvitePrivacy':
          updatedSettings = await _settingsService.updateGroupInvitePrivacy(value as String, widget.token);
          break;
        case 'callPrivacy':
          updatedSettings = await _settingsService.updateCallPrivacy(value as String, widget.token);
          break;
        case 'mediaAutoDownload':
          updatedSettings = await _settingsService.updateMediaAutoDownload(value as bool, widget.token);
          break;
        case 'mediaDownloadWifiOnly':
          updatedSettings = await _settingsService.updateMediaDownloadWifiOnly(value as bool, widget.token);
          break;
        case 'fontSize':
          updatedSettings = await _settingsService.updateFontSize(value as String, widget.token);
          break;
        case 'accessibilityMode':
          updatedSettings = await _settingsService.updateAccessibilityMode(value as bool, widget.token);
          break;
        default:
          return;
      }

      setState(() {
        _settings = updatedSettings;
      });
      
      widget.onSettingsChanged?.call(updatedSettings);
      HapticFeedback.lightImpact();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar configuração: $e')),
      );
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error ?? 'Erro desconhecido'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSettings,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required String key,
    IconData? icon,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: (newValue) => _updateSetting(key, newValue),
      secondary: icon != null ? Icon(icon) : null,
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required String value,
    required String key,
    required List<String> options,
    IconData? icon,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      leading: icon != null ? Icon(icon) : null,
      onTap: () => _showOptionsDialog(title, value, key, options),
    );
  }

  void _showOptionsDialog(String title, String currentValue, String key, List<String> options) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: currentValue,
              onChanged: (value) {
                if (value != null) {
                  _updateSetting(key, value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    if (_settings == null) return _buildLoadingState();

    return ListView(
      children: [
        // Aparência
        ExpansionTile(
          title: const Text('Aparência'),
          leading: const Icon(Icons.palette),
          children: [
            _buildListTile(
              title: 'Tema',
              subtitle: 'Escolha o tema do aplicativo',
              value: _settings!.theme,
              key: 'theme',
              options: _settingsService.getThemeOptions(),
            ),
            _buildListTile(
              title: 'Tamanho da fonte',
              subtitle: 'Ajuste o tamanho do texto',
              value: _settings!.fontSize,
              key: 'fontSize',
              options: _settingsService.getFontSizeOptions(),
            ),
          ],
        ),

        // Idioma e região
        ExpansionTile(
          title: const Text('Idioma e região'),
          leading: const Icon(Icons.language),
          children: [
            _buildListTile(
              title: 'Idioma',
              subtitle: 'Escolha o idioma do aplicativo',
              value: _settings!.language,
              key: 'language',
              options: _settingsService.getLanguageOptions(),
            ),
          ],
        ),

        // Notificações
        ExpansionTile(
          title: const Text('Notificações'),
          leading: const Icon(Icons.notifications),
          children: [
            _buildSwitchTile(
              title: 'Notificações',
              subtitle: 'Receber notificações do aplicativo',
              value: _settings!.notifications,
              key: 'notifications',
              icon: Icons.notifications,
            ),
            _buildSwitchTile(
              title: 'Som',
              subtitle: 'Reproduzir sons nas notificações',
              value: _settings!.soundEnabled,
              key: 'soundEnabled',
              icon: Icons.volume_up,
            ),
            _buildSwitchTile(
              title: 'Vibração',
              subtitle: 'Vibrar nas notificações',
              value: _settings!.vibrationEnabled,
              key: 'vibrationEnabled',
              icon: Icons.vibration,
            ),
          ],
        ),

        // Privacidade
        ExpansionTile(
          title: const Text('Privacidade'),
          leading: const Icon(Icons.privacy_tip),
          children: [
            _buildSwitchTile(
              title: 'Confirmação de leitura',
              subtitle: 'Mostrar quando suas mensagens são lidas',
              value: _settings!.readReceipts,
              key: 'readReceipts',
              icon: Icons.done_all,
            ),
            _buildSwitchTile(
              title: 'Última visualização',
              subtitle: 'Mostrar quando você esteve online',
              value: _settings!.lastSeen,
              key: 'lastSeen',
              icon: Icons.visibility,
            ),
            _buildSwitchTile(
              title: 'Foto do perfil',
              subtitle: 'Mostrar sua foto do perfil para outros',
              value: _settings!.profilePhoto,
              key: 'profilePhoto',
              icon: Icons.photo,
            ),
            _buildListTile(
              title: 'Privacidade do status',
              subtitle: 'Quem pode ver seu status',
              value: _settings!.statusPrivacy,
              key: 'statusPrivacy',
              options: _settingsService.getPrivacyOptions(),
            ),
            _buildListTile(
              title: 'Convites de grupo',
              subtitle: 'Quem pode convidá-lo para grupos',
              value: _settings!.groupInvitePrivacy,
              key: 'groupInvitePrivacy',
              options: _settingsService.getPrivacyOptions(),
            ),
            _buildListTile(
              title: 'Chamadas',
              subtitle: 'Quem pode chamá-lo',
              value: _settings!.callPrivacy,
              key: 'callPrivacy',
              options: _settingsService.getPrivacyOptions(),
            ),
          ],
        ),

        // Mídia e armazenamento
        ExpansionTile(
          title: const Text('Mídia e armazenamento'),
          leading: const Icon(Icons.storage),
          children: [
            _buildSwitchTile(
              title: 'Download automático',
              subtitle: 'Baixar mídia automaticamente',
              value: _settings!.mediaAutoDownload,
              key: 'mediaAutoDownload',
              icon: Icons.download,
            ),
            _buildSwitchTile(
              title: 'Apenas Wi-Fi',
              subtitle: 'Baixar mídia apenas no Wi-Fi',
              value: _settings!.mediaDownloadWifiOnly,
              key: 'mediaDownloadWifiOnly',
              icon: Icons.wifi,
            ),
          ],
        ),

        // Acessibilidade
        ExpansionTile(
          title: const Text('Acessibilidade'),
          leading: const Icon(Icons.accessibility),
          children: [
            _buildSwitchTile(
              title: 'Modo de acessibilidade',
              subtitle: 'Melhorar a experiência para usuários com deficiência',
              value: _settings!.accessibilityMode,
              key: 'accessibilityMode',
              icon: Icons.accessibility_new,
            ),
          ],
        ),

        // Informações do aplicativo
        ExpansionTile(
          title: const Text('Sobre'),
          leading: const Icon(Icons.info),
          children: [
            ListTile(
              title: const Text('Versão'),
              subtitle: const Text('1.0.0'),
              leading: const Icon(Icons.info_outline),
            ),
            ListTile(
              title: const Text('Política de privacidade'),
              subtitle: const Text('Como protegemos seus dados'),
              leading: const Icon(Icons.privacy_tip_outlined),
              onTap: () {
                // Implementar navegação para política de privacidade
              },
            ),
            ListTile(
              title: const Text('Termos de serviço'),
              subtitle: const Text('Termos e condições de uso'),
              leading: const Icon(Icons.description_outlined),
              onTap: () {
                // Implementar navegação para termos de serviço
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSettings,
          ),
        ],
      ),
      body: _buildSettingsContent(),
    );
  }
}
