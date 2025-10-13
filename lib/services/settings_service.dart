// services/settings_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _baseUrl = 'https://projeto-798t.onrender.com/api';
  UserSettings? _cachedSettings;

  // Callbacks
  Function(UserSettings)? onSettingsChanged;
  Function(String)? onSettingsError;

  UserSettings? get cachedSettings => _cachedSettings;

  // Obter configurações do usuário
  Future<UserSettings> getUserSettings(String token) async {
    try {
      final url = Uri.parse('$_baseUrl/settings');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final settings = UserSettings.fromJson(json.decode(response.body));
        _cachedSettings = settings;
        await _saveSettingsLocally(settings);
        return settings;
      } else {
        throw Exception('Falha ao carregar configurações');
      }
    } catch (e) {
      print('[SETTINGS] Error getting user settings: $e');
      
      // Tentar carregar configurações locais em caso de erro
      final localSettings = await _loadSettingsLocally();
      if (localSettings != null) {
        return localSettings;
      }
      
      throw Exception('Erro ao carregar configurações: $e');
    }
  }

  // Atualizar configurações do usuário
  Future<UserSettings> updateUserSettings({
    required String token,
    String? theme,
    String? language,
    bool? notifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? readReceipts,
    bool? lastSeen,
    bool? profilePhoto,
    String? statusPrivacy,
    String? groupInvitePrivacy,
    String? callPrivacy,
    bool? mediaAutoDownload,
    bool? mediaDownloadWifiOnly,
    String? fontSize,
    bool? accessibilityMode,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/settings');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'theme': theme,
          'language': language,
          'notifications': notifications,
          'soundEnabled': soundEnabled,
          'vibrationEnabled': vibrationEnabled,
          'readReceipts': readReceipts,
          'lastSeen': lastSeen,
          'profilePhoto': profilePhoto,
          'statusPrivacy': statusPrivacy,
          'groupInvitePrivacy': groupInvitePrivacy,
          'callPrivacy': callPrivacy,
          'mediaAutoDownload': mediaAutoDownload,
          'mediaDownloadWifiOnly': mediaDownloadWifiOnly,
          'fontSize': fontSize,
          'accessibilityMode': accessibilityMode,
        }),
      );

      if (response.statusCode == 200) {
        final settings = UserSettings.fromJson(json.decode(response.body));
        _cachedSettings = settings;
        await _saveSettingsLocally(settings);
        onSettingsChanged?.call(settings);
        return settings;
      } else {
        throw Exception('Falha ao atualizar configurações');
      }
    } catch (e) {
      print('[SETTINGS] Error updating user settings: $e');
      onSettingsError?.call('Erro ao atualizar configurações: $e');
      throw Exception('Erro ao atualizar configurações: $e');
    }
  }

  // Salvar configurações localmente
  Future<void> _saveSettingsLocally(UserSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_settings', json.encode(settings.toJson()));
    } catch (e) {
      print('[SETTINGS] Error saving settings locally: $e');
    }
  }

  // Carregar configurações localmente
  Future<UserSettings?> _loadSettingsLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('user_settings');
      if (settingsJson != null) {
        return UserSettings.fromJson(json.decode(settingsJson));
      }
    } catch (e) {
      print('[SETTINGS] Error loading settings locally: $e');
    }
    return null;
  }

  // Obter configurações locais
  Future<UserSettings?> getLocalSettings() async {
    return await _loadSettingsLocally();
  }

  // Limpar configurações locais
  Future<void> clearLocalSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_settings');
      _cachedSettings = null;
    } catch (e) {
      print('[SETTINGS] Error clearing local settings: $e');
    }
  }

  // Configurações específicas
  Future<bool> updateTheme(String theme, String token) async {
    try {
      await updateUserSettings(token: token, theme: theme);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateLanguage(String language, String token) async {
    try {
      await updateUserSettings(token: token, language: language);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateNotifications(bool enabled, String token) async {
    try {
      await updateUserSettings(token: token, notifications: enabled);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSoundEnabled(bool enabled, String token) async {
    try {
      await updateUserSettings(token: token, soundEnabled: enabled);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateVibrationEnabled(bool enabled, String token) async {
    try {
      await updateUserSettings(token: token, vibrationEnabled: enabled);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateReadReceipts(bool enabled, String token) async {
    try {
      await updateUserSettings(token: token, readReceipts: enabled);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateLastSeen(bool enabled, String token) async {
    try {
      await updateUserSettings(token: token, lastSeen: enabled);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProfilePhoto(bool enabled, String token) async {
    try {
      await updateUserSettings(token: token, profilePhoto: enabled);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStatusPrivacy(String privacy, String token) async {
    try {
      await updateUserSettings(token: token, statusPrivacy: privacy);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateGroupInvitePrivacy(String privacy, String token) async {
    try {
      await updateUserSettings(token: token, groupInvitePrivacy: privacy);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCallPrivacy(String privacy, String token) async {
    try {
      await updateUserSettings(token: token, callPrivacy: privacy);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMediaAutoDownload(bool enabled, String token) async {
    try {
      await updateUserSettings(token: token, mediaAutoDownload: enabled);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMediaDownloadWifiOnly(bool enabled, String token) async {
    try {
      await updateUserSettings(token: token, mediaDownloadWifiOnly: enabled);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateFontSize(String size, String token) async {
    try {
      await updateUserSettings(token: token, fontSize: size);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAccessibilityMode(bool enabled, String token) async {
    try {
      await updateUserSettings(token: token, accessibilityMode: enabled);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Configurações padrão
  UserSettings getDefaultSettings() {
    return UserSettings(
      id: '',
      userId: '',
      theme: 'dark',
      language: 'pt-BR',
      notifications: true,
      soundEnabled: true,
      vibrationEnabled: true,
      readReceipts: true,
      lastSeen: true,
      profilePhoto: true,
      statusPrivacy: 'contacts',
      groupInvitePrivacy: 'contacts',
      callPrivacy: 'contacts',
      mediaAutoDownload: true,
      mediaDownloadWifiOnly: true,
      fontSize: 'medium',
      accessibilityMode: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Validar configurações
  bool validateSettings(UserSettings settings) {
    // Validar tema
    if (!['dark', 'light', 'system'].contains(settings.theme)) {
      return false;
    }

    // Validar idioma
    if (!['pt-BR', 'en-US', 'es-ES'].contains(settings.language)) {
      return false;
    }

    // Validar privacidade
    if (!['everyone', 'contacts', 'nobody'].contains(settings.statusPrivacy)) {
      return false;
    }

    if (!['everyone', 'contacts', 'nobody'].contains(settings.groupInvitePrivacy)) {
      return false;
    }

    if (!['everyone', 'contacts', 'nobody'].contains(settings.callPrivacy)) {
      return false;
    }

    // Validar tamanho da fonte
    if (!['small', 'medium', 'large'].contains(settings.fontSize)) {
      return false;
    }

    return true;
  }

  // Obter configurações de privacidade disponíveis
  List<String> getPrivacyOptions() {
    return ['everyone', 'contacts', 'nobody'];
  }

  // Obter temas disponíveis
  List<String> getThemeOptions() {
    return ['dark', 'light', 'system'];
  }

  // Obter idiomas disponíveis
  List<String> getLanguageOptions() {
    return ['pt-BR', 'en-US', 'es-ES'];
  }

  // Obter tamanhos de fonte disponíveis
  List<String> getFontSizeOptions() {
    return ['small', 'medium', 'large'];
  }

  // Obter texto localizado para configurações
  String getLocalizedText(String key) {
    final texts = {
      'theme': 'Tema',
      'language': 'Idioma',
      'notifications': 'Notificações',
      'soundEnabled': 'Som habilitado',
      'vibrationEnabled': 'Vibração habilitada',
      'readReceipts': 'Confirmação de leitura',
      'lastSeen': 'Última visualização',
      'profilePhoto': 'Foto do perfil',
      'statusPrivacy': 'Privacidade do status',
      'groupInvitePrivacy': 'Privacidade de convites de grupo',
      'callPrivacy': 'Privacidade de chamadas',
      'mediaAutoDownload': 'Download automático de mídia',
      'mediaDownloadWifiOnly': 'Download apenas no Wi-Fi',
      'fontSize': 'Tamanho da fonte',
      'accessibilityMode': 'Modo de acessibilidade',
    };

    return texts[key] ?? key;
  }
}
