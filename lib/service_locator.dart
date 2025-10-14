import 'package:get_it/get_it.dart';
import 'services/api_service.dart';
import 'services/socket_service.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/call_service.dart';
import 'services/call_history_service.dart';
import 'services/video_call_service.dart';
import 'services/voice_recording_service.dart';
import 'services/audio_playback_service.dart';
import 'services/search_service.dart';
import 'services/notification_service.dart';
import 'services/group_service.dart';
import 'services/settings_service.dart';
import 'services/status_service.dart';
import 'services/community_service.dart';
import 'services/file_upload_service.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'database/database.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Database
  locator.registerLazySingleton(() => AppDatabase());

  // Services
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => SocketService());
  locator.registerLazySingleton(() => DatabaseService(locator<AppDatabase>()));
locator.registerLazySingleton(() => CallService());
locator.registerLazySingleton(() => CallHistoryService(locator<ApiService>()));
locator.registerLazySingleton(() => VideoCallService());
locator.registerLazySingleton(() => VoiceRecordingService());
locator.registerLazySingleton(() => AudioPlaybackService());
locator.registerLazySingleton(() => SearchService());
locator.registerLazySingleton(() => NotificationService());
locator.registerLazySingleton(() => GroupService());
locator.registerLazySingleton(() => SettingsService());
locator.registerLazySingleton(() => FileUploadService(locator<ApiService>()));
locator.registerLazySingleton(() => StatusService(locator<ApiService>()));
locator.registerLazySingleton(() => CommunityService());
locator.registerLazySingleton(() => AuthService(locator<ApiService>(), locator<SocketService>(), locator<CallService>()));

  // Providers
  locator.registerFactory(() => AuthProvider(locator<AuthService>()));
  locator.registerFactory(() => ChatProvider(
        locator<ApiService>(),
        locator<SocketService>(),
        locator<DatabaseService>(),
        locator<AuthProvider>(),
        locator<CallService>(),
      ));
}