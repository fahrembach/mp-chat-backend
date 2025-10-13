import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'service_locator.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'services/socket_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/users_screen.dart';
import 'screens/chat_room_screen.dart';
import 'models/user.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => locator<AuthProvider>(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => locator<ChatProvider>(),
          update: (_, auth, chat) {
            if (auth.isAuthenticated) {
              // You can trigger actions here when auth state changes
            }
            return chat!;
          },
        ),
        Provider<SocketService>(
          create: (_) => locator<SocketService>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = Provider.of<AuthProvider>(context);
          return MaterialApp.router(
            title: 'M-P Chat',
            theme: ThemeData.dark().copyWith(
              primaryColor: const Color(0xFF075E54), // Verde WhatsApp
              scaffoldBackgroundColor: const Color(0xFF121B22), // Fundo escuro
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1F2C34),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              cardColor: const Color(0xFF1F2C34),
              dividerColor: const Color(0xFF2A3942),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
                bodySmall: TextStyle(color: Colors.white60),
              ),
              iconTheme: const IconThemeData(color: Colors.white70),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF1F2C34),
                selectedItemColor: Color(0xFF25D366), // Verde WhatsApp
                unselectedItemColor: Colors.white60,
                type: BottomNavigationBarType.fixed,
              ),
              listTileTheme: const ListTileThemeData(
                textColor: Colors.white,
                iconColor: Colors.white70,
              ),
            ),
            routerConfig: _createRouter(authProvider),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const MainScreen(),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => UsersScreen(),
        ),
        GoRoute(
          path: '/chat/:userId',
          builder: (context, state) {
            final user = state.extra as User;
            return ChatRoomScreen(peer: user);
          },
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isLoggedIn && !isLoggingIn) return '/login';
        if (isLoggedIn && isLoggingIn) return '/';

        return null;
      },
    );
  }
}