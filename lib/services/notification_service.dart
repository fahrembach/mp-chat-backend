// services/notification_service.dart
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  bool _isInitialized = false;
  String? _fcmToken;

  // Callbacks
  Function(Notification)? onNotificationReceived;
  Function(String)? onNotificationError;

  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configurar notificações locais
      await _initializeLocalNotifications();
      
      // Configurar Firebase Messaging
      await _initializeFirebaseMessaging();
      
      // Solicitar permissões
      await _requestPermissions();
      
      _isInitialized = true;
      print('[NOTIFICATION] Service initialized successfully');
      
    } catch (e) {
      print('[NOTIFICATION] Error initializing service: $e');
      onNotificationError?.call('Erro ao inicializar notificações: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Configurar canal Android
    const androidChannel = AndroidNotificationChannel(
      'mp_chat_channel',
      'M-P Chat Notifications',
      description: 'Notificações do M-P Chat',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Obter token FCM
    _fcmToken = await _firebaseMessaging.getToken();
    print('[NOTIFICATION] FCM Token: $_fcmToken');

    // Configurar handlers de mensagem
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // Configurar handler para quando o app é aberto por notificação
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  Future<void> _requestPermissions() async {
    // Permissões locais
    await Permission.notification.request();
    
    // Permissões Firebase
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('[NOTIFICATION] User denied notification permissions');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload != null) {
        final data = json.decode(payload);
        final notification = Notification.fromJson(data);
        onNotificationReceived?.call(notification);
      }
    } catch (e) {
      print('[NOTIFICATION] Error handling notification tap: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('[NOTIFICATION] Received foreground message: ${message.messageId}');
    
    // Mostrar notificação local
    _showLocalNotification(message);
    
    // Processar dados da mensagem
    if (message.data.isNotEmpty) {
      try {
        final notification = Notification.fromJson(message.data);
        onNotificationReceived?.call(notification);
      } catch (e) {
        print('[NOTIFICATION] Error parsing notification data: $e');
      }
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('[NOTIFICATION] Received background message: ${message.messageId}');
    
    // Processar dados da mensagem
    if (message.data.isNotEmpty) {
      try {
        final notification = Notification.fromJson(message.data);
        onNotificationReceived?.call(notification);
      } catch (e) {
        print('[NOTIFICATION] Error parsing notification data: $e');
      }
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'mp_chat_channel',
      'M-P Chat Notifications',
      channelDescription: 'Notificações do M-P Chat',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'M-P Chat',
      message.notification?.body ?? 'Nova mensagem',
      details,
      payload: json.encode(message.data),
    );
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mp_chat_channel',
      'M-P Chat Notifications',
      channelDescription: 'Notificações do M-P Chat',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id ?? DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showScheduledNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    int? id,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mp_chat_channel',
      'M-P Chat Notifications',
      channelDescription: 'Notificações do M-P Chat',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id ?? DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      scheduledDate,
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('[NOTIFICATION] Subscribed to topic: $topic');
    } catch (e) {
      print('[NOTIFICATION] Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('[NOTIFICATION] Unsubscribed from topic: $topic');
    } catch (e) {
      print('[NOTIFICATION] Error unsubscribing from topic: $e');
    }
  }

  Future<void> sendNotificationToken(String token) async {
    try {
      // Salvar token localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      
      // Enviar token para o servidor
      // Implementar chamada para API do backend
      print('[NOTIFICATION] Token saved and sent to server: $token');
    } catch (e) {
      print('[NOTIFICATION] Error sending token: $e');
    }
  }

  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      print('[NOTIFICATION] Error getting stored token: $e');
      return null;
    }
  }

  Future<void> clearStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
    } catch (e) {
      print('[NOTIFICATION] Error clearing stored token: $e');
    }
  }

  Future<void> dispose() async {
    // Limpar recursos se necessário
  }
}
